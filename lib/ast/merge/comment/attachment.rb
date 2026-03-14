# frozen_string_literal: true

module Ast
  module Merge
    module Comment
      # A passive per-node container for comment regions associated with a
      # structural AST node.
      #
      # This does not yet impose merge policy. It simply normalizes how merge
      # gems can describe leading, inline, trailing, and orphan comment regions
      # around a structural owner node.
      class Attachment
        attr_reader :owner, :leading_region, :inline_region, :trailing_region, :orphan_regions, :metadata

        def initialize(owner: nil, leading_region: nil, inline_region: nil, trailing_region: nil, orphan_regions: [], metadata: {}, **options)
          @owner = owner
          @leading_region = leading_region
          @inline_region = inline_region
          @trailing_region = trailing_region
          @orphan_regions = Array(orphan_regions).freeze
          @metadata = metadata.merge(options).freeze
        end

        def regions
          [leading_region, inline_region, trailing_region, *orphan_regions].compact
        end

        def empty?
          regions.empty?
        end

        def leading_freeze?(freeze_token)
          leading_region.respond_to?(:freeze?) && leading_region.freeze?(freeze_token)
        end

        def leading_unfreeze?(freeze_token)
          leading_region.respond_to?(:unfreeze?) && leading_region.unfreeze?(freeze_token)
        end

        def freeze?(freeze_token)
          regions.any? { |region| region.respond_to?(:freeze?) && region.freeze?(freeze_token) }
        end

        def unfreeze?(freeze_token)
          regions.any? { |region| region.respond_to?(:unfreeze?) && region.unfreeze?(freeze_token) }
        end

        def freeze_marker?(freeze_token)
          freeze?(freeze_token) || unfreeze?(freeze_token)
        end

        def inspect
          owner_desc = if owner && owner.respond_to?(:type)
            owner.method(:type).call
          elsif owner.nil?
            nil
          else
            owner.class.name
          end

          "#<#{self.class.name} owner=#{owner_desc.inspect} regions=#{regions.size}>"
        end
      end
    end
  end
end
