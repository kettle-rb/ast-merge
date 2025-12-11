# frozen_string_literal: true

require_relative "freezable"

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

      # Get all freeze blocks/nodes from statements.
      # Includes both traditional FreezeNodeBase blocks and Freezable-wrapped nodes.
      #
      # @return [Array<Freezable>] All freeze nodes
      def freeze_blocks
        statements.select { |node| node.is_a?(Freezable) }
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
        result = if signature_generator
          custom_result = signature_generator.call(node)
          case custom_result
          when Array, nil
            # Custom result is either an array signature or nil
            custom_result
          else
            # Check for fallthrough nodes (parser-specific nodes, NodeTyping::Wrapper, etc.)
            if fallthrough_node?(custom_result)
              # Unwrap NodeTyping::Wrapper to get the underlying node for signature generation
              # (Wrappers include the full node which would cause signature mismatches)
              actual_node = custom_result.respond_to?(:unwrap) ? custom_result.unwrap : custom_result
              compute_node_signature(actual_node)
            else
              # Unknown result type - return as-is (shouldn't happen)
              custom_result
            end
          end
        else
          compute_node_signature(node)
        end

        DebugLogger.debug("Generated signature", {
          node_type: node.class.name.split("::").last,
          signature: result,
          generator: signature_generator ? "custom" : "default",
        }) if result

        result
      end

      # Check if a value represents a fallthrough node that should be used for
      # default signature computation.
      #
      # When a signature_generator returns a non-Array/nil value, we check if it's
      # a "fallthrough" node that should be passed to compute_node_signature.
      # This includes:
      # - Freezable nodes (frozen wrappers)
      # - FreezeNodeBase instances
      # - NodeTyping::Wrapper instances (unwrapped to get the underlying node)
      #
      # Override this method to add custom node type detection for your parser.
      #
      # @param value [Object] The value to check
      # @return [Boolean] true if this is a fallthrough node
      def fallthrough_node?(value)
        value.is_a?(Freezable) || value.is_a?(FreezeNodeBase) || value.is_a?(NodeTyping::Wrapper)
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
