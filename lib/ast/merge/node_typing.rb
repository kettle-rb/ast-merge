# frozen_string_literal: true

module Ast
  module Merge
    # Provides node type wrapping support for SmartMerger implementations.
    #
    # NodeTyping allows custom callable objects to be associated with specific
    # node types. When a node is processed, the corresponding callable can:
    # - Return the node unchanged (passthrough)
    # - Return a modified node with a custom `merge_type` attribute
    # - Return nil to indicate the node should be skipped
    #
    # The `merge_type` attribute can then be used by other merge tools like
    # `signature_generator`, `match_refiner`, and per-node-type `preference` settings.
    #
    # @example Basic node typing for different gem types
    #   node_typing = {
    #     CallNode: ->(node) {
    #       return node unless node.name == :gem
    #       first_arg = node.arguments&.arguments&.first
    #       return node unless first_arg.is_a?(StringNode)
    #
    #       gem_name = first_arg.unescaped
    #       if gem_name.start_with?("rubocop")
    #         NodeTyping.with_merge_type(node, :lint_gem)
    #       elsif gem_name.start_with?("rspec")
    #         NodeTyping.with_merge_type(node, :test_gem)
    #       else
    #         node
    #       end
    #     }
    #   }
    #
    # @example Using with per-node-type preference
    #   merger = SmartMerger.new(
    #     template,
    #     destination,
    #     node_typing: node_typing,
    #     preference: {
    #       default: :destination,
    #       lint_gem: :template,  # Use template versions for lint gems
    #       test_gem: :destination  # Keep destination versions for test gems
    #     }
    #   )
    #
    # @see MergerConfig
    # @see ConflictResolverBase
    module NodeTyping
      # Node wrapper that adds a merge_type attribute to an existing node.
      # This uses a simple delegation pattern to preserve all original node
      # behavior while adding the merge_type.
      class Wrapper
        # @return [Object] The original node being wrapped
        attr_reader :node

        # @return [Symbol] The custom merge type for this node
        attr_reader :merge_type

        # Create a new node type wrapper.
        #
        # @param node [Object] The original node to wrap
        # @param merge_type [Symbol] The custom merge type
        def initialize(node, merge_type)
          @node = node
          @merge_type = merge_type
        end

        # Delegate all unknown methods to the wrapped node.
        # This allows the wrapper to be used transparently in place of the node.
        def method_missing(method, *args, &block)
          if @node.respond_to?(method)
            @node.send(method, *args, &block)
          else
            super
          end
        end

        # Check if the wrapped node responds to a method.
        def respond_to_missing?(method, include_private = false)
          @node.respond_to?(method, include_private) || super
        end

        # Returns true to indicate this is a node type wrapper.
        def typed_node?
          true
        end

        # Unwrap to get the original node.
        # @return [Object] The original unwrapped node
        def unwrap
          @node
        end

        # Forward equality check to the wrapped node.
        def ==(other)
          if other.is_a?(Wrapper)
            @node == other.node && @merge_type == other.merge_type
          else
            @node == other
          end
        end

        # Forward hash to the wrapped node.
        def hash
          [@node, @merge_type].hash
        end

        # Forward eql? to the wrapped node.
        def eql?(other)
          self == other
        end

        # Forward inspect to show both the type and node.
        def inspect
          "#<NodeTyping::Wrapper merge_type=#{@merge_type.inspect} node=#{@node.inspect}>"
        end
      end

      # Wrapper for frozen AST nodes that includes Freezable behavior.
      #
      # FrozenWrapper extends Wrapper to add freeze node semantics, making the
      # wrapped node satisfy both the NodeTyping API and the Freezable API.
      # This enables composition where frozen nodes are:
      # - Wrapped AST nodes (can unwrap to get original)
      # - Typed nodes (have merge_type)
      # - Freeze nodes (satisfy is_a?(Freezable) and freeze_node?)
      #
      # ## Key Distinction from FreezeNodeBase
      #
      # FrozenWrapper and FreezeNodeBase both include Freezable, but they represent
      # fundamentally different concepts:
      #
      # ### FrozenWrapper (this class)
      # - Wraps an AST node that has a freeze marker in its leading comments
      # - The node is still a structural AST node (e.g., a `gem` call in a gemspec)
      # - During matching, we want to match by the underlying node's IDENTITY
      #   (e.g., the gem name), NOT by the full content
      # - Signature generation should unwrap and use the underlying node's structure
      # - Example: `# token:freeze\ngem "example_gem", "~> 1.0"` wraps a CallNode
      #
      # ### FreezeNodeBase
      # - Represents an explicit freeze block with `# token:freeze ... # token:unfreeze`
      # - The entire block is opaque content that should be preserved verbatim
      # - During matching, we match by the full CONTENT of the block
      # - Signature generation uses freeze_signature (content-based)
      # - Example: A multi-line comment block with custom formatting
      #
      # ## Signature Generation Behavior
      #
      # When FileAnalyzable#generate_signature encounters a FrozenWrapper:
      # 1. It unwraps to get the underlying AST node
      # 2. Passes the unwrapped node to the signature_generator
      # 3. This allows the signature generator to recognize the node type
      #    (e.g., Prism::CallNode) and generate appropriate signatures
      #
      # This is critical because signature generators check for specific AST types.
      # If we passed the wrapper, the generator wouldn't recognize it as a CallNode
      # and would fall back to a generic signature, breaking matching.
      #
      # @example Creating a frozen wrapper
      #   frozen = NodeTyping::FrozenWrapper.new(prism_node, :frozen)
      #   frozen.freeze_node?  # => true
      #   frozen.is_a?(Ast::Merge::Freezable)  # => true
      #   frozen.unwrap  # => prism_node
      #
      # @see Wrapper
      # @see Ast::Merge::Freezable
      # @see FreezeNodeBase
      # @see FileAnalyzable#generate_signature
      class FrozenWrapper < Wrapper
        include Ast::Merge::Freezable

        # Create a frozen wrapper for an AST node.
        #
        # @param node [Object] The AST node to wrap
        # @param merge_type [Symbol] The merge type (defaults to :frozen)
        def initialize(node, merge_type = :frozen)
          super(node, merge_type)
        end

        # Returns true to indicate this is a frozen node.
        # Overrides both Wrapper#typed_node? context and provides freeze_node? from Freezable.
        #
        # @return [Boolean] true
        def frozen_node?
          true
        end

        # Returns the content of this frozen node.
        # Delegates to the wrapped node's slice method.
        #
        # @return [String] The node content
        def slice
          @node.slice
        end

        # Returns the signature for this frozen node.
        # Uses the freeze_signature from Freezable module.
        #
        # @return [Array] Signature in the form [:FreezeNode, content]
        def signature
          freeze_signature
        end

        # Forward inspect to show frozen status.
        def inspect
          "#<NodeTyping::FrozenWrapper merge_type=#{@merge_type.inspect} node=#{@node.inspect}>"
        end
      end

      class << self
        # Wrap a node with a custom merge_type.
        #
        # @param node [Object] The node to wrap
        # @param merge_type [Symbol] The merge type to assign
        # @return [Wrapper] The wrapped node
        #
        # @example
        #   typed_node = NodeTyping.with_merge_type(call_node, :config_call)
        #   typed_node.merge_type  # => :config_call
        #   typed_node.name        # => delegates to call_node.name
        def with_merge_type(node, merge_type)
          Wrapper.new(node, merge_type)
        end

        # Wrap a node as frozen with the Freezable behavior.
        #
        # @param node [Object] The node to wrap as frozen
        # @param merge_type [Symbol] The merge type (defaults to :frozen)
        # @return [FrozenWrapper] The frozen wrapped node
        #
        # @example
        #   frozen_node = NodeTyping.frozen(call_node)
        #   frozen_node.freeze_node?  # => true
        #   frozen_node.is_a?(Ast::Merge::Freezable)  # => true
        def frozen(node, merge_type = :frozen)
          FrozenWrapper.new(node, merge_type)
        end

        # Check if a node is a frozen wrapper.
        #
        # @param node [Object] The node to check
        # @return [Boolean] true if the node is a FrozenWrapper or includes Freezable
        def frozen_node?(node)
          node.is_a?(Freezable)
        end

        # Check if a node is a node type wrapper.
        #
        # @param node [Object] The node to check
        # @return [Boolean] true if the node is a Wrapper
        def typed_node?(node)
          node.respond_to?(:typed_node?) && node.typed_node?
        end

        # Get the merge_type from a node, returning nil if it's not a typed node.
        #
        # @param node [Object] The node to get merge_type from
        # @return [Symbol, nil] The merge_type or nil
        def merge_type_for(node)
          typed_node?(node) ? node.merge_type : nil
        end

        # Unwrap a typed node to get the original node.
        # Returns the node unchanged if it's not wrapped.
        #
        # @param node [Object] The node to unwrap
        # @return [Object] The unwrapped node
        def unwrap(node)
          typed_node?(node) ? node.unwrap : node
        end

        # Process a node through a typing configuration.
        #
        # @param node [Object] The node to process
        # @param typing_config [Hash{Symbol,String => #call}, nil] Hash mapping node type names
        #   to callables. Keys can be symbols or strings representing node class names
        #   (e.g., :CallNode, "DefNode", :Prism_CallNode for fully qualified names)
        # @return [Object, nil] The processed node (possibly wrapped with merge_type),
        #   or nil if the node should be skipped
        #
        # @example
        #   config = {
        #     CallNode: ->(node) {
        #       NodeTyping.with_merge_type(node, :special_call)
        #     }
        #   }
        #   result = NodeTyping.process(call_node, config)
        def process(node, typing_config)
          return node unless typing_config
          return node if typing_config.empty?

          # Get the node type name for lookup
          type_key = node_type_key(node)

          # Try to find a matching typing callable
          callable = find_typing_callable(typing_config, type_key, node)
          return node unless callable

          # Call the typing callable with the node
          callable.call(node)
        end

        # Validate a typing configuration hash.
        #
        # @param typing_config [Hash, nil] The configuration to validate
        # @raise [ArgumentError] If the configuration is invalid
        # @return [void]
        def validate!(typing_config)
          return if typing_config.nil?

          unless typing_config.is_a?(Hash)
            raise ArgumentError, "node_typing must be a Hash, got #{typing_config.class}"
          end

          typing_config.each do |key, value|
            unless key.is_a?(Symbol) || key.is_a?(String)
              raise ArgumentError,
                "node_typing keys must be Symbol or String, got #{key.class} for #{key.inspect}"
            end

            unless value.respond_to?(:call)
              raise ArgumentError,
                "node_typing values must be callable (respond to #call), " \
                  "got #{value.class} for key #{key.inspect}"
            end
          end
        end

        private

        # Get the type key for looking up a typing callable.
        # Handles both simple class names and fully-qualified names.
        #
        # @param node [Object] The node to get the type key for
        # @return [String] The type key
        def node_type_key(node)
          # Handle Wrapper - use the wrapped node's class
          actual_node = typed_node?(node) ? node.unwrap : node
          actual_node.class.name&.split("::")&.last || actual_node.class.to_s
        end

        # Find a typing callable for the given type key.
        #
        # @param config [Hash] The typing configuration
        # @param type_key [String] The type key to look up
        # @param node [Object] The original node (for fully-qualified lookup)
        # @return [#call, nil] The typing callable or nil
        def find_typing_callable(config, type_key, node)
          # Try exact match with symbol key
          return config[type_key.to_sym] if config.key?(type_key.to_sym)

          # Try exact match with string key
          return config[type_key] if config.key?(type_key)

          # Try fully-qualified class name (e.g., "Prism::CallNode")
          actual_node = typed_node?(node) ? node.unwrap : node
          full_name = actual_node.class.name
          return config[full_name.to_sym] if full_name && config.key?(full_name.to_sym)
          return config[full_name] if full_name && config.key?(full_name)

          # Try with underscored naming (e.g., :prism_call_node)
          underscored = full_name&.gsub("::", "_")&.gsub(/([a-z])([A-Z])/, '\1_\2')&.downcase
          return config[underscored&.to_sym] if underscored && config.key?(underscored.to_sym)

          nil
        end
      end
    end
  end
end
