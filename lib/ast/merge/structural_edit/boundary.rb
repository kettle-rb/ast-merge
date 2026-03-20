# frozen_string_literal: true

module Ast
  module Merge
    module StructuralEdit
      # Passive metadata about one edge of a structural splice.
      #
      # A boundary captures the surviving owner adjacent to a splice plus any
      # known shared layout/comment attachments. The first contiguous replace
      # primitive mostly needs the owner and edge metadata, but remove/rehome
      # work can build on the same object without inventing a new boundary shape.
      class Boundary
        EDGES = %i[leading trailing].freeze

        attr_reader :edge, :owner, :layout_attachment, :comment_attachment, :metadata

        def initialize(edge:, owner: nil, layout_attachment: nil, comment_attachment: nil, metadata: {}, **options)
          @edge = normalize_edge(edge)
          @owner = owner
          @layout_attachment = layout_attachment
          @comment_attachment = comment_attachment
          @metadata = metadata.merge(options).freeze
        end

        def leading?
          edge == :leading
        end

        def trailing?
          edge == :trailing
        end

        def gaps
          attachment = layout_attachment
          return [] unless attachment && attachment.respond_to?(:gaps)

          Array(attachment.public_send(:gaps))
        end

        def regions
          attachment = comment_attachment
          return [] unless attachment && attachment.respond_to?(:regions)

          Array(attachment.public_send(:regions))
        end

        def inspect
          "#<#{self.class.name} edge=#{edge.inspect} owner=#{owner.class.name if owner} gaps=#{gaps.size} regions=#{regions.size}>"
        end

        private

        def normalize_edge(edge)
          normalized = edge&.to_sym
          return normalized if EDGES.include?(normalized)

          raise ArgumentError,
            "Unknown structural edit boundary edge: #{edge.inspect}. Expected one of: #{EDGES.join(", ")}"
        end
      end
    end
  end
end
