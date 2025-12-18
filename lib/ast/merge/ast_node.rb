# frozen_string_literal: true

module Ast
  module Merge
    # Base class for synthetic AST nodes in the ast-merge framework.
    #
    # "Synthetic" nodes are nodes that aren't backed by a real parser - they're
    # created by ast-merge for representing content that doesn't have a native
    # AST (comments, text lines, env file entries, etc.).
    #
    # This class implements the TreeHaver::Node protocol, making it compatible
    # with all code that expects TreeHaver nodes. This allows synthetic nodes
    # to be used interchangeably with parser-backed nodes in merge operations.
    #
    # Implements the TreeHaver::Node protocol:
    # - type → String node type
    # - text / slice → Source text content
    # - start_byte / end_byte → Byte offsets
    # - start_point / end_point → Point (row, column)
    # - children → Array of child nodes
    # - named? / structural? → Node classification
    # - inner_node → Returns self (no wrapping layer for synthetic nodes)
    #
    # Adds merge-specific methods:
    # - signature → Array used for matching nodes across files
    # - normalized_content → Cleaned text for comparison
    #
    # @example Subclassing for custom node types
    #   class MyNode < AstNode
    #     def type
    #       "my_node"
    #     end
    #
    #     def signature
    #       [:my_node, normalized_content]
    #     end
    #   end
    #
    # @see TreeHaver::Node The protocol this class implements
    # @see Comment::Line Example synthetic node for comments
    # @see Text::LineNode Example synthetic node for text lines
    class AstNode
      include Comparable

      # Point class compatible with TreeHaver::Point
      # Provides both method and hash-style access to row/column
      Point = Struct.new(:row, :column, keyword_init: true) do
        # Hash-like access for compatibility
        def [](key)
          case key
          when :row, "row" then row
          when :column, "column" then column
          end
        end

        def to_h
          {row: row, column: column}
        end

        def to_s
          "(#{row}, #{column})"
        end

        def inspect
          "#<Ast::Merge::AstNode::Point row=#{row} column=#{column}>"
        end
      end

      # Location struct for tracking source positions
      # Compatible with TreeHaver location expectations
      Location = Struct.new(:start_line, :end_line, :start_column, :end_column, keyword_init: true) do
        # Check if a line number falls within this location
        # @param line_number [Integer] The line number to check (1-based)
        # @return [Boolean] true if the line number is within the range
        def cover?(line_number)
          line_number.between?(start_line, end_line)
        end
      end

      # @return [Location] The location of this node in source
      attr_reader :location

      # @return [String] The source text for this node
      attr_reader :slice

      # @return [String, nil] The full source text (for text extraction)
      attr_reader :source

      # Initialize a new AstNode.
      #
      # @param slice [String] The source text for this node
      # @param location [Location, #start_line] Location object
      # @param source [String, nil] Full source text (optional)
      def initialize(slice:, location:, source: nil)
        @slice = slice
        @location = location
        @source = source
      end

      # TreeHaver::Node protocol: inner_node
      # For synthetic nodes, this returns self (no wrapping layer)
      #
      # @return [AstNode] self
      def inner_node
        self
      end

      # TreeHaver::Node protocol: type
      # Returns the node type as a string.
      # Subclasses should override this with specific type names.
      #
      # @return [String] Node type
      def type
        # Default: derive from class name (MyNode → "my_node")
        self.class.name.split("::").last
          .gsub(/([A-Z])/, '_\1')
          .downcase
          .sub(/^_/, "")
      end

      # Alias for tree-sitter compatibility
      alias_method :kind, :type

      # TreeHaver::Node protocol: text
      # @return [String] The source text
      def text
        slice.to_s
      end

      # TreeHaver::Node protocol: start_byte
      # Calculates byte offset from source if available, otherwise estimates from lines
      #
      # @return [Integer] Starting byte offset
      def start_byte
        return 0 unless source && location

        # Calculate byte offset from line/column
        lines = source.lines
        byte_offset = 0
        (0...(location.start_line - 1)).each do |i|
          byte_offset += lines[i]&.bytesize || 0
        end
        byte_offset + (location.start_column || 0)
      end

      # TreeHaver::Node protocol: end_byte
      #
      # @return [Integer] Ending byte offset
      def end_byte
        start_byte + slice.to_s.bytesize
      end

      # TreeHaver::Node protocol: start_point
      # Returns a Point with row (0-based) and column
      #
      # @return [Point] Starting position
      def start_point
        Point.new(
          row: (location&.start_line || 1) - 1,  # Convert to 0-based
          column: location&.start_column || 0,
        )
      end

      # TreeHaver::Node protocol: end_point
      # Returns a Point with row (0-based) and column
      #
      # @return [Point] Ending position
      def end_point
        Point.new(
          row: (location&.end_line || 1) - 1,  # Convert to 0-based
          column: location&.end_column || 0,
        )
      end

      # TreeHaver::Node protocol: children
      # @return [Array<AstNode>] Child nodes (empty for leaf nodes)
      def children
        []
      end

      # TreeHaver::Node protocol: child_count
      # @return [Integer] Number of children
      def child_count
        children.size
      end

      # TreeHaver::Node protocol: child(index)
      # @param index [Integer] Child index
      # @return [AstNode, nil] Child at index
      def child(index)
        children[index]
      end

      # TreeHaver::Node protocol: named?
      # Synthetic nodes are always "named" (structural) nodes
      #
      # @return [Boolean] true
      def named?
        true
      end

      # TreeHaver::Node protocol: structural?
      # Synthetic nodes are always structural
      #
      # @return [Boolean] true
      def structural?
        true
      end

      # TreeHaver::Node protocol: has_error?
      # Synthetic nodes don't have parse errors
      #
      # @return [Boolean] false
      def has_error?
        false
      end

      # TreeHaver::Node protocol: missing?
      # Synthetic nodes are never "missing"
      #
      # @return [Boolean] false
      def missing?
        false
      end

      # TreeHaver::Node protocol: each
      # Iterate over children
      #
      # @yield [AstNode] Each child node
      # @return [Enumerator, nil]
      def each(&block)
        return to_enum(__method__) unless block_given?
        children.each(&block)
      end

      # Generate a signature for this node for matching purposes.
      #
      # Override in subclasses for custom signature logic.
      # Default returns the node type and a normalized form of the slice.
      #
      # @return [Array] Signature array for matching
      def signature
        [type.to_sym, normalized_content]
      end

      # @return [String] Normalized content for signature comparison
      def normalized_content
        slice.to_s.strip
      end

      # Comparable: compare nodes by position
      #
      # @param other [AstNode] node to compare with
      # @return [Integer, nil] -1, 0, 1, or nil if not comparable
      def <=>(other)
        return unless other.respond_to?(:start_byte) && other.respond_to?(:end_byte)

        cmp = start_byte <=> other.start_byte
        return cmp if cmp.nonzero?

        end_byte <=> other.end_byte
      end

      # @return [String] Human-readable representation
      def inspect
        "#<#{self.class.name} type=#{type} lines=#{location&.start_line}..#{location&.end_line}>"
      end

      # @return [String] The source text
      def to_s
        slice.to_s
      end

      # Support unwrap protocol (returns self for non-wrapper nodes)
      # @return [AstNode] self
      def unwrap
        self
      end
    end

    # Alias for clarity - SyntheticNode clearly indicates "not backed by a real parser"
    # Use this alias when the distinction between synthetic and parser-backed nodes matters.
    #
    # @see AstNode
    SyntheticNode = AstNode
  end
end
