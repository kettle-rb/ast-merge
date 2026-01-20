# frozen_string_literal: true

require_relative "merge_gem_registry"

# Ast::Merge RSpec Dependency Tags
#
# This module provides dependency detection helpers for conditional test execution
# in the ast-merge gem family. It uses MergeGemRegistry for dynamic merge gem detection.
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
# == Dynamic Tag Registration
#
# Merge gems register themselves with MergeGemRegistry, which automatically:
# - Defines `*_available?` methods on DependencyTags
# - Configures RSpec exclusion filters for the tag
# - Supports negated tags (`:not_*`)
#
# @example How merge gems register (in their lib file)
#   Ast::Merge::RSpec::MergeGemRegistry.register(
#     :markly_merge,
#     require_path: "markly/merge",
#     merger_class: "Markly::Merge::SmartMerger",
#     test_source: "# Test\n\nParagraph",
#     category: :markdown
#   )
#
# == Built-in Composite Tags
#
# [:any_markdown_merge]
#   At least one markdown merge gem is available (category: :markdown).

module Ast
  module Merge
    module RSpec
      # Dependency detection helpers for conditional test execution
      module DependencyTags
        class << self
          # ============================================================
          # Composite Availability Checks
          # ============================================================

          # Check if at least one markdown merge gem is available
          #
          # @return [Boolean] true if any markdown merge gem works
          def any_markdown_merge_available?
            MergeGemRegistry.gems_by_category(:markdown).any? do |tag|
              MergeGemRegistry.available?(tag)
            end
          end

          # ============================================================
          # Summary and Reset
          # ============================================================

          # Get a summary of available dependencies (for debugging)
          #
          # @return [Hash{Symbol => Boolean}] map of dependency name to availability
          def summary
            result = MergeGemRegistry.summary
            result[:any_markdown_merge] = any_markdown_merge_available?
            result
          end

          # Reset all memoized availability checks
          #
          # @return [void]
          def reset!
            MergeGemRegistry.reset_availability!
          end
        end
      end
    end
  end
end

# NOTE: Known merge gems (KNOWN_GEMS) are NOT automatically registered here.
# Each test suite should explicitly register only the gems it needs in its
# spec/config/tree_haver.rb file using:
#
#   Ast::Merge::RSpec::MergeGemRegistry.register_known_gems(:gem1, :gem2, ...)
#
# This avoids wasting time registering gems that aren't needed for a particular
# test suite. Only the gems that are actually required for testing should be registered.
#
# Example for a gem that needs to test with optional markdown backends:
#   Ast::Merge::RSpec::MergeGemRegistry.register_known_gems(
#     :commonmarker_merge,
#     :markly_merge
#   )

# Configure RSpec with dependency-based exclusion filters
RSpec.configure do |config|
  deps = Ast::Merge::RSpec::DependencyTags
  registry = Ast::Merge::RSpec::MergeGemRegistry

  config.before(:suite) do
    # Force availability checking for all registered gems
    # This happens AFTER SimpleCov is loaded, preserving coverage accuracy
    registry.force_check_availability!

    # Now configure exclusion filters based on actual availability
    registry.registered_gems.each do |tag|
      if registry.available?(tag)
        # Gem is available - exclude tests tagged with :not_tag
        negated_tag = :"not_#{tag}"
        config.filter_run_excluding[negated_tag] = true
      else
        # Gem is NOT available - exclude tests tagged with :tag
        config.filter_run_excluding[tag] = true
      end
    end

    # Configure composite tags (these also trigger gem loading, so must be here)
    if deps.any_markdown_merge_available?
      config.filter_run_excluding[:not_any_markdown_merge] = true
    else
      config.filter_run_excluding[:any_markdown_merge] = true
    end

    # Print dependency summary if AST_MERGE_DEBUG is set
    unless ENV.fetch("AST_MERGE_DEBUG", "false").casecmp?("false")
      puts "\n=== Ast::Merge Test Dependencies ==="
      deps.summary.each do |dep, available|
        status = available ? "✓ available" : "✗ not available"
        puts "  #{dep}: #{status}"
      end
      puts "=====================================\n"
    end
  end

  # ============================================================
  # Dynamic Merge Gem Tags - Initial Setup
  # ============================================================
  # Note: We don't set exclusions here because that would require checking
  # availability (loading gems) before SimpleCov. The actual exclusions are
  # set in the before(:suite) hook above after force_check_availability! runs.
  # This includes composite tags like :any_markdown_merge.
end
