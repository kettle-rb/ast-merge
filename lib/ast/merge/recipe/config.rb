# frozen_string_literal: true

require "yaml"

module Ast
  module Merge
    module Recipe
      # Loads and represents a merge recipe from YAML configuration.
      #
      # A recipe extends Preset with:
      # - Template file specification
      # - Target file patterns
      # - Injection point configuration
      # - when_missing behavior
      #
      # @example Loading a recipe
      #   recipe = Config.load(".merge-recipes/gem_family_section.yml")
      #   recipe.name          # => "gem_family_section"
      #   recipe.template_path # => "GEM_FAMILY_SECTION.md"
      #   recipe.targets       # => ["README.md", "vendor/*/README.md"]
      #
      # @example Recipe YAML format
      #   name: gem_family_section
      #   description: Update gem family section in README files
      #
      #   template: GEM_FAMILY_SECTION.md
      #
      #   targets:
      #     - "README.md"
      #     - "vendor/*/README.md"
      #
      #   injection:
      #     anchor:
      #       type: heading
      #       text: /Gem Family/
      #     position: replace
      #     boundary:
      #       type: heading
      #       same_or_shallower: true
      #
      #   merge:
      #     preference: template
      #     add_missing: true
      #
      #   when_missing: skip
      #
      # @see Preset For base configuration without template/targets
      # @see Runner For executing recipes
      # @see ScriptLoader For loading Ruby scripts from recipe folders
      class Config < Preset
        # @return [String] Path to template file (relative to recipe or absolute)
        attr_reader :template_path

        # @return [Array<String>] Glob patterns for target files
        attr_reader :targets

        # @return [Hash] Injection point configuration
        attr_reader :injection

        # @return [Symbol] Behavior when injection anchor not found (:skip, :add, :error)
        attr_reader :when_missing

        # Alias for compatibility - recipe_path points to the same file as preset_path
        def recipe_path
          preset_path
        end

        class << self
          # Load a recipe from a YAML file.
          #
          # @param path [String] Path to the recipe YAML file
          # @return [Config] Loaded recipe
          # @raise [ArgumentError] If file doesn't exist or is invalid
          def load(path)
            raise ArgumentError, "Recipe file not found: #{path}" unless File.exist?(path)

            yaml = YAML.safe_load_file(path, permitted_classes: [Regexp, Symbol])
            new(yaml, preset_path: path)
          end
        end

        # Create a recipe from a hash (parsed YAML or programmatic).
        #
        # @param config [Hash] Recipe configuration
        # @param preset_path [String, nil] Path to recipe file (for relative path resolution)
        # @param recipe_path [String, nil] Alias for preset_path (backward compatibility)
        def initialize(config, preset_path: nil, recipe_path: nil)
          # Support both preset_path and recipe_path for backward compatibility
          effective_path = preset_path || recipe_path
          super(config, preset_path: effective_path)

          @template_path = config["template"] || raise(ArgumentError, "Recipe must have 'template' key")
          @targets = Array(config["targets"] || ["*.md"])
          @injection = parse_injection(config["injection"] || {})
          @when_missing = (config["when_missing"] || "skip").to_sym
        end

        # Get the absolute path to the template file.
        #
        # @param base_dir [String] Base directory for relative paths
        # @return [String] Absolute path to template
        def template_absolute_path(base_dir: nil)
          return @template_path if File.absolute_path?(@template_path)

          base = base_dir || (preset_path ? File.dirname(preset_path) : Dir.pwd)
          File.expand_path(@template_path, base)
        end

        # Expand target globs to actual file paths.
        #
        # @param base_dir [String] Base directory for glob expansion
        # @return [Array<String>] Absolute paths to target files
        def expand_targets(base_dir: nil)
          base = base_dir || (preset_path ? File.dirname(preset_path) : Dir.pwd)

          targets.flat_map do |pattern|
            if File.absolute_path?(pattern)
              Dir.glob(pattern)
            else
              # Expand and normalize to remove .. segments
              expanded_pattern = File.expand_path(pattern, base)
              Dir.glob(expanded_pattern)
            end
          end.uniq.sort
        end

        # Build an InjectionPointFinder query from the injection config.
        #
        # @return [Hash] Arguments for InjectionPointFinder#find
        def finder_query
          anchor = injection[:anchor] || {}
          boundary = injection[:boundary] || {}

          query = {
            type: anchor[:type],
            text: anchor[:text],
            position: injection[:position] || :replace,
            boundary_type: boundary[:type],
            boundary_text: boundary[:text],
          }

          # Support tree-depth based boundary detection
          # same_or_shallower: true means "end at next sibling (same tree level or above)"
          if boundary[:same_or_shallower]
            query[:boundary_same_or_shallower] = true
          end

          query.compact
        end

        # Whether to use replace mode (template replaces section entirely).
        #
        # @return [Boolean]
        def replace_mode?
          merge_config[:replace_mode] == true
        end

        private

        def parse_injection(config)
          return {} if config.empty?

          {
            anchor: parse_matcher(config["anchor"] || {}),
            position: (config["position"] || "replace").to_sym,
            boundary: parse_matcher(config["boundary"] || {}),
          }
        end

        def parse_matcher(config)
          return if config.empty?

          {
            type: config["type"]&.to_sym,
            text: parse_text_pattern(config["text"]),
            level: config["level"],
            level_lte: config["level_lte"],
            level_gte: config["level_gte"],
            same_or_shallower: config["same_or_shallower"] == true,
          }.compact
        end

        def parse_text_pattern(text)
          return if text.nil?
          return text if text.is_a?(Regexp)

          # Handle /regex/ syntax in YAML strings
          if text.is_a?(String) && text.start_with?("/") && text.end_with?("/")
            Regexp.new(text[1..-2])
          else
            text
          end
        end
      end
    end
  end
end
