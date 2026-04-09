# frozen_string_literal: true

module Ast
  module Merge
    # Base class for tracking merge results in AST merge libraries.
    # Provides shared decision constants and base functionality for
    # file-type-specific implementations.
    #
    # @example Basic usage in a subclass
    #   class MyMergeResult < Ast::Merge::MergeResultBase
    #     def add_node(node, decision:, source:)
    #       # File-type-specific node handling
    #     end
    #   end
    class MergeResultBase
      # Decision constants for tracking merge choices

      # Line was kept from template (no conflict or template preferred).
      # Used when template content is included without modification.
      DECISION_KEPT_TEMPLATE = :kept_template

      # Line was kept from destination (no conflict or destination preferred).
      # Used when destination content is included without modification.
      DECISION_KEPT_DEST = :kept_destination

      # Line was merged from both sources.
      # Used when content was combined from template and destination.
      DECISION_MERGED = :merged

      # Line was added from template (template-only content).
      # Used for content that exists only in template and is added to result.
      DECISION_ADDED = :added

      # Line from destination freeze block (always preserved).
      # Used for content within freeze markers that must be kept
      # from destination regardless of template content.
      DECISION_FREEZE_BLOCK = :freeze_block

      # Line replaced matching content (signature match with preference applied).
      # Used when template and destination have nodes with same signature but
      # different content, and one version replaced the other based on preference.
      DECISION_REPLACED = :replaced

      # Line was appended from destination (destination-only content).
      # Used for content that exists only in destination and is added to result.
      DECISION_APPENDED = :appended

      # @return [Array<String>] Lines in the result (canonical storage for line-by-line merging)
      attr_reader :lines

      # @return [Array<Hash>] Decisions made during merge
      attr_reader :decisions

      # @return [Object, nil] Analysis of the template file
      attr_reader :template_analysis

      # @return [Object, nil] Analysis of the destination file
      attr_reader :dest_analysis

      # @return [Array<Hash>] Conflicts detected during merge
      attr_reader :conflicts

      # @return [Array] Frozen blocks preserved during merge
      attr_reader :frozen_blocks

      # @return [Hash] Statistics about the merge
      attr_reader :stats

      # Initialize a new merge result.
      #
      # This unified constructor accepts all parameters that any *-merge gem might need.
      # Subclasses should call super with the parameters they use.
      #
      # @param template_analysis [Object, nil] Analysis of the template file
      # @param dest_analysis [Object, nil] Analysis of the destination file
      # @param conflicts [Array<Hash>] Conflicts detected during merge
      # @param frozen_blocks [Array] Frozen blocks preserved during merge
      # @param stats [Hash] Statistics about the merge
      # @param options [Hash] Additional options for forward compatibility
      def initialize(
        template_analysis: nil,
        dest_analysis: nil,
        conflicts: [],
        frozen_blocks: [],
        stats: {},
        **options
      )
        @template_analysis = template_analysis
        @dest_analysis = dest_analysis
        @lines = []
        @decisions = []
        @conflicts = conflicts
        @frozen_blocks = frozen_blocks
        @stats = stats
        # **options captured for forward compatibility - subclasses may use additional options
      end

      # Get content - returns @lines array for most gems.
      # Subclasses may override for different content models (e.g., string).
      #
      # @return [Array<String>] The merged content as array of lines
      def content
        @lines
      end

      # Set content from a string (splits on newlines).
      # Used when region substitution replaces the merged content.
      #
      # @param value [String] The new content
      def content=(value)
        @lines = value.to_s.split("\n", -1)
      end

      # Get content as a string.
      # This is the canonical method for converting the merge result to a string.
      # Ensures a trailing newline for non-empty content, matching standard file
      # conventions and the pattern used by EmitterBase#to_s, Psych::Merge::MergeResult#to_yaml,
      # and Bash::Merge::MergeResult#to_bash.
      #
      # @return [String] Content as string joined with newlines
      def to_s
        content = @lines.join("\n")
        content += "\n" unless content.empty? || content.end_with?("\n")
        content
      end

      # Collapse runs of consecutive blank lines in @lines down to at most
      # +max_consecutive+ blank lines.  Defaults to 1, which preserves
      # single-gap semantics while removing accidental double/triple gaps
      # left behind by comment deduplication or node removal.
      # Also removes the corresponding entries from @decisions to keep
      # the two arrays in sync.  Trailing blank lines at EOF are preserved.
      #
      # @param max_consecutive [Integer] Maximum allowed consecutive blank lines
      def normalize_consecutive_blank_lines!(max_consecutive: 1)
        return if @lines.empty?

        # Find last non-blank line — only normalize interior gaps
        last_content_idx = @lines.rindex { |line| !line.strip.empty? }
        return unless last_content_idx # all blank — nothing to normalize

        consecutive = 0
        indices_to_remove = []
        @lines.each_with_index do |line, idx|
          break if idx > last_content_idx

          if line.strip.empty?
            consecutive += 1
            indices_to_remove << idx if consecutive > max_consecutive
          else
            consecutive = 0
          end
        end

        return if indices_to_remove.empty?

        indices_to_remove.reverse_each do |idx|
          @lines.delete_at(idx)
          @decisions&.delete_at(idx)
        end
      end

      # Check if content has been built (has any lines).
      #
      # @return [Boolean]
      def content?
        !@lines.empty?
      end

      # Check if the result is empty
      # @return [Boolean]
      def empty?
        @lines.empty?
      end

      # Get the number of lines
      # @return [Integer]
      def line_count
        @lines.length
      end

      # Get summary of decisions made
      # @return [Hash<Symbol, Integer>]
      def decision_summary
        summary = Hash.new(0)
        @decisions.each { |d| summary[d[:decision]] += 1 }
        summary
      end

      # String representation
      # @return [String]
      def inspect
        "#<#{self.class.name} lines=#{line_count} decisions=#{@decisions.length}>"
      end

      protected

      # Track a decision
      # @param decision [Symbol] The decision made
      # @param source [Symbol] The source (:template, :destination, :merged)
      # @param line [Integer, nil] The line number
      def track_decision(decision, source, line: nil)
        @decisions << {
          decision: decision,
          source: source,
          line: line,
          timestamp: Time.now,
        }
      end
    end
  end
end
