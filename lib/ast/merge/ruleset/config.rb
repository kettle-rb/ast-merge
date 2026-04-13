# frozen_string_literal: true

module Ast
  module Merge
    module Ruleset
      # Parses and validates a compact merge-ruleset document.
      class Config
        REQUIRED_DIRECTIVES = %i[format owners match read attach].freeze
        OPTIONAL_SINGLE_VALUE_DIRECTIVES = %i[comment_style render].freeze
        MULTI_VALUE_DIRECTIVES = %i[capability logical_owner].freeze
        KNOWN_DIRECTIVES = (REQUIRED_DIRECTIVES + OPTIONAL_SINGLE_VALUE_DIRECTIVES + MULTI_VALUE_DIRECTIVES).freeze

        READ_STRATEGIES = %i[
          source_augmented_synthetic
          native_read_synthetic_write
          native_mutation
        ].freeze

        ATTACHMENT_STRATEGIES = %i[
          layout_only
          tracker_layout_merge
          augmenter_preferred_tracker_layout
          normalize_tracked_layout_merge
        ].freeze

        IDENTIFIER_RE = /\A[A-Za-z][A-Za-z0-9_.-]*\z/.freeze
        TOKEN_RE = /\A[!-~]+\z/.freeze

        attr_reader :format, :owners, :match, :read, :attach, :comment_style, :render,
          :capabilities, :logical_owners, :directives, :source, :path

        class << self
          def load(path)
            raise ArgumentError, "Ruleset file not found: #{path}" unless File.exist?(path)

            parse(File.read(path, encoding: "UTF-8"), path: path)
          end

          def parse(source, path: nil)
            new(source, path: path)
          end
        end

        def initialize(source, path: nil)
          @source = source.to_s
          @path = path
          @directives = []
          @capabilities = {}
          @logical_owners = {}

          parse_source!
          validate_required_directives!
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

        def support_style(source:, capability: :full)
          case read
          when :source_augmented_synthetic
            Comment::SupportStyle.source_augmented_synthetic(
              source: source,
              capability: capability,
              style: comment_style,
            )
          when :native_read_synthetic_write
            Comment::SupportStyle.native_read_synthetic_write(
              source: source,
              capability: capability,
              style: comment_style,
            )
          when :native_mutation
            Comment::SupportStyle.native_mutation(
              source: source,
              capability: capability,
              style: comment_style,
            )
          else
            raise ArgumentError, "Unknown ruleset read strategy: #{read.inspect}"
          end
        end

        private

        def parse_source!
          source.each_line.with_index(1) do |raw_line, line_number|
            stripped = raw_line.strip
            next if stripped.empty?
            next if stripped.start_with?("#")

            parse_directive_line!(stripped, line_number)
          end
        end

        def parse_directive_line!(line, line_number)
          tokens = line.split(/\s+/)
          directive_token = tokens.shift
          directive = parse_identifier!(directive_token, line_number, field: :directive).to_sym

          validate_known_directive!(directive, line_number)
          validate_token_list!(tokens, line_number)

          case directive
          when *REQUIRED_DIRECTIVES, *OPTIONAL_SINGLE_VALUE_DIRECTIVES
            parse_single_value_directive!(directive, tokens, line_number)
          when :capability
            parse_capability!(tokens, line_number)
          when :logical_owner
            parse_logical_owner!(tokens, line_number)
          end

          @directives << {
            name: directive,
            arguments: tokens.dup,
            line_number: line_number,
          }
        end

        def parse_single_value_directive!(directive, tokens, line_number)
          if tokens.length != 1
            raise ArgumentError, "Directive #{directive} on line #{line_number} requires exactly 1 argument"
          end

          value = parse_scalar(tokens.first, line_number)

          case directive
          when :format, :owners, :match, :comment_style, :render
            value = value.to_sym
          when :read
            value = parse_strategy!(value, READ_STRATEGIES, directive, line_number)
          when :attach
            value = parse_strategy!(value, ATTACHMENT_STRATEGIES, directive, line_number)
          end

          instance_variable_name = :"@#{directive}"
          raise ArgumentError, "Duplicate directive #{directive} on line #{line_number}" if instance_variable_defined?(instance_variable_name)

          instance_variable_set(instance_variable_name, value)
        end

        def parse_capability!(tokens, line_number)
          if tokens.length != 2
            raise ArgumentError, "Directive capability on line #{line_number} requires exactly 2 arguments"
          end

          name = parse_identifier!(tokens[0], line_number, field: :capability).to_sym
          raise ArgumentError, "Duplicate capability #{name} on line #{line_number}" if capabilities.key?(name)

          capabilities[name] = parse_scalar(tokens[1], line_number)
        end

        def parse_logical_owner!(tokens, line_number)
          if tokens.length != 2
            raise ArgumentError, "Directive logical_owner on line #{line_number} requires exactly 2 arguments"
          end

          owner_kind = parse_identifier!(tokens[0], line_number, field: :logical_owner).to_sym
          raise ArgumentError, "Duplicate logical_owner #{owner_kind} on line #{line_number}" if logical_owners.key?(owner_kind)

          logical_owners[owner_kind] = parse_scalar(tokens[1], line_number).to_sym
        end

        def validate_required_directives!
          missing = REQUIRED_DIRECTIVES.reject { |directive| instance_variable_defined?(:"@#{directive}") }
          return if missing.empty?

          raise ArgumentError, "Ruleset missing required directives: #{missing.join(', ')}"
        end

        def validate_known_directive!(directive, line_number)
          return if KNOWN_DIRECTIVES.include?(directive)

          raise ArgumentError, "Unknown directive #{directive} on line #{line_number}"
        end

        def validate_token_list!(tokens, line_number)
          tokens.each do |token|
            next if TOKEN_RE.match?(token) && !token.include?("#") && !token.include?("\"")

            raise ArgumentError, "Invalid token #{token.inspect} on line #{line_number}"
          end
        end

        def parse_identifier!(token, line_number, field:)
          return token if IDENTIFIER_RE.match?(token)

          raise ArgumentError, "Invalid #{field} #{token.inspect} on line #{line_number}"
        end

        def parse_strategy!(value, allowed_values, directive, line_number)
          strategy = value.to_sym
          return strategy if allowed_values.include?(strategy)

          raise ArgumentError, "Unknown #{directive} strategy #{value.inspect} on line #{line_number}"
        end

        def parse_scalar(token, line_number)
          return true if token == "true"
          return false if token == "false"
          return token if IDENTIFIER_RE.match?(token)
          return token if TOKEN_RE.match?(token) && !token.include?("#") && !token.include?("\"")

          raise ArgumentError, "Invalid scalar #{token.inspect} on line #{line_number}"
        end
      end
    end
  end
end
