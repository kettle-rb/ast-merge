# frozen_string_literal: true

module Ast
  module Merge
    # Represents a detected region within a document.
    #
    # Regions are portions of a document that can be handled by a specialized
    # merger. For example, YAML frontmatter in a Markdown file, or a Ruby code
    # block that should be merged using a Ruby-aware merger.
    #
    # @example Creating a region for YAML frontmatter
    #   Region.new(
    #     type: :yaml_frontmatter,
    #     content: "title: My Doc\nversion: 1.0\n",
    #     start_line: 1,
    #     end_line: 4,
    #     delimiters: ["---", "---"],
    #     metadata: { format: :yaml }
    #   )
    #
    # @example Creating a region for a Ruby code block
    #   Region.new(
    #     type: :ruby_code_block,
    #     content: "def hello\n  puts 'world'\nend\n",
    #     start_line: 5,
    #     end_line: 9,
    #     delimiters: ["```ruby", "```"],
    #     metadata: { language: "ruby" }
    #   )
    #
    # @api public
    Region = Struct.new(
      # @return [Symbol] The type of region (e.g., :yaml_frontmatter, :ruby_code_block)
      :type,

      # @return [String] The raw string content of this region (inner content, without delimiters)
      :content,

      # @return [Integer] 1-indexed start line in the original document
      :start_line,

      # @return [Integer] 1-indexed end line in the original document
      :end_line,

      # @return [Array<String>, nil] Delimiter strings to reconstruct the region
      #   ["```ruby", "```"] - [opening_delimiter, closing_delimiter]
      :delimiters,

      # @return [Hash, nil] Optional metadata for detector-specific information
      #   (e.g., { language: "ruby" }, { format: :yaml })
      :metadata,

      keyword_init: true
    ) do
      # Returns the line range covered by this region.
      #
      # @return [Range] The range from start_line to end_line (inclusive)
      # @example
      #   region.line_range # => 1..4
      def line_range
        start_line..end_line
      end

      # Returns the number of lines this region spans.
      #
      # @return [Integer] The number of lines
      # @example
      #   region.line_count # => 4
      def line_count
        end_line - start_line + 1
      end

      # Reconstructs the full region text including delimiters.
      #
      # @return [String] The complete region with start and end delimiters
      # @example
      #   region.full_text
      #   # => "```ruby\ndef hello\n  puts 'world'\nend\n```"
      def full_text
        return content if delimiters.nil? || delimiters.empty?

        opening = delimiters[0] || ""
        closing = delimiters[1] || ""
        "#{opening}\n#{content}#{closing}"
      end

      # Checks if this region overlaps with the given line number.
      #
      # @param line [Integer] The line number to check (1-indexed)
      # @return [Boolean] true if the line is within this region
      def contains_line?(line)
        line_range.cover?(line)
      end

      # Checks if this region overlaps with another region.
      #
      # @param other [Region] Another region to check for overlap
      # @return [Boolean] true if the regions overlap
      def overlaps?(other)
        line_range.cover?(other.start_line) ||
          line_range.cover?(other.end_line) ||
          other.line_range.cover?(start_line)
      end

      # Returns a short string representation of the region.
      #
      # @return [String] A concise string describing the region
      def to_s
        "Region<#{type}:#{start_line}-#{end_line}>"
      end

      # Returns a detailed human-readable representation of the region.
      #
      # @return [String] A string describing the region with truncated content
      def inspect
        truncated = if content && content.length > 30
          "#{content[0, 30]}..."
        else
          content.inspect
        end
        "#{to_s} #{truncated}"
      end
    end
  end
end
