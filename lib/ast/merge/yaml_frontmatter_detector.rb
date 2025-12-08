# frozen_string_literal: true

module Ast
  module Merge
    ##
    # Detects YAML frontmatter at the beginning of a document.
    #
    # YAML frontmatter is delimited by `---` at the start and end,
    # and must begin on the first line of the document (optionally
    # preceded by a UTF-8 BOM).
    #
    # @example YAML frontmatter
    #   ---
    #   title: My Document
    #   author: Jane Doe
    #   ---
    #
    # @example Usage
    #   detector = YamlFrontmatterDetector.new
    #   regions = detector.detect_all(markdown_source)
    #   # => [#<Region type=:yaml_frontmatter content="title: My Document\n...">]
    #
    class YamlFrontmatterDetector < RegionDetectorBase
      ##
      # Pattern for detecting YAML frontmatter.
      # - Must start at beginning of document (or after BOM)
      # - Opening delimiter is `---` followed by optional whitespace and newline
      # - Content is captured (non-greedy)
      # - Closing delimiter is `---` at start of line, followed by optional whitespace and newline/EOF
      #
      FRONTMATTER_PATTERN = /\A(?:\xEF\xBB\xBF)?(---[ \t]*\r?\n)(.*?)(^---[ \t]*(?:\r?\n|\z))/m.freeze

      ##
      # @return [Symbol] the type identifier for YAML frontmatter regions
      #
      def region_type
        :yaml_frontmatter
      end

      ##
      # Detects YAML frontmatter at the beginning of the document.
      #
      # @param source [String] the source document to scan
      # @return [Array<Region>] array containing at most one Region for frontmatter
      #
      def detect_all(source)
        return [] if source.nil? || source.empty?

        match = source.match(FRONTMATTER_PATTERN)
        return [] unless match

        opening_delimiter = match[1]
        content = match[2]
        closing_delimiter = match[3]

        # Calculate line numbers
        # Frontmatter starts at line 1 (or after BOM)
        start_line = 1
        # Count newlines in content to determine end line
        # Opening delimiter ends at line 1
        # Content spans from line 2 to line 2 + content_lines - 1
        # Closing delimiter is on the next line
        content_newlines = content.count("\n")
        # end_line is the line with the closing ---
        end_line = start_line + 1 + content_newlines

        # Adjust if content ends without newline
        end_line -= 1 if content.end_with?("\n") && content_newlines > 0

        # Actually, let's calculate more carefully
        # Line 1: ---
        # Line 2 to N: content
        # Line N+1: ---
        lines_in_opening = 1
        lines_in_content = content.empty? ? 0 : content.count("\n") + (content.end_with?("\n") ? 0 : 1)
        end_line = lines_in_opening + lines_in_content + 1

        # Simplify: count total newlines in the full match to determine end line
        full_match = match[0]
        total_newlines = full_match.count("\n")
        end_line = total_newlines + (full_match.end_with?("\n") ? 0 : 1)

        [
          Region.new(
            type: region_type,
            content: content,
            start_line: start_line,
            end_line: end_line,
            delimiters: [opening_delimiter.strip, closing_delimiter.strip],
            metadata: {format: :yaml},
          ),
        ]
      end

      private

      ##
      # @return [Array<Region>] array containing at most one Region
      #
      def build_regions(source, matches)
        # Not used - detect_all is overridden directly
        raise NotImplementedError, "YamlFrontmatterDetector overrides detect_all directly"
      end
    end
  end
end
