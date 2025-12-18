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
      class << self
        def included(base)
          base.class_eval do
            attr_reader(:source, :lines, :freeze_token, :signature_generator)
          end
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
        return if index < 0 || index >= statements.length

        generate_signature(statements[index])
      end

      # Get a specific line (1-indexed).
      #
      # @param line_num [Integer] Line number (1-indexed)
      # @return [String, nil] The line content or nil if out of bounds
      def line_at(line_num)
        return if line_num < 1

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
      # Signatures are used to match nodes between template and destination files.
      # Two nodes with the same signature are considered "the same" for merge purposes,
      # allowing the merger to decide which version to keep based on preference settings.
      #
      # ## Signature Generation Flow
      #
      # 1. **FreezeNodeBase** (explicit freeze blocks like `# token:freeze ... # token:unfreeze`):
      #    Uses content-based signature via `freeze_signature`. This ensures explicit freeze
      #    blocks match between files based on their actual content.
      #
      # 2. **FrozenWrapper** (AST nodes with freeze markers in leading comments):
      #    The wrapper is **unwrapped first** to get the underlying AST node. The signature
      #    is then generated from the underlying node, NOT the wrapper. This is critical
      #    because the freeze marker only affects merge *preference* (destination wins),
      #    not *matching*. Two nodes should match by their structural identity even if
      #    their content differs slightly.
      #
      # 3. **Custom signature_generator**: If provided, receives the unwrapped node and can:
      #    - Return an Array signature (e.g., `[:gem, "foo"]`) - used directly
      #    - Return `nil` - node gets no signature, won't be matched
      #    - Return the node (fallthrough) - default signature computation is used
      #
      # 4. **Default computation**: Falls through to `compute_node_signature` for
      #    parser-specific default signature generation.
      #
      # ## Why FrozenWrapper Must Be Unwrapped
      #
      # Consider a gemspec with a frozen `gem_version` variable:
      #
      #   Template:                         Destination:
      #   # kettle-dev:freeze               # kettle-dev:freeze
      #   # Comment                         # Comment
      #   # kettle-dev:unfreeze             # More comments
      #   gem_version = "1.0"               # kettle-dev:unfreeze
      #                                     gem_version = "1.0"
      #
      # Both have a `gem_version` assignment with a freeze marker in leading comments.
      # The assignments are wrapped in FrozenWrapper, but their CONTENT differs
      # (template has fewer comments in the freeze block).
      #
      # If we generated signatures from the wrapper (which delegates `slice` to the
      # full node content), they would NOT match and both would be output - duplicating
      # the freeze block!
      #
      # By unwrapping first, we generate signatures from the underlying
      # `LocalVariableWriteNode`, which matches by variable name (`gem_version`),
      # ensuring only ONE version is output (the destination version, since it's frozen).
      #
      # @param node [Object] Node to generate signature for (may be wrapped)
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
      #
      # @see FreezeNodeBase#freeze_signature
      # @see NodeTyping::FrozenWrapper
      # @see Freezable
      def generate_signature(node)
        # ==========================================================================
        # CASE 1: FreezeNodeBase (explicit freeze blocks)
        # ==========================================================================
        # FreezeNodeBase represents an explicit freeze block delimited by markers:
        #   # token:freeze
        #   ... content ...
        #   # token:unfreeze
        #
        # These are standalone structural elements (not attached to AST nodes).
        # They use content-based signatures so identical freeze blocks match.
        # This is different from FrozenWrapper which wraps AST nodes.
        if node.is_a?(FreezeNodeBase)
          return node.freeze_signature
        end

        # ==========================================================================
        # CASE 2: Unwrap FrozenWrapper (and other wrappers)
        # ==========================================================================
        # FrozenWrapper wraps AST nodes that have freeze markers in their leading
        # comments. The wrapper marks the node as "frozen" (prefer destination),
        # but for MATCHING purposes, we need the underlying node's identity.
        #
        # Example: A `gem_version = ...` assignment wrapped in FrozenWrapper should
        # match another `gem_version = ...` assignment by variable name, not by
        # the full content of the assignment (which may differ).
        #
        # CRITICAL: We must unwrap BEFORE calling the signature_generator so it
        # receives the actual AST node type (e.g., Prism::LocalVariableWriteNode)
        # rather than the wrapper (FrozenWrapper). Otherwise, type-based signature
        # generators (like kettle-jem's gemspec generator) won't recognize the node
        # and will fall through to default handling incorrectly.
        actual_node = node.respond_to?(:unwrap) ? node.unwrap : node

        result = if signature_generator
          # ==========================================================================
          # CASE 3: Custom signature generator
          # ==========================================================================
          # Pass the UNWRAPPED node to the custom generator. This ensures:
          # - Type checks work (e.g., `node.is_a?(Prism::CallNode)`)
          # - The generator sees the real AST structure
          # - Frozen nodes match by their underlying identity
          custom_result = signature_generator.call(actual_node)
          case custom_result
          when Array, nil
            # Generator returned a final signature or nil - use as-is
            custom_result
          else
            # Generator returned a node (fallthrough) - compute default signature
            if fallthrough_node?(custom_result)
              # Special case: if fallthrough result is Freezable, use freeze_signature
              # This handles cases where the generator wraps a node in Freezable
              if custom_result.is_a?(Freezable)
                custom_result.freeze_signature
              else
                # Unwrap any wrapper and compute default signature
                unwrapped = custom_result.respond_to?(:unwrap) ? custom_result.unwrap : custom_result
                compute_node_signature(unwrapped)
              end
            else
              # Non-node return value - pass through (allows arbitrary signature types)
              custom_result
            end
          end
        else
          # ==========================================================================
          # CASE 4: No custom generator - use default computation
          # ==========================================================================
          # Pass the UNWRAPPED node to compute_node_signature. This is critical
          # because compute_node_signature uses type checking (e.g., case statements
          # matching Prism::DefNode, Prism::CallNode, etc.). If we pass a
          # FrozenWrapper, it won't match any of those types and will fall through
          # to a generic handler, producing incorrect signatures.
          #
          # For FrozenWrapper nodes, the underlying AST node determines the signature
          # (e.g., method name for DefNode, gem name for CallNode). The wrapper only
          # affects merge preference (destination wins), not matching.
          compute_node_signature(actual_node)
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
      # - AstNode instances (custom AST nodes like Comment::Line)
      # - Freezable nodes (frozen wrappers)
      # - FreezeNodeBase instances
      # - NodeTyping::Wrapper instances (unwrapped to get the underlying node)
      #
      # Override this method to add custom node type detection for your parser.
      #
      # @param value [Object] The value to check
      # @return [Boolean] true if this is a fallthrough node
      def fallthrough_node?(value)
        value.is_a?(AstNode) ||
          value.is_a?(Freezable) ||
          value.is_a?(FreezeNodeBase) ||
          value.is_a?(NodeTyping::Wrapper)
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
