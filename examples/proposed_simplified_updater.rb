#!/usr/bin/env ruby
# frozen_string_literal: true

# PROPOSED: Simplified gem family section updater using the new architecture
#
# This is a MOCKUP showing what the script could look like after implementing
# the recommendations in docs/PARTIAL-TEMPLATE-MERGE-ARCHITECTURE.md
#
# Key insight: The template file IS the section definition.
# No need to redundantly list link_refs or content patterns.
#
# Current script: ~511 lines
# This mockup: ~25 lines of Ruby + ~20 lines YAML

require "bundler/inline"

gemfile do
  source "https://gem.coop"
  gem "ast-merge"      # Would include Recipe, RecipeRunner, Query, SectionExtractor
  gem "markly-merge"   # Parser backend
  gem "table_tennis"   # Output formatting
end

require "ast/merge/recipe"
require "table_tennis"

# Load recipe from YAML
recipe = Ast::Merge::Recipe.load(".merge-recipes/gem_family_section.yml")

# Run the merges
runner = Ast::Merge::RecipeRunner.new(
  recipe,
  dry_run: ARGV.include?("--dry-run"),
  parser: :markly,
)

results = runner.run

# Output with TableTennis
puts TableTennis.new(runner.results_table)
puts
puts TableTennis.new(runner.summary_table)

__END__

# Example .merge-recipes/gem_family_section.yml:
#
# name: gem_family_section
# description: Update gem family section in README files
#
# template: GEM_FAMILY_SECTION.md
#
# targets:
#   - "README.md"
#   - "vendor/*/README.md"
#
# section:
#   # Start is auto-inferred from template's first node (H3 heading)
#   # Boundary: stop at next H3 or higher
#   boundary: heading[level <= 3]
#
# merge:
#   preference: template
#   add_missing: true
#
# when_missing: skip


