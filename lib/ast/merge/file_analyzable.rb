# frozen_string_literal: true

module Ast
  module Merge
    # Mixin module for file analysis classes across all *-merge gems.
    #
    # This module provides common functionality for analyzing source files,
    # including freeze block detection, line access, and signature generation.
    # Include this module in your FileAnalysis class and implement the required
    # abstract methods.
    #
    # @example Including in a FileAnalysis class
    #   class FileAnalysis
    #     include Ast::Merge::FileAnalyzable
    #
    #     def initialize(source, freeze_token: DEFAULT_FREEZE_TOKEN, signature_generator: nil)
    #       @source = source
    #       @lines = source.split("\n", -1)
    #       @freeze_token = freeze_token
    #       @signature_generator = signature_generator
    #       @statements = parse_and_extract_statements
    #     end
    #
    #     # Required: implement this method for parser-specific signature logic
    #     def compute_node_signature(node)
    #       # Return signature array or nil
    #     end
    #
    #     # Required: implement if using generate_signature with custom node type detection
    #     def fallthrough_node?(node)
    #       node.is_a?(MyParser::Node) || node.is_a?(FreezeNodeBase)
    #     end
    #   end
    #
    # @abstract Include this module and implement {#compute_node_signature} and optionally {#fallthrough_node?}
    module FileAnalyzable
      # Common attributes shared by all FileAnalysis classes.
      # These attr_reader declarations provide consistent interface across all merge gems.
      # Including classes should set these instance variables in their initialize method.
      #
      # @!attribute [r] source
      #   @return [String] Original source content
      # @!attribute [r] lines
      #   @return [Array<String>] Lines of source code (may be specialized in subclasses)
      # @!attribute [r] freeze_token
      #   @return [String] Token used to mark freeze blocks (e.g., "prism-merge", "psych-merge")
      # @!attribute [r] signature_generator
      #   @return [Proc, nil] Custom signature generator, or nil to use default
      def self.included(base)
        base.class_eval do
          attr_reader :source, :lines, :freeze_token, :signature_generator
        end
      end

      # Get all top-level statements (nodes and freeze blocks).
      # Override this method in including classes to return the appropriate collection.
      # The default implementation returns @statements if set, otherwise an empty array.
      #
      # @return [Array] All top-level statements
      def statements
        @statements ||= []
      end

      # Get all freeze blocks from statements.
      #
      # @return [Array<FreezeNodeBase>] All freeze block nodes
      def freeze_blocks
        statements.select { |node| node.is_a?(FreezeNodeBase) }
      end

      # Check if a line is within a freeze block.
      #
      # @param line_num [Integer] 1-based line number
      # @return [Boolean] true if line is inside a freeze block
      def in_freeze_block?(line_num)
        freeze_blocks.any? { |fb| fb.location.cover?(line_num) }
      end

      # Get the freeze block containing the given line, if any.
      #
      # @param line_num [Integer] 1-based line number
      # @return [FreezeNodeBase, nil] Freeze block node or nil
      def freeze_block_at(line_num)
        freeze_blocks.find { |fb| fb.location.cover?(line_num) }
      end

      # Get structural signature for a statement at given index.
      #
      # @param index [Integer] Statement index (0-based)
      # @return [Array, nil] Signature array or nil if index out of bounds
      def signature_at(index)
        return nil if index < 0 || index >= statements.length

        generate_signature(statements[index])
      end

      # Get a specific line (1-indexed).
      #
      # @param line_num [Integer] Line number (1-indexed)
      # @return [String, nil] The line content or nil if out of bounds
      def line_at(line_num)
        return nil if line_num < 1

        lines[line_num - 1]
      end

      # Get a normalized line (whitespace-trimmed, for comparison).
      #
      # @param line_num [Integer] Line number (1-indexed)
      # @return [String, nil] Normalized line content or nil if out of bounds
      def normalized_line(line_num)
        line = line_at(line_num)
        line&.strip
      end

      # Generate signature for a node.
      #
      # If a custom signature_generator is provided, it is called first.
      # The custom generator can return:
      # - An array signature (e.g., `[:gem, "foo"]`) - used as the signature
      # - `nil` - the node gets no signature (won't be matched by signature)
      # - A parser node or FreezeNodeBase - falls through to default computation
      #
      # Override this method to add debug logging or customize behavior.
      #
      # @param node [Object] Node to generate signature for
      # @return [Array, nil] Signature array or nil
      #
      # @example Custom generator with fallthrough
      #   signature_generator = ->(node) {
      #     case node
      #     when MyParser::SpecialNode
      #       [:special, node.name]
      #     else
      #       node  # Return original node for default signature computation
      #     end
      #   }
      def generate_signature(node)
        if signature_generator
          result = signature_generator.call(node)
          case result
          when Array, nil
            return result
          end
          # If result is a node (fallthrough), use it for default computation
          node = result if fallthrough_node?(result)
        end

        compute_node_signature(node)
      end

      # Check if a value represents a fallthrough node (parser node or FreezeNodeBase).
      # Override this method to add custom node type detection for your parser.
      #
      # @param value [Object] The value to check
      # @return [Boolean] true if this is a fallthrough node
      def fallthrough_node?(value)
        value.is_a?(FreezeNodeBase)
      end

      # Compute default signature for a node.
      # This method must be implemented by including classes.
      #
      # @param node [Object] The node to compute signature for
      # @return [Array, nil] Signature array or nil
      # @abstract
      def compute_node_signature(node)
        raise NotImplementedError, "#{self.class} must implement #compute_node_signature"
      end
    end
  end
end
