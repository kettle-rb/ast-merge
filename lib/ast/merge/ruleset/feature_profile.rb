# frozen_string_literal: true

module Ast
  module Merge
    module Ruleset
      # Shared value object describing a merge implementation or ruleset surface
      # using spec-aligned feature terminology.
      class FeatureProfile
        attr_reader :owner_selector,
          :match_key,
          :read_strategy,
          :attachment_strategy,
          :comment_style,
          :render_family,
          :comment_capability,
          :support_style,
          :capabilities,
          :logical_owners,
          :metadata

        def initialize(
          owner_selector:,
          match_key:,
          read_strategy: nil,
          attachment_strategy: nil,
          comment_style: nil,
          render_family: nil,
          comment_capability: nil,
          support_style: nil,
          capabilities: {},
          logical_owners: {},
          metadata: {}
        )
          @owner_selector = owner_selector&.to_sym
          @match_key = match_key&.to_sym
          @read_strategy = read_strategy&.to_sym
          @attachment_strategy = attachment_strategy&.to_sym
          @comment_style = comment_style&.to_sym
          @render_family = render_family&.to_sym
          @comment_capability = comment_capability
          @support_style = support_style
          @capabilities = capabilities.dup.freeze
          @logical_owners = logical_owners.dup.freeze
          @metadata = metadata.dup.freeze
        end

        def layout_aware?
          capabilities.fetch(:layout_aware, false)
        end

        def logical_owner?
          capabilities.fetch(:logical_owner, logical_owners.any?)
        end

        def comment_aware?
          if support_style.respond_to?(:available?)
            support_style.available?
          elsif comment_capability.respond_to?(:available?)
            comment_capability.available?
          else
            false
          end
        end

        def structural_only?
          !layout_aware? && !comment_aware? && !logical_owner?
        end

        def to_h
          {
            owner_selector: owner_selector,
            match_key: match_key,
            read_strategy: read_strategy,
            attachment_strategy: attachment_strategy,
            comment_style: comment_style,
            render_family: render_family,
            comment_capability: comment_capability&.to_h,
            support_style: support_style&.to_h,
            capabilities: capabilities,
            logical_owners: logical_owners,
            metadata: metadata,
            layout_aware: layout_aware?,
            logical_owner: logical_owner?,
            comment_aware: comment_aware?,
            structural_only: structural_only?,
          }.compact
        end
      end
    end
  end
end
