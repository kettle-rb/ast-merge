# frozen_string_literal: true

# Ast::Merge RSpec Dependency Tags
#
# This module provides dependency detection helpers for conditional test execution
# in the ast-merge gem family. It extends tree_haver's dependency tags with
# merge-gem-specific checks.
#
# @example Loading in spec_helper.rb
#   require "ast/merge/rspec/dependency_tags"
#
# @example Usage in specs
#   it "requires markly-merge", :markly_merge do
#     # This test only runs when markly-merge is available
#   end
#
#   it "requires prism-merge", :prism_merge do
#     # This test only runs when prism-merge is available
#   end
#
# == Available Tags
#
# === Merge Gem Tags (run when dependency IS available)
#
# [:markly_merge]
#   markly-merge gem is available and functional.
#
# [:commonmarker_merge]
#   commonmarker-merge gem is available and functional.
#
# [:markdown_merge]
#   markdown-merge gem is available and functional.
#
# [:prism_merge]
#   prism-merge gem is available and functional.
#
# [:json_merge]
#   json-merge gem is available and functional.
#
# [:jsonc_merge]
#   jsonc-merge gem is available and functional.
#
# [:toml_merge]
#   toml-merge gem is available and functional.
#
# [:bash_merge]
#   bash-merge gem is available and functional.
#
# [:psych_merge]
#   psych-merge gem is available and functional.
#
# [:rbs_merge]
#   rbs-merge gem is available and functional.
#
# [:any_markdown_merge]
#   At least one markdown merge gem (markly-merge or commonmarker-merge) is available.
#
# === Negated Tags (run when dependency is NOT available)
#
# All positive tags have negated versions prefixed with `not_`:
# - :not_markly_merge, :not_commonmarker_merge, :not_markdown_merge
# - :not_prism_merge, :not_json_merge, :not_jsonc_merge
# - :not_toml_merge, :not_bash_merge, :not_psych_merge, :not_rbs_merge
# - :not_any_markdown_merge

module Ast
  module Merge
    module RSpec
      # Dependency detection helpers for conditional test execution
      module DependencyTags
        class << self
          # ============================================================
          # Merge Gem Availability
          # ============================================================

          # rubocop:disable ThreadSafety/ClassInstanceVariable
          # Check if markly-merge is available and functional
          #
          # @return [Boolean] true if markly-merge works
          def markly_merge_available?
            return @markly_merge_available if defined?(@markly_merge_available)
            @markly_merge_available = merge_gem_works?("markly/merge", "Markly::Merge::SmartMerger", "# Test\n\nParagraph")
          end

          # Check if commonmarker-merge is available and functional
          #
          # @return [Boolean] true if commonmarker-merge works
          def commonmarker_merge_available?
            return @commonmarker_merge_available if defined?(@commonmarker_merge_available)
            @commonmarker_merge_available = merge_gem_works?("commonmarker/merge", "Commonmarker::Merge::SmartMerger", "# Test\n\nParagraph")
          end

          # Check if markdown-merge is available and functional
          #
          # @return [Boolean] true if markdown-merge works
          def markdown_merge_available?
            return @markdown_merge_available if defined?(@markdown_merge_available)
            @markdown_merge_available = merge_gem_works?("markdown/merge", "Markdown::Merge::SmartMerger", "# Test\n\nParagraph")
          end

          # Check if prism-merge is available and functional
          #
          # @return [Boolean] true if prism-merge works
          def prism_merge_available?
            return @prism_merge_available if defined?(@prism_merge_available)
            @prism_merge_available = merge_gem_works?("prism/merge", "Prism::Merge::SmartMerger", "puts 1")
          end

          # Check if json-merge is available and functional
          #
          # @return [Boolean] true if json-merge works
          def json_merge_available?
            return @json_merge_available if defined?(@json_merge_available)
            @json_merge_available = merge_gem_works?("json/merge", "Json::Merge::SmartMerger", '{"key": "value"}')
          end

          # Check if jsonc-merge is available and functional
          #
          # @return [Boolean] true if jsonc-merge works
          def jsonc_merge_available?
            return @jsonc_merge_available if defined?(@jsonc_merge_available)
            @jsonc_merge_available = merge_gem_works?("jsonc/merge", "Jsonc::Merge::SmartMerger", '{"key": "value" /* comment */}')
          end

          # Check if toml-merge is available and functional
          #
          # @return [Boolean] true if toml-merge works
          def toml_merge_available?
            return @toml_merge_available if defined?(@toml_merge_available)
            @toml_merge_available = merge_gem_works?("toml/merge", "Toml::Merge::SmartMerger", 'key = "value"')
          end

          # Check if bash-merge is available and functional
          #
          # @return [Boolean] true if bash-merge works
          def bash_merge_available?
            return @bash_merge_available if defined?(@bash_merge_available)
            @bash_merge_available = merge_gem_works?("bash/merge", "Bash::Merge::SmartMerger", "echo hello")
          end

          # Check if psych-merge is available and functional
          #
          # @return [Boolean] true if psych-merge works
          def psych_merge_available?
            return @psych_merge_available if defined?(@psych_merge_available)
            @psych_merge_available = merge_gem_works?("psych/merge", "Psych::Merge::SmartMerger", "key: value")
          end

          # Check if rbs-merge is available and functional
          #
          # @return [Boolean] true if rbs-merge works
          def rbs_merge_available?
            return @rbs_merge_available if defined?(@rbs_merge_available)
            @rbs_merge_available = merge_gem_works?("rbs/merge", "Rbs::Merge::SmartMerger", "class Foo end")
          end
          # rubocop:enable ThreadSafety/ClassInstanceVariable

          # Check if at least one markdown merge gem is available
          #
          # @return [Boolean] true if any markdown merge gem works
          def any_markdown_merge_available?
            markly_merge_available? || commonmarker_merge_available? || markdown_merge_available?
          end

          # ============================================================
          # Summary and Reset
          # ============================================================

          # Get a summary of available dependencies (for debugging)
          #
          # @return [Hash{Symbol => Boolean}] map of dependency name to availability
          def summary
            {
              markly_merge: markly_merge_available?,
              commonmarker_merge: commonmarker_merge_available?,
              markdown_merge: markdown_merge_available?,
              prism_merge: prism_merge_available?,
              json_merge: json_merge_available?,
              jsonc_merge: jsonc_merge_available?,
              toml_merge: toml_merge_available?,
              bash_merge: bash_merge_available?,
              psych_merge: psych_merge_available?,
              rbs_merge: rbs_merge_available?,
              any_markdown_merge: any_markdown_merge_available?,
            }
          end

          # Reset all memoized availability checks
          #
          # @return [void]
          def reset!
            instance_variables.each do |ivar|
              remove_instance_variable(ivar) if ivar.to_s.end_with?("_available")
            end
          end

          private

          # Generic helper to check if a merge gem is available and functional
          #
          # @param require_path [String] the require path for the gem
          # @param merger_class [String] the full class name of the SmartMerger
          # @param test_source [String] sample source code to test merging
          # @return [Boolean] true if the merger can be instantiated
          def merge_gem_works?(require_path, merger_class, test_source)
            require require_path
            klass = Object.const_get(merger_class)
            klass.new(test_source, test_source)
            true
          rescue LoadError, StandardError
            false
          end
        end
      end
    end
  end
end

# Configure RSpec with dependency-based exclusion filters
RSpec.configure do |config|
  deps = Ast::Merge::RSpec::DependencyTags

  config.before(:suite) do
    # Print dependency summary if AST_MERGE_DEBUG is set
    if ENV["AST_MERGE_DEBUG"]
      puts "\n=== Ast::Merge Test Dependencies ==="
      deps.summary.each do |dep, available|
        status = available ? "✓ available" : "✗ not available"
        puts "  #{dep}: #{status}"
      end
      puts "=====================================\n"
    end
  end

  # ============================================================
  # Merge Gem Tags
  # ============================================================

  config.filter_run_excluding(markly_merge: true) unless deps.markly_merge_available?
  config.filter_run_excluding(commonmarker_merge: true) unless deps.commonmarker_merge_available?
  config.filter_run_excluding(markdown_merge: true) unless deps.markdown_merge_available?
  config.filter_run_excluding(prism_merge: true) unless deps.prism_merge_available?
  config.filter_run_excluding(json_merge: true) unless deps.json_merge_available?
  config.filter_run_excluding(jsonc_merge: true) unless deps.jsonc_merge_available?
  config.filter_run_excluding(toml_merge: true) unless deps.toml_merge_available?
  config.filter_run_excluding(bash_merge: true) unless deps.bash_merge_available?
  config.filter_run_excluding(psych_merge: true) unless deps.psych_merge_available?
  config.filter_run_excluding(rbs_merge: true) unless deps.rbs_merge_available?
  config.filter_run_excluding(any_markdown_merge: true) unless deps.any_markdown_merge_available?

  # ============================================================
  # Negated Tags (run when dependency is NOT available)
  # ============================================================

  config.filter_run_excluding(not_markly_merge: true) if deps.markly_merge_available?
  config.filter_run_excluding(not_commonmarker_merge: true) if deps.commonmarker_merge_available?
  config.filter_run_excluding(not_markdown_merge: true) if deps.markdown_merge_available?
  config.filter_run_excluding(not_prism_merge: true) if deps.prism_merge_available?
  config.filter_run_excluding(not_json_merge: true) if deps.json_merge_available?
  config.filter_run_excluding(not_jsonc_merge: true) if deps.jsonc_merge_available?
  config.filter_run_excluding(not_toml_merge: true) if deps.toml_merge_available?
  config.filter_run_excluding(not_bash_merge: true) if deps.bash_merge_available?
  config.filter_run_excluding(not_psych_merge: true) if deps.psych_merge_available?
  config.filter_run_excluding(not_rbs_merge: true) if deps.rbs_merge_available?
  config.filter_run_excluding(not_any_markdown_merge: true) if deps.any_markdown_merge_available?
end
