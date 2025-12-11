# frozen_string_literal: true

module Ast
  module Merge
    # Base class for AST nodes in the ast-merge framework.
    #
    # This provides a common API that works across different AST implementations
    # (Prism, TreeSitter, custom comment nodes, etc.) enabling uniform handling
    # in merge operations.
    #
    # Subclasses should implement:
    # - #slice - returns the source text for the node
    # - #location - returns an object responding to start_line/end_line
    # - #children - returns child nodes (empty array for leaf nodes)
    # - #signature - returns a signature array for matching (optional, can use default)
    #
    # @abstract
    class AstNode
      # Simple location struct for nodes that don't have a native location object
      Location = Struct.new(:start_line, :end_line, :start_column, :end_column, keyword_init: true) do
        # @return [Array<Object>] Empty array - custom nodes don't have Prism-style attached comments
        def leading_comments
          []
        end

        # @return [Array<Object>] Empty array - custom nodes don't have Prism-style attached comments
        def trailing_comments
          []
        end
      end

      # @return [Location] The location of this node in source
      attr_reader :location

      # @return [String] The source text for this node
      attr_reader :slice

      # Initialize a new AstNode.
      #
      # @param slice [String] The source text for this node
      # @param location [Location, #start_line] Location object or anything responding to start_line/end_line
      def initialize(slice:, location:)
        @slice = slice
        @location = location
      end

      # @return [Array<AstNode>] Child nodes (empty for leaf nodes)
      def children
        []
      end

      # Generate a signature for this node for matching purposes.
      #
      # Override in subclasses for custom signature logic.
      # Default returns the node class name and a normalized form of the slice.
      #
      # @return [Array] Signature array for matching
      def signature
        [self.class.name, normalized_content]
      end

      # @return [String] Normalized content for signature comparison
      def normalized_content
        slice.to_s.strip
      end

      # @return [String] Human-readable representation
      def inspect
        "#<#{self.class.name} lines=#{location.start_line}..#{location.end_line} slice=#{slice.to_s[0..50].inspect}>"
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

      # Check if this node responds to the Prism-style location API
      # @return [Boolean] true
      def respond_to_missing?(method, include_private = false)
        [:location, :slice].include?(method) || super
      end
    end
  end
end
