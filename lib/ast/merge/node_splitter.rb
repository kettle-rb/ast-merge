# frozen_string_literal: true

module Ast
  module Merge
    # Provides node transformation support for SmartMerger implementations.
    #
    # NodeSplitter allows custom callable objects to be associated with specific
    # node types. When a node is processed, the corresponding callable can:
    # - Return the node unchanged (passthrough)
    # - Return a modified node with a custom `merge_type` attribute
    # - Return nil to indicate the node should be skipped
    #
    # The `merge_type` attribute can then be used by other merge tools like
    # `signature_generator`, `match_refiner`, and per-node-type `preference` settings.
    #
    # @example Basic node splitting for different gem types
    #   node_splitter = {
    #     CallNode: ->(node) {
    #       return node unless node.name == :gem
    #       first_arg = node.arguments&.arguments&.first
    #       return node unless first_arg.is_a?(StringNode)
    #       
    #       gem_name = first_arg.unescaped
    #       if gem_name.start_with?("rubocop")
    #         NodeSplitter.with_merge_type(node, :lint_gem)
    #       elsif gem_name.start_with?("rspec")
    #         NodeSplitter.with_merge_type(node, :test_gem)
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
    #     node_splitter: node_splitter,
    #     preference: {
    #       default: :destination,
    #       lint_gem: :template,  # Use template versions for lint gems
    #       test_gem: :destination  # Keep destination versions for test gems
    #     }
    #   )
    #
    # @see MergerConfig
    # @see ConflictResolverBase
    module NodeSplitter
      # Node wrapper that adds a merge_type attribute to an existing node.
      # This uses a simple delegation pattern to preserve all original node
      # behavior while adding the merge_type.
      class TypedNodeWrapper
        # @return [Object] The original node being wrapped
        attr_reader :node

        # @return [Symbol] The custom merge type for this node
        attr_reader :merge_type

        # Create a new typed node wrapper.
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

        # Returns true to indicate this is a typed node wrapper.
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
          if other.is_a?(TypedNodeWrapper)
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
          "#<TypedNodeWrapper merge_type=#{@merge_type.inspect} node=#{@node.inspect}>"
        end
      end

      class << self
        # Wrap a node with a custom merge_type.
        #
        # @param node [Object] The node to wrap
        # @param merge_type [Symbol] The merge type to assign
        # @return [TypedNodeWrapper] The wrapped node
        #
        # @example
        #   typed_node = NodeSplitter.with_merge_type(call_node, :config_call)
        #   typed_node.merge_type  # => :config_call
        #   typed_node.name        # => delegates to call_node.name
        def with_merge_type(node, merge_type)
          TypedNodeWrapper.new(node, merge_type)
        end

        # Check if a node is a typed node wrapper.
        #
        # @param node [Object] The node to check
        # @return [Boolean] true if the node is a TypedNodeWrapper
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

        # Process a node through a splitter configuration.
        #
        # @param node [Object] The node to process
        # @param splitter_config [Hash{Symbol,String => #call}, nil] Hash mapping node type names
        #   to callables. Keys can be symbols or strings representing node class names
        #   (e.g., :CallNode, "DefNode", :Prism_CallNode for fully qualified names)
        # @return [Object, nil] The processed node (possibly wrapped with merge_type),
        #   or nil if the node should be skipped
        #
        # @example
        #   config = {
        #     CallNode: ->(node) { 
        #       NodeSplitter.with_merge_type(node, :special_call) 
        #     }
        #   }
        #   result = NodeSplitter.process(call_node, config)
        def process(node, splitter_config)
          return node unless splitter_config
          return node if splitter_config.empty?

          # Get the node type name for lookup
          type_key = node_type_key(node)

          # Try to find a matching splitter
          callable = find_splitter(splitter_config, type_key, node)
          return node unless callable

          # Call the splitter with the node
          callable.call(node)
        end

        # Validate a splitter configuration hash.
        #
        # @param splitter_config [Hash, nil] The configuration to validate
        # @raise [ArgumentError] If the configuration is invalid
        # @return [void]
        def validate!(splitter_config)
          return if splitter_config.nil?

          unless splitter_config.is_a?(Hash)
            raise ArgumentError, "node_splitter must be a Hash, got #{splitter_config.class}"
          end

          splitter_config.each do |key, value|
            unless key.is_a?(Symbol) || key.is_a?(String)
              raise ArgumentError,
                    "node_splitter keys must be Symbol or String, got #{key.class} for #{key.inspect}"
            end

            unless value.respond_to?(:call)
              raise ArgumentError,
                    "node_splitter values must be callable (respond to #call), " \
                    "got #{value.class} for key #{key.inspect}"
            end
          end
        end

        private

        # Get the type key for looking up a splitter.
        # Handles both simple class names and fully-qualified names.
        #
        # @param node [Object] The node to get the type key for
        # @return [String] The type key
        def node_type_key(node)
          # Handle TypedNodeWrapper - use the wrapped node's class
          actual_node = typed_node?(node) ? node.unwrap : node
          actual_node.class.name&.split("::")&.last || actual_node.class.to_s
        end

        # Find a splitter for the given type key.
        #
        # @param config [Hash] The splitter configuration
        # @param type_key [String] The type key to look up
        # @param node [Object] The original node (for fully-qualified lookup)
        # @return [#call, nil] The splitter callable or nil
        def find_splitter(config, type_key, node)
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
