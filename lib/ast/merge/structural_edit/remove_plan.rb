# frozen_string_literal: true

module Ast
  module Merge
    module StructuralEdit
      # Passive plan for removing a contiguous structural range while preserving
      # exact untouched source and recording which removed comment/layout
      # attachments should be promoted to surviving adjacent owners.
      # :reek:TooManyMethods
      # :reek:MissingSafeMethod
      class RemovePlan
        # :reek:LongParameterList
        # :reek:ControlParameter
        def initialize(source:, remove_start_line:, remove_end_line:, leading_boundary: nil, trailing_boundary: nil, removed_attachments: [], removed_owners: nil, retained_owners: nil, metadata: {}, preserve_removed_trailing_blank_lines: true, **options)
          normalized_removed_attachments = Array(removed_attachments).compact.freeze
          @state = {
            boundaries: {
              leading: leading_boundary,
              trailing: trailing_boundary,
            }.freeze,
            removed_attachments: normalized_removed_attachments,
            removed_owners: normalize_owners(removed_owners || removed_attachment_owners(normalized_removed_attachments)),
            retained_owners: normalize_owners(retained_owners || [leading_boundary&.owner, trailing_boundary&.owner]),
            metadata: metadata.merge(options).freeze,
          }.freeze

          validate_boundaries!
          @splice_plan = SplicePlan.new(
            source: source,
            replacement: "",
            replace_start_line: remove_start_line,
            replace_end_line: remove_end_line,
            leading_boundary: leading_boundary,
            trailing_boundary: trailing_boundary,
            preserve_removed_trailing_blank_lines: preserve_removed_trailing_blank_lines,
            metadata: {source: :structural_edit_remove_plan}.merge(self.metadata),
          )
        end

        def source
          splice_plan.source
        end

        def remove_start_line
          splice_plan.replace_start_line
        end

        def remove_end_line
          splice_plan.replace_end_line
        end

        def line_range
          remove_start_line..remove_end_line
        end

        def leading_boundary
          boundaries[:leading]
        end

        def trailing_boundary
          boundaries[:trailing]
        end

        def removed_attachments
          @state[:removed_attachments]
        end

        def removed_owners
          @state[:removed_owners]
        end

        def retained_owners
          @state[:retained_owners]
        end

        def metadata
          @state[:metadata]
        end

        def before_content
          splice_plan.before_content
        end

        def removed_content
          splice_plan.removed_content
        end

        def after_content
          splice_plan.after_content
        end

        def merged_content
          splice_plan.merged_content
        end

        def changed?
          splice_plan.changed?
        end

        def to_splice_plan
          splice_plan
        end

        def apply_to(alternate_source = source)
          splice_plan.apply_to(alternate_source)
        end

        def rehome_plans
          removed_attachments.flat_map { |attachment| build_rehome_plans_for(attachment) }
        end

        def promoted_comment_regions
          rehome_plans.flat_map(&:comment_regions)
        end

        def promoted_layout_gaps
          rehome_plans.flat_map(&:layout_gaps)
        end

        def inspect
          "#<#{self.class.name} lines=#{remove_start_line}..#{remove_end_line} removed_owners=#{removed_owners.size} rehome_plans=#{rehome_plans.size}>"
        end

        private

        attr_reader :splice_plan

        def build_rehome_plans_for(attachment)
          fragment_specs_for(attachment).filter_map do |fragment_spec|
            rehome_plan_for(attachment, fragment_spec)
          end
        end

        # :reek:NilCheck
        # :reek:FeatureEnvy
        def rehome_plan_for(attachment, fragment_spec)
          target_boundary = fragment_spec[:target_boundary]
          return if target_boundary.nil?

          RehomePlan.new(
            source_owner: attachment_owner(attachment),
            target_boundary: target_boundary,
            comment_regions: fragment_spec[:comment_regions],
            layout_gaps: fragment_spec[:layout_gaps],
            metadata: {source: :structural_edit_remove_plan}.merge(fragment_spec[:metadata]),
          )
        end

        def fragment_specs_for(attachment)
          [
            {
              target_boundary: leading_boundary || trailing_boundary,
              comment_regions: attachment_values(attachment, :leading_region),
              layout_gaps: attachment_values(attachment, :leading_gap),
              metadata: {kind: :leading},
            },
            {
              target_boundary: leading_boundary || trailing_boundary,
              comment_regions: attachment_values(attachment, :inline_region, :orphan_regions),
              layout_gaps: [],
              metadata: {kind: :ambiguous},
            },
            {
              target_boundary: trailing_boundary || leading_boundary,
              comment_regions: attachment_values(attachment, :trailing_region),
              layout_gaps: attachment_values(attachment, :trailing_gap),
              metadata: {kind: :trailing},
            },
          ].reject { |fragment_spec| fragment_spec[:comment_regions].empty? && fragment_spec[:layout_gaps].empty? }
        end

        # :reek:FeatureEnvy
        # :reek:ManualDispatch
        def attachment_values(attachment, *methods)
          methods.flat_map do |method_name|
            next [] unless attachment.respond_to?(method_name)

            Array(attachment.public_send(method_name)).compact
          end
        end

        # :reek:ManualDispatch
        # :reek:UtilityFunction
        def attachment_owner(attachment)
          attachment.respond_to?(:owner) ? attachment.owner : nil
        end

        def removed_attachment_owners(attachments)
          attachments.filter_map { |attachment| attachment_owner(attachment) }
        end

        # :reek:FeatureEnvy
        # :reek:TooManyStatements
        def normalize_owners(owners)
          seen = {}

          Array(owners).compact.each_with_object([]) do |owner, result|
            owner_key = owner.object_id
            next if seen[owner_key]

            seen[owner_key] = true
            result << owner
          end.freeze
        end

        def boundaries
          @state[:boundaries]
        end

        def validate_boundaries!
          if leading_boundary && !leading_boundary.leading?
            raise ArgumentError, "leading_boundary must use edge :leading"
          end

          return unless trailing_boundary && !trailing_boundary.trailing?

          raise ArgumentError, "trailing_boundary must use edge :trailing"
        end
      end
    end
  end
end
