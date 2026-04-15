# frozen_string_literal: true

module Ast
  module Merge
    module Runtime
      # Aggregates operations and frames for one top-level merge session.
      class Session
        attr_reader :policy_context, :metadata, :delegation_registry

        def initialize(policy_context: {}, metadata: {}, delegation_registry: DelegationRegistry.new)
          @policy_context = policy_context.dup.freeze
          @metadata = metadata.dup.freeze
          @delegation_registry = delegation_registry
          @operations_by_id = {}
          @frames_by_operation_id = {}
        end

        def register(operation, frame:, delegate: nil)
          @operations_by_id[operation.operation_id] = operation
          @frames_by_operation_id[operation.operation_id] = frame
          operation.assign_delegate!(delegate) if delegate
          operation
        end

        def operation(operation_id)
          @operations_by_id[operation_id]
        end

        def frame_for(operation_id)
          @frames_by_operation_id[operation_id]
        end

        def operations
          @operations_by_id.values
        end

        def diagnostics
          operations.flat_map(&:diagnostics)
        end

        def root_operations
          operations.select do |operation|
            frame = frame_for(operation.operation_id)
            frame&.root?
          end
        end

        def resolve_delegate_for(surface, capability: nil)
          delegation_registry.resolve(surface, capability: capability)
        end

        def summary
          {
            operation_count: operations.size,
            root_operation_count: root_operations.size,
            status_counts: tally_by(operations, &:status),
            diagnostic_count: diagnostics.size,
            diagnostic_severity_counts: tally_by(diagnostics, &:severity),
            delegate_names: normalized_values(operations.map(&:delegate_name)),
            surface_kinds: normalized_values(operations.filter_map { |operation| operation.surface&.surface_kind }),
            effective_languages: normalized_values(operations.filter_map { |operation| operation.surface&.effective_language }),
            capabilities_used: normalized_values(operations.filter_map { |operation| operation.result&.capabilities_used }.flatten),
            capabilities_missing: normalized_values(operations.filter_map { |operation| operation.result&.capabilities_missing }.flatten),
          }
        end

        def to_h
          {
            policy_context: policy_context,
            metadata: metadata,
            summary: summary,
            delegation_registry: delegation_registry.to_h,
            operations: operations.map(&:to_h),
            diagnostics: diagnostics.map(&:to_h),
          }
        end

        private

        def tally_by(items)
          items.each_with_object({}) do |item, counts|
            key = yield(item)
            counts[key] = counts.fetch(key, 0) + 1
          end
        end

        def normalized_values(values)
          values.compact.uniq.sort_by(&:to_s)
        end
      end
    end
  end
end
