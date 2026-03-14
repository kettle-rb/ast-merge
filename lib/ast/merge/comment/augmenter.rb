# frozen_string_literal: true

require "set"

module Ast
  module Merge
    module Comment
      # Builds standardized comment regions and attachments from source text,
      # tracked comment hashes, and structural owner ranges.
      #
      # This is a passive augmentation layer. It does not modify merge behavior;
      # it only infers normalized `Comment::Region` and `Comment::Attachment`
      # objects that format gems can adopt incrementally.
      class Augmenter
        attr_reader :lines, :owners, :tracked_comments, :style, :capability, :attachments_by_owner,
          :preamble_region, :postlude_region, :orphan_regions

        def self.call(**options)
          new(**options)
        end

        def initialize(lines: nil, source: nil, comments: [], owners: [], style: nil, capability: nil, **options)
          @lines = normalize_lines(lines, source)
          @style = resolve_style(style)
          @owners = normalize_owners(owners)
          @tracked_comments = normalize_comments(comments)
          @capability = capability || Capability.source_augmented(
            source: :tracked_hash,
            style: style_name,
            owner_count: @owners.size,
            comment_count: @tracked_comments.size,
            **options,
          )

          @attachments_by_owner = {}
          @preamble_region = nil
          @postlude_region = nil
          @orphan_regions = []

          build!
        end

        def attachment_for(owner)
          attachments_by_owner[owner]
        end

        private

        def build!
          claimed = Set.new

          owners.each do |owner|
            leading_comments = infer_leading_comments(owner, claimed)
            inline_comments = infer_inline_comments(owner, claimed)

            attachments_by_owner[owner] = Attachment.new(
              owner: owner,
              leading_region: build_region(:leading, leading_comments),
              inline_region: build_region(:inline, inline_comments, include_blank_lines: false),
            )

            leading_comments.each { |comment| claimed << comment.object_id }
            inline_comments.each { |comment| claimed << comment.object_id }
          end

          infer_postlude!(claimed)
          infer_remaining_regions!(claimed)
        end

        def infer_leading_comments(owner, claimed)
          return [] unless owner.respond_to?(:start_line)
          return [] unless owner.start_line

          candidates = tracked_comments.select do |comment|
            comment[:full_line] && !claimed.include?(comment.object_id) && comment[:line] < owner.start_line
          end
          return [] if candidates.empty?

          selected = []
          current_line = owner.start_line - 1

          while current_line >= 1
            comment = candidates.find { |candidate| candidate[:line] == current_line }

            if comment
              selected.unshift(comment)
              current_line -= 1
            elsif blank_line?(current_line)
              current_line -= 1
            else
              break
            end
          end

          selected
        end

        def infer_inline_comments(owner, claimed)
          return [] unless owner.respond_to?(:start_line) && owner.respond_to?(:end_line)
          return [] unless owner.start_line && owner.end_line

          tracked_comments.select do |comment|
            !comment[:full_line] &&
              !claimed.include?(comment.object_id) &&
              (owner.start_line..owner.end_line).cover?(comment[:line])
          end
        end

        def infer_postlude!(claimed)
          last_line = owners.reverse_each.map(&:end_line).compact.first
          return unless last_line

          comments = tracked_comments.select do |comment|
            comment[:full_line] && !claimed.include?(comment.object_id) && comment[:line] > last_line
          end
          return if comments.empty?

          @postlude_region = build_region(:postlude, comments)
          comments.each { |comment| claimed << comment.object_id }
        end

        def infer_remaining_regions!(claimed)
          remaining = tracked_comments.select do |comment|
            comment[:full_line] && !claimed.include?(comment.object_id)
          end
          return if remaining.empty?

          groups = group_comments_with_blank_lines(remaining)
          first_owner_start = owners.first&.start_line

          groups.each do |group|
            kind = if first_owner_start && group.last[:line] < first_owner_start
              @preamble_region.nil? ? :preamble : :orphan
            else
              :orphan
            end

            region = build_region(kind, group)
            if kind == :preamble && @preamble_region.nil?
              @preamble_region = region
            else
              @orphan_regions << region
            end
          end
        end

        def group_comments_with_blank_lines(comments)
          sorted = comments.sort_by { |comment| comment[:line] }
          groups = []
          current = []

          sorted.each do |comment|
            if current.empty?
              current << comment
              next
            end

            if only_blank_lines_between?(current.last[:line], comment[:line])
              current << comment
            else
              groups << current
              current = [comment]
            end
          end

          groups << current if current.any?
          groups
        end

        def only_blank_lines_between?(from_line, to_line)
          return true if to_line <= from_line + 1

          ((from_line + 1)...to_line).all? { |line_number| blank_line?(line_number) }
        end

        def build_region(kind, comments, include_blank_lines: true)
          return if comments.empty?

          nodes = []
          previous_line = nil

          comments.sort_by { |comment| comment[:line] }.each do |comment|
            if include_blank_lines && previous_line
              ((previous_line + 1)...comment[:line]).each do |line_number|
                nodes << Empty.new(line_number: line_number, text: line_at(line_number).to_s) if blank_line?(line_number)
              end
            end

            nodes << TrackedHashAdapter.node(comment, style: style)
            previous_line = comment[:line]
          end

          Region.new(
            kind: kind,
            nodes: nodes,
            metadata: {
              source: :augmenter,
              tracked_hashes: comments,
            },
          )
        end

        def normalize_lines(lines, source)
          return Array(lines) if lines
          return [] unless source

          values = source.split("\n", -1)
          values.pop if values.last&.empty? && source.end_with?("\n")
          values
        end

        def resolve_style(style)
          case style
          when nil
            Style.for(:hash_comment)
          when Style
            style
          else
            Style.for(style)
          end
        end

        def style_name
          style.respond_to?(:name) ? style.name : style.to_s
        end

        def normalize_comments(comments)
          Array(comments)
            .map { |comment| normalize_comment_hash(comment) }
            .sort_by { |comment| comment[:line] }
        end

        def normalize_comment_hash(comment)
          raise ArgumentError, "comment must be a Hash" unless comment.is_a?(Hash)

          comment.each_with_object({}) do |(key, value), result|
            result[key.to_sym] = value
          end
        end

        def normalize_owners(owners)
          Array(owners)
            .tap { |values| values.each { |owner| validate_owner!(owner) } }
            .sort_by { |owner| [owner.start_line || Float::INFINITY, owner.end_line || Float::INFINITY] }
        end

        def validate_owner!(owner)
          unless owner.respond_to?(:start_line) && owner.respond_to?(:end_line)
            raise ArgumentError, "owner must respond to #start_line and #end_line"
          end
        end

        def blank_line?(line_number)
          line_at(line_number).to_s.strip.empty?
        end

        def line_at(line_number)
          return if line_number < 1

          lines[line_number - 1]
        end
      end
    end
  end
end
