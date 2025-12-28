# frozen_string_literal: true

require "yaml"

module Ast
  module Merge
    module Recipe
      # Loads and represents a merge recipe from YAML configuration.
      #
      # A recipe defines how to perform a partial template merge:
      # - Which template file to use
      # - Which target files to process
      # - How to find the injection point in destinations
      # - Merge preferences and behavior
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
      # @see Runner For executing recipes
      # @see ScriptLoader For loading Ruby scripts from recipe folders
      #
      class Config
        # @return [String] Recipe name
        attr_reader :name

        # @return [String, nil] Recipe description
        attr_reader :description

        # @return [String] Path to template file (relative to recipe or absolute)
        attr_reader :template_path

        # @return [Array<String>] Glob patterns for target files
        attr_reader :targets

        # @return [Hash] Injection point configuration
        attr_reader :injection

        # @return [Hash] Merge behavior configuration
        attr_reader :merge_config

        # @return [Symbol] Behavior when injection anchor not found (:skip, :add, :error)
        attr_reader :when_missing

        # @return [String, nil] Path to the recipe file (if loaded from file)
        attr_reader :recipe_path

        # Load a recipe from a YAML file.
        #
        # @param path [String] Path to the recipe YAML file
        # @return [Config] Loaded recipe
        # @raise [ArgumentError] If file doesn't exist or is invalid
        def self.load(path)
          raise ArgumentError, "Recipe file not found: #{path}" unless File.exist?(path)

          yaml = YAML.safe_load(File.read(path), permitted_classes: [Regexp, Symbol])
          new(yaml, recipe_path: path)
        end

        # Create a recipe from a hash (parsed YAML or programmatic).
        #
        # @param config [Hash] Recipe configuration
        # @param recipe_path [String, nil] Path to recipe file (for relative path resolution)
        def initialize(config, recipe_path: nil)
          @recipe_path = recipe_path
          @name = config["name"] || "unnamed"
          @description = config["description"]
          @template_path = config["template"] || raise(ArgumentError, "Recipe must have 'template' key")
          @targets = Array(config["targets"] || ["*.md"])
          @injection = parse_injection(config["injection"] || {})
          @merge_config = parse_merge_config(config["merge"] || {})
          @when_missing = (config["when_missing"] || "skip").to_sym
        end

        # Get the absolute path to the template file.
        #
        # @param base_dir [String] Base directory for relative paths
        # @return [String] Absolute path to template
        def template_absolute_path(base_dir: nil)
          return @template_path if File.absolute_path?(@template_path)

          base = base_dir || (recipe_path ? File.dirname(recipe_path) : Dir.pwd)
          File.expand_path(@template_path, base)
        end

        # Expand target globs to actual file paths.
        #
        # @param base_dir [String] Base directory for glob expansion
        # @return [Array<String>] Absolute paths to target files
        def expand_targets(base_dir: nil)
          base = base_dir || (recipe_path ? File.dirname(recipe_path) : Dir.pwd)

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

        # Get the merge preference setting.
        #
        # @return [Symbol, Hash] Preference (:template, :destination, or per-type hash)
        def preference
          merge_config[:preference] || :template
        end

        # Get the add_missing setting, loading as callable if it's a script reference.
        #
        # @return [Boolean, Proc] Boolean value or callable filter
        def add_missing
          value = merge_config[:add_missing]
          return true if value.nil?
          return value if value == true || value == false
          return value if value.respond_to?(:call)

          # It's a script reference or inline lambda - load it
          script_loader.load_callable(value)
        end

        # Convenience alias for boolean check.
        #
        # @return [Boolean, Proc]
        def add_missing?
          add_missing
        end

        # Whether to use replace mode (template replaces section entirely).
        #
        # @return [Boolean]
        def replace_mode?
          merge_config[:replace_mode] == true
        end

        # Get the signature_generator callable, loading from script if needed.
        #
        # @return [Proc, nil] Signature generator callable
        def signature_generator
          value = merge_config[:signature_generator]
          return nil if value.nil?
          return value if value.respond_to?(:call)

          script_loader.load_callable(value)
        end

        # Get the node_typing configuration with callables loaded.
        #
        # @return [Hash, nil] Hash of type => callable
        def node_typing
          value = merge_config[:node_typing]
          return nil if value.nil?
          return value if value.is_a?(Hash) && value.values.all? { |v| v.respond_to?(:call) }

          script_loader.load_callable_hash(value)
        end

        # Get the script loader instance.
        #
        # @return [ScriptLoader]
        def script_loader
          @script_loader ||= ScriptLoader.new(recipe_path: recipe_path)
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
          return nil if config.empty?

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
          return nil if text.nil?
          return text if text.is_a?(Regexp)

          # Handle /regex/ syntax in YAML strings
          if text.is_a?(String) && text.start_with?("/") && text.end_with?("/")
            Regexp.new(text[1..-2])
          else
            text
          end
        end

        def parse_merge_config(config)
          {
            preference: parse_preference(config["preference"]),
            add_missing: config["add_missing"],
            replace_mode: config["replace_mode"] == true,
            match_by: Array(config["match_by"]).map(&:to_sym),
            deep: config["deep"] == true,
            signature_generator: config["signature_generator"],
            node_typing: config["node_typing"],
          }
        end

        def parse_preference(pref)
          return :template if pref.nil?
          return pref.to_sym if pref.is_a?(String)

          # Hash of type => preference
          pref.transform_keys(&:to_sym).transform_values(&:to_sym) if pref.is_a?(Hash)
        end
      end
    end
  end
end

