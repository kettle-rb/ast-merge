# frozen_string_literal: true

module Ast
  module Merge
    module Ruleset
      # Normalized parsed merge-ruleset configuration.
      class Config
        attr_reader :format,
          :owners,
          :match,
          :read,
          :attach,
          :comment_style,
          :render,
          :capabilities,
          :logical_owners,
          :directives,
          :source,
          :path

        class << self
          def load(path)
            raise ArgumentError, "Ruleset file not found: #{path}" unless File.exist?(path)

            parse(File.read(path, encoding: "UTF-8"), path: path)
          end

          def parse(source, path: nil)
            new(**Parser.parse(source, path: path))
          end
        end

        def initialize(
          source:,
          path: nil,
          format:,
          owners:,
          match:,
          read:,
          attach:,
          comment_style: nil,
          render: nil,
          capabilities: {},
          logical_owners: {},
          directives: []
        )
          @source = source.to_s
          @path = path
          @format = format
          @owners = owners
          @match = match
          @read = read
          @attach = attach
          @comment_style = comment_style
          @render = render
          @capabilities = capabilities.dup
          @logical_owners = logical_owners.dup
          @directives = directives.dup
        end

        def to_h
          {
            format: format,
            owners: owners,
            match: match,
            read: read,
            attach: attach,
            comment_style: comment_style,
            render: render,
            capabilities: capabilities.dup,
            logical_owners: logical_owners.dup,
          }.compact
        end

        def attachment_strategy
          attach
        end

        def feature_profile(source: :ruleset_config, capability: :full)
          FeatureProfile.new(
            owner_selector: owners,
            match_key: match,
            read_strategy: read,
            attachment_strategy: attach,
            comment_style: comment_style,
            render_family: render,
            support_style: comment_style ? support_style(source: source, capability: capability) : nil,
            capabilities: capabilities.merge(
              layout_aware: true,
              logical_owner: logical_owners.any?,
            ),
            logical_owners: logical_owners,
            metadata: {
              source: source,
              path: path,
            }.compact,
          )
        end

        def support_style(source:, capability: :full)
          SupportStyleResolver.call(read: read, source: source, capability: capability, style: comment_style)
        end
      end
    end
  end
end
