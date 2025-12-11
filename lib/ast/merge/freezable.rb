# frozen_string_literal: true

module Ast
  module Merge
    # Mixin module that provides freeze node behavior.
    #
    # This module can be included in any class to make it behave as a frozen node
    # for merge operations. It provides the core API that identifies a node as frozen
    # and allows it to participate in freeze-aware merging.
    #
    # The primary use cases are:
    # 1. Included by FreezeNodeBase for traditional freeze block nodes
    # 2. Included by NodeTyping::FrozenWrapper for wrapping AST nodes with freeze markers
    #
    # @example Checking if something is freezable
    #   if node.is_a?(Ast::Merge::Freezable)
    #     # Node will be preserved during merge
    #   end
    #
    # @example Including in a custom class
    #   class MyFrozenNode
    #     include Ast::Merge::Freezable
    #
    #     def slice
    #       @content
    #     end
    #   end
    #
    # @see FreezeNodeBase
    # @see NodeTyping::FrozenWrapper
    module Freezable
      # Check if this is a freeze node.
      # Always returns true for classes that include this module.
      #
      # @return [Boolean] true
      def freeze_node?
        true
      end

      # Returns a stable signature for this freeze node.
      # The signature uses the content to allow matching freeze blocks
      # between template and destination.
      #
      # Subclasses can override this for custom signature behavior.
      #
      # @return [Array] Signature array in the form [:FreezeNode, content]
      def freeze_signature
        [:FreezeNode, slice&.strip]
      end

      # Returns the content of this freeze node.
      # Must be implemented by including classes.
      #
      # @return [String] The frozen content
      # @abstract
      def slice
        raise NotImplementedError, "#{self.class} must implement #slice"
      end
    end
  end
end
