# frozen_string_literal: true

module Ast
  module Merge
    module StructuralEdit
      # Passive metadata for promoting preserved comment/layout fragments from a
      # removed owner to a surviving adjacent boundary owner.
      #
      # A rehome plan does not mutate attachments in place. It captures which
      # fragments should survive a removal and how they should be re-exposed on
      # the surviving side so emitters / downstream mergers can adopt the shared
      # contract incrementally.
      class RehomePlan
        # :reek:LongParameterList
        def initialize(source_owner: nil, target_boundary:, comment_regions: [], layout_gaps: [], metadata: {}, **options)
          raise ArgumentError, "target_boundary is required" unless target_boundary

          @state = {
            source_owner: source_owner,
            target_boundary: target_boundary,
            comment_regions: Array(comment_regions).compact.freeze,
            layout_gaps: Array(layout_gaps).compact.freeze,
            metadata: metadata.merge(options).freeze,
          }.freeze
        end

        def source_owner
          @state[:source_owner]
        end

        def target_boundary
          @state[:target_boundary]
        end

        def comment_regions
          @state[:comment_regions]
        end

        def layout_gaps
          @state[:layout_gaps]
        end

        def metadata
          @state[:metadata]
        end

        def target_owner
          target_boundary.owner
        end

        def edge
          target_boundary.edge
        end

        def leading?
          target_boundary.leading?
        end

        def trailing?
          target_boundary.trailing?
        end

        def empty?
          comment_regions.empty? && layout_gaps.empty?
        end

        def comment_attachment
          primary_region, *orphan_regions = comment_regions
          options = {
            owner: target_owner,
            orphan_regions: orphan_regions,
            metadata: {source: :structural_edit_rehome_plan}.merge(metadata),
          }

          if leading?
            Ast::Merge::Comment::Attachment.new(**options, trailing_region: primary_region)
          else
            Ast::Merge::Comment::Attachment.new(**options, leading_region: primary_region)
          end
        end

        def layout_attachment
          primary_gap = layout_gaps.first
          options = {
            owner: target_owner,
            metadata: {source: :structural_edit_rehome_plan}.merge(metadata),
          }

          if leading?
            Ast::Merge::Layout::Attachment.new(**options, trailing_gap: primary_gap)
          else
            Ast::Merge::Layout::Attachment.new(**options, leading_gap: primary_gap)
          end
        end

        def inspect
          "#<#{self.class.name} edge=#{edge.inspect} target_owner=#{target_owner.class.name if target_owner} comment_regions=#{comment_regions.size} layout_gaps=#{layout_gaps.size}>"
        end
      end
    end
  end
end
