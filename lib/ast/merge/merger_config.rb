# frozen_string_literal: true

module Ast
  module Merge
    # Configuration object for SmartMerger options.
    #
    # This class encapsulates common configuration options used across all
    # *-merge gem SmartMerger implementations. It provides a standardized
    # interface for merge configuration and validates option values.
    #
    # @example Creating a config with defaults
    #   config = MergerConfig.new
    #   config.signature_match_preference  # => :destination
    #   config.add_template_only_nodes     # => false
    #
    # @example Creating a config for template-wins merge
    #   config = MergerConfig.new(
    #     signature_match_preference: :template,
    #     add_template_only_nodes: true
    #   )
    #
    # @example Using with SmartMerger
    #   config = MergerConfig.new(signature_match_preference: :template)
    #   merger = SmartMerger.new(template, dest, **config.to_h)
    class MergerConfig
      # Valid values for signature_match_preference
      VALID_PREFERENCES = %i[destination template].freeze

      # @return [Symbol] Which version to prefer when nodes have matching signatures
      #   - :destination (default) - Keep destination version (preserves customizations)
      #   - :template - Use template version (applies updates)
      attr_reader :signature_match_preference

      # @return [Boolean] Whether to add nodes that only exist in template
      #   - false (default) - Skip template-only nodes
      #   - true - Add template-only nodes to result
      attr_reader :add_template_only_nodes

      # @return [String] Token used for freeze block markers
      attr_reader :freeze_token

      # @return [Proc, nil] Custom signature generator proc
      attr_reader :signature_generator

      # Initialize a new MergerConfig.
      #
      # @param signature_match_preference [Symbol] Which version to prefer on match
      #   (:destination or :template)
      # @param add_template_only_nodes [Boolean] Whether to add template-only nodes
      # @param freeze_token [String, nil] Token for freeze block markers (nil uses gem default)
      # @param signature_generator [Proc, nil] Custom signature generator
      #
      # @raise [ArgumentError] If signature_match_preference is not :destination or :template
      def initialize(
        signature_match_preference: :destination,
        add_template_only_nodes: false,
        freeze_token: nil,
        signature_generator: nil
      )
        validate_preference!(signature_match_preference)

        @signature_match_preference = signature_match_preference
        @add_template_only_nodes = add_template_only_nodes
        @freeze_token = freeze_token
        @signature_generator = signature_generator
      end

      # Check if destination version should be preferred on signature match.
      #
      # @return [Boolean] true if destination preference
      def prefer_destination?
        @signature_match_preference == :destination
      end

      # Check if template version should be preferred on signature match.
      #
      # @return [Boolean] true if template preference
      def prefer_template?
        @signature_match_preference == :template
      end

      # Convert config to a hash suitable for passing to SmartMerger.
      #
      # @param default_freeze_token [String, nil] Default freeze token to use if none specified
      # @return [Hash] Configuration as keyword arguments hash
      def to_h(default_freeze_token: nil)
        result = {
          signature_match_preference: @signature_match_preference,
          add_template_only_nodes: @add_template_only_nodes
        }
        result[:freeze_token] = @freeze_token || default_freeze_token if @freeze_token || default_freeze_token
        result[:signature_generator] = @signature_generator if @signature_generator
        result
      end

      # Create a new config with updated values.
      #
      # @param options [Hash] Options to override
      # @return [MergerConfig] New config with updated values
      def with(**options)
        self.class.new(
          signature_match_preference: options.fetch(:signature_match_preference, @signature_match_preference),
          add_template_only_nodes: options.fetch(:add_template_only_nodes, @add_template_only_nodes),
          freeze_token: options.fetch(:freeze_token, @freeze_token),
          signature_generator: options.fetch(:signature_generator, @signature_generator)
        )
      end

      # Create a config preset for "destination wins" merging.
      # Destination customizations are preserved, template-only content is skipped.
      #
      # @param freeze_token [String, nil] Optional freeze token
      # @param signature_generator [Proc, nil] Optional signature generator
      # @return [MergerConfig] Config preset
      def self.destination_wins(freeze_token: nil, signature_generator: nil)
        new(
          signature_match_preference: :destination,
          add_template_only_nodes: false,
          freeze_token: freeze_token,
          signature_generator: signature_generator
        )
      end

      # Create a config preset for "template wins" merging.
      # Template updates are applied, template-only content is added.
      #
      # @param freeze_token [String, nil] Optional freeze token
      # @param signature_generator [Proc, nil] Optional signature generator
      # @return [MergerConfig] Config preset
      def self.template_wins(freeze_token: nil, signature_generator: nil)
        new(
          signature_match_preference: :template,
          add_template_only_nodes: true,
          freeze_token: freeze_token,
          signature_generator: signature_generator
        )
      end

      private

      def validate_preference!(preference)
        return if VALID_PREFERENCES.include?(preference)

        raise ArgumentError,
              "Invalid signature_match_preference: #{preference.inspect}. " \
              "Must be one of: #{VALID_PREFERENCES.map(&:inspect).join(", ")}"
      end
    end
  end
end
