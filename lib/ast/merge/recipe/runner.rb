# frozen_string_literal: true

module Ast
  module Merge
    module Recipe
      # Executes a merge recipe against target files.
      #
      # The runner:
      # 1. Loads the template file
      # 2. Expands target file globs
      # 3. For each target, finds the injection point and performs the merge
      # 4. Collects results for reporting
      #
      # @example Running a recipe
      #   recipe = Recipe::Config.load(".merge-recipes/gem_family_section.yml")
      #   runner = Recipe::Runner.new(recipe, dry_run: true)
      #   results = runner.run
      #   puts runner.summary
      #
      # @example With custom parser
      #   runner = Recipe::Runner.new(recipe, parser: :markly, base_dir: "/path/to/project")
      #   results = runner.run
      #
      # @see Config For recipe configuration
      # @see ScriptLoader For loading Ruby scripts from recipe folders
      #
      class Runner
        # Result of processing a single file
        Result = Struct.new(:path, :relative_path, :status, :changed, :has_anchor, :message, :stats, :error, keyword_init: true)

        # @return [Config] The recipe being executed
        attr_reader :recipe

        # @return [Boolean] Whether this is a dry run
        attr_reader :dry_run

        # @return [String] Base directory for path resolution
        attr_reader :base_dir

        # @return [Symbol] Parser to use (:markly, :commonmarker, :prism, :psych, etc.)
        attr_reader :parser

        # @return [Array<Result>] Results from the last run
        attr_reader :results

        # Initialize a recipe runner.
        #
        # @param recipe [Config] The recipe to execute
        # @param dry_run [Boolean] If true, don't write files
        # @param base_dir [String, nil] Base directory for path resolution
        # @param parser [Symbol] Which parser to use
        # @param verbose [Boolean] Enable verbose output
        def initialize(recipe, dry_run: false, base_dir: nil, parser: :markly, verbose: false)
          @recipe = recipe
          @dry_run = dry_run
          @base_dir = base_dir || Dir.pwd
          @parser = parser
          @verbose = verbose
          @results = []
        end

        # Run the recipe against all target files.
        #
        # @return [Array<Result>] Results for each processed file
        def run
          @results = []

          template_content = load_template
          # Let the recipe expand targets from its own location
          target_files = recipe.expand_targets

          target_files.each do |target_path|
            result = process_file(target_path, template_content)
            @results << result
            yield result if block_given?
          end

          @results
        end

        # Get results grouped by status.
        #
        # @return [Hash<Symbol, Array<Result>>]
        def results_by_status
          @results.group_by(&:status)
        end

        # Get a summary hash of the run.
        #
        # @return [Hash]
        def summary
          by_status = results_by_status
          {
            total: @results.size,
            updated: (by_status[:updated] || []).size,
            would_update: (by_status[:would_update] || []).size,
            unchanged: (by_status[:unchanged] || []).size,
            skipped: (by_status[:skipped] || []).size,
            errors: (by_status[:error] || []).size,
          }
        end

        # Format results as an array of hashes for TableTennis.
        #
        # @return [Array<Hash>]
        def results_table
          @results.map do |r|
            {
              file: r.relative_path,
              status: r.status.to_s,
              changed: r.changed ? "yes" : "no",
              message: r.message,
            }
          end
        end

        # Format summary as an array of hashes for TableTennis.
        #
        # @return [Array<Hash>]
        def summary_table
          s = summary
          [
            {metric: "Total files", value: s[:total]},
            {metric: "Updated", value: dry_run ? s[:would_update] : s[:updated]},
            {metric: "Unchanged", value: s[:unchanged]},
            {metric: "Skipped (no anchor)", value: s[:skipped]},
            {metric: "Errors", value: s[:errors]},
          ]
        end

        private

        def load_template
          # Let the recipe resolve the template path from its own location
          path = recipe.template_absolute_path
          raise ArgumentError, "Template not found: #{path}" unless File.exist?(path)

          File.read(path)
        end

        def process_file(target_path, template_content)
          relative_path = make_relative(target_path)

          begin
            destination_content = File.read(target_path)

            # Use PartialTemplateMerger which handles finding injection point and merging
            merger = PartialTemplateMerger.new(
              template: template_content,
              destination: destination_content,
              anchor: recipe.injection[:anchor] || {},
              boundary: recipe.injection[:boundary],
              parser: parser,
              preference: recipe.preference,
              add_missing: recipe.add_missing,
              when_missing: recipe.when_missing,
              replace_mode: recipe.replace_mode?,
              signature_generator: recipe.signature_generator,
              node_typing: recipe.node_typing,
            )

            result = merger.merge

            if result.section_found?
              create_result_from_merge(target_path, relative_path, destination_content, result)
            else
              handle_missing_anchor_result(target_path, relative_path, result)
            end
          rescue => e
            Result.new(
              path: target_path,
              relative_path: relative_path,
              status: :error,
              changed: false,
              has_anchor: false,
              message: e.message,
              error: e,
            )
          end
        end

        def create_result_from_merge(target_path, relative_path, _destination_content, merge_result)
          changed = merge_result.changed

          if changed
            unless dry_run
              File.write(target_path, merge_result.content)
            end

            Result.new(
              path: target_path,
              relative_path: relative_path,
              status: dry_run ? :would_update : :updated,
              changed: true,
              has_anchor: true,
              message: dry_run ? "Would update" : "Updated",
              stats: merge_result.stats,
            )
          else
            Result.new(
              path: target_path,
              relative_path: relative_path,
              status: :unchanged,
              changed: false,
              has_anchor: true,
              message: "No changes needed",
              stats: merge_result.stats,
            )
          end
        end

        def handle_missing_anchor_result(target_path, relative_path, merge_result)
          # PartialTemplateMerger already handled when_missing logic
          status = if merge_result.changed
            dry_run ? :would_update : :updated
          else
            :skipped
          end

          if merge_result.changed && !dry_run
            File.write(target_path, merge_result.content)
          end

          Result.new(
            path: target_path,
            relative_path: relative_path,
            status: status,
            changed: merge_result.changed,
            has_anchor: false,
            message: merge_result.message || "No matching anchor found",
          )
        end

        def make_relative(path)
          # Try to make path relative to base_dir first
          if path.start_with?(base_dir)
            return path.sub("#{base_dir}/", "")
          end

          # If recipe has a path, try relative to recipe's parent directory
          if recipe.recipe_path
            recipe_base = File.dirname(recipe.recipe_path, 2)
            if path.start_with?(recipe_base)
              return path.sub("#{recipe_base}/", "")
            end
          end

          # Fall back to the path itself
          path
        end
      end
    end
  end
end
