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

        def to_h
          {
            policy_context: policy_context,
            metadata: metadata,
            delegation_registry: delegation_registry.to_h,
            operations: operations.map(&:to_h),
            diagnostics: diagnostics.map(&:to_h),
          }
        end
      end
    end
  end
end
