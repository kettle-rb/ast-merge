# frozen_string_literal: true

module Ast
  module Merge
    # Base class for region detection.
    #
    # Region detectors identify portions of a document that should be handled
    # by a specialized merger. For example, detecting YAML frontmatter in a
    # Markdown file, or Ruby code blocks that should be merged with Prism.
    #
    # Subclasses must implement:
    # - {#region_type} - Returns the type symbol for detected regions
    # - {#detect_all} - Finds all regions of this type in a document
    #
    # @example Implementing a custom detector
    #   class MyBlockDetector < Ast::Merge::RegionDetectorBase
    #     def region_type
    #       :my_block
    #     end
    #
    #     def detect_all(source)
    #       # Return array of Region structs
    #       []
    #     end
    #   end
    #
    # @abstract Subclass and implement {#region_type} and {#detect_all}
    # @api public
    class RegionDetectorBase
      # Returns the type symbol for regions detected by this detector.
      #
      # This symbol is used to identify the region type in the Region struct
      # and for matching regions between template and destination documents.
      #
      # @return [Symbol] The region type (e.g., :yaml_frontmatter, :ruby_code_block)
      # @abstract Subclasses must implement this method
      def region_type
        raise NotImplementedError, "#{self.class}#region_type must be implemented"
      end

      # Detects all regions of this type in the given source.
      #
      # @param source [String] The full document content to scan
      # @return [Array<Region>] All detected regions, sorted by start_line
      # @abstract Subclasses must implement this method
      #
      # @example Return value structure
      #   [
      #     Region.new(
      #       type: :yaml_frontmatter,
      #       content: "title: My Doc\n",
      #       start_line: 1,
      #       end_line: 3,
      #       delimiters: { start: "---\n", end: "---\n" },
      #       metadata: { format: :yaml }
      #     )
      #   ]
      def detect_all(source)
        raise NotImplementedError, "#{self.class}#detect_all must be implemented"
      end

      # Whether to strip delimiters from content before passing to merger.
      #
      # When true (default), only the inner content is passed to the region's
      # merger. The delimiters are stored separately and reattached after merging.
      #
      # When false, the full content including delimiters is passed to the merger,
      # which must then handle the delimiters itself.
      #
      # @return [Boolean] true if delimiters should be stripped (default: true)
      def strip_delimiters?
        true
      end

      # A human-readable name for this detector.
      #
      # Used in error messages and debugging output.
      #
      # @return [String] The detector name
      def name
        self.class.name || "AnonymousDetector"
      end

      # Returns a string representation of this detector.
      #
      # @return [String] A description of the detector
      def inspect
        "#<#{name} region_type=#{region_type}>"
      end

      protected

      # Helper to build a Region struct with common defaults.
      #
      # @param type [Symbol] The region type
      # @param content [String] The inner content (without delimiters)
      # @param start_line [Integer] 1-indexed start line
      # @param end_line [Integer] 1-indexed end line
      # @param delimiters [Hash, nil] { start: String, end: String }
      # @param metadata [Hash, nil] Additional metadata
      # @return [Region] A new Region struct
      def build_region(type:, content:, start_line:, end_line:, delimiters: nil, metadata: nil)
        Region.new(
          type: type,
          content: content,
          start_line: start_line,
          end_line: end_line,
          delimiters: delimiters,
          metadata: metadata || {},
        )
      end
    end
  end
end
