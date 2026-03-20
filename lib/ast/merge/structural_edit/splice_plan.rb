# frozen_string_literal: true

module Ast
  module Merge
    module StructuralEdit
      # Passive plan for a contiguous structural splice.
      #
      # The first shared primitive models exact line-range replacement: keep the
      # original source untouched outside the replaced window and substitute only
      # the requested structural range. This avoids separator surgery in callers
      # such as PartialTemplateMergerBase and gives future remove/rehome work a
      # stable place to grow richer ownership-transfer rules.
      class SplicePlan
        attr_reader :source,
          :replacement,
          :replace_start_line,
          :replace_end_line,
          :leading_boundary,
          :trailing_boundary,
          :preserve_removed_trailing_blank_lines,
          :metadata

        def initialize(source:, replacement:, replace_start_line:, replace_end_line:, leading_boundary: nil, trailing_boundary: nil, preserve_removed_trailing_blank_lines: true, metadata: {}, **options)
          @source = source.to_s
          @replacement = replacement.to_s
          @replace_start_line = Integer(replace_start_line)
          @replace_end_line = Integer(replace_end_line)
          @leading_boundary = leading_boundary
          @trailing_boundary = trailing_boundary
          @preserve_removed_trailing_blank_lines = preserve_removed_trailing_blank_lines
          @metadata = metadata.merge(options).freeze

          validate_range!
        end

        def line_chunks
          @line_chunks ||= source.lines
        end

        def before_content
          line_chunks[0...(replace_start_line - 1)].to_a.join
        end

        def line_range
          replace_start_line..replace_end_line
        end

        def removed_content
          line_chunks[(replace_start_line - 1)..(replace_end_line - 1)].to_a.join
        end

        def after_content
          line_chunks[replace_end_line..].to_a.join
        end

        def merged_content
          +before_content + replacement_with_preserved_boundary_layout + after_content
        end

        def changed?
          merged_content != source
        end

        def to_splice_plan
          self
        end

        def apply_to(alternate_source = source)
          alternate_text = alternate_source.to_s
          return merged_content if alternate_text == source

          self.class.new(
            source: alternate_text,
            replacement: replacement,
            replace_start_line: replace_start_line,
            replace_end_line: replace_end_line,
            leading_boundary: leading_boundary,
            trailing_boundary: trailing_boundary,
            metadata: metadata,
          ).merged_content
        end

        def inspect
          "#<#{self.class.name} lines=#{replace_start_line}..#{replace_end_line} changed=#{changed?}>"
        end

        private

        def replacement_with_preserved_boundary_layout
          result = +replacement

          if preserve_removed_trailing_blank_lines?
            result << missing_trailing_blank_line_chunks.join
          end

          result
        end

        def preserve_removed_trailing_blank_lines?
          return false unless preserve_removed_trailing_blank_lines

          !after_content.empty? &&
            !missing_trailing_blank_line_chunks.empty?
        end

        def missing_trailing_blank_line_chunks
          removed_blank_chunks = trailing_blank_line_chunks(removed_content)
          replacement_blank_chunks = trailing_blank_line_chunks(replacement)
          return [] if removed_blank_chunks.empty?
          return [] if replacement_blank_chunks.length >= removed_blank_chunks.length
          return [] if after_content.start_with?("\n")

          removed_blank_chunks[replacement_blank_chunks.length..]
        end

        def trailing_blank_line_chunks(text)
          text.lines.reverse.take_while { |line| line.strip.empty? }.reverse
        end

        def validate_range!
          raise ArgumentError, "replace_start_line must be >= 1" if replace_start_line < 1
          raise ArgumentError, "replace_end_line must be >= replace_start_line" if replace_end_line < replace_start_line

          line_count = line_chunks.length
          return if replace_end_line <= line_count

          raise ArgumentError,
            "replace_end_line #{replace_end_line} exceeds source line count #{line_count}"
        end
      end
    end
  end
end
