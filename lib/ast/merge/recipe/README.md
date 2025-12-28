# Ast::Merge::Recipe

YAML-based recipe system for defining and executing merge operations across multiple files.

## Overview

The `Recipe` namespace provides a declarative way to define merge operations using YAML configuration files. This is particularly useful for:
- Updating template sections across many files
- Maintaining consistent documentation sections
- Automating repetitive merge tasks

## Components

### Config

Loads and represents a merge recipe from a YAML file.

```ruby
# Load a recipe from YAML
recipe = Ast::Merge::Recipe::Config.load("path/to/recipe.yml")

# Or create programmatically
recipe = Ast::Merge::Recipe::Config.new({
  "name" => "update_docs",
  "template" => "template.md",
  "targets" => ["README.md", "docs/*.md"],
  "injection" => {
    "anchor" => { "type" => "heading", "text" => "/My Section/" },
    "position" => "replace"
  }
})
```

### Runner

Executes recipes against target files.

```ruby
recipe = Ast::Merge::Recipe::Config.load("recipe.yml")
runner = Ast::Merge::Recipe::Runner.new(
  recipe,
  dry_run: true,      # Don't write files
  verbose: true,      # Show detailed output
  parser: :markly,    # Parser to use
  base_dir: Dir.pwd   # Base directory for paths
)

# Run and get results
results = runner.run

# Or run with a block for each file
runner.run do |result|
  puts "#{result.status}: #{result.relative_path}"
end

# Summary
puts runner.summary
# => { total: 10, updated: 5, unchanged: 3, skipped: 2 }
```

### ScriptLoader

Loads Ruby scripts referenced by recipes for custom logic.

```ruby
# Scripts are loaded from a folder matching the recipe basename
# For recipe.yml, scripts go in recipe/

loader = Ast::Merge::Recipe::ScriptLoader.new(recipe_path: "my_recipe.yml")

# Load a callable from a script file
filter = loader.load_callable("my_recipe/link_filter.rb")
# => #<Proc:...>
```

## Recipe YAML Format

```yaml
# Recipe name (required)
name: gem_family_section

# Description (optional)
description: Update gem family section in README files

# Template file path (required, relative to recipe file)
template: GEM_FAMILY_SECTION.md

# Target files (required, supports globs)
targets:
  - README.md
  - vendor/*/README.md

# Injection point configuration (required)
injection:
  # Anchor defines where to inject/find the section
  anchor:
    type: heading           # Node type to match
    text: "/Gem Family/"    # Text pattern (regex if wrapped in //)
    level: 3                # Optional: heading level
  
  # Position relative to anchor
  position: replace         # before, after, replace, first_child, last_child
  
  # Boundary defines where the section ends (for replace)
  boundary:
    type: heading           # Stop at next heading of same/higher level

# Merge preferences (optional)
merge:
  preference: template      # template, destination, or per-type hash
  add_missing: true         # Add template-only nodes

# Behavior when anchor not found (optional)
when_missing: skip          # skip, add, error
```

## CLI Usage

```bash
# Run a recipe in dry-run mode
bin/ast-merge-recipe .merge-recipes/gem_family_section.yml --dry-run

# Run with verbose output
bin/ast-merge-recipe recipe.yml --verbose

# Specify parser
bin/ast-merge-recipe recipe.yml --parser=commonmarker

# Specify base directory
bin/ast-merge-recipe recipe.yml --base-dir=/path/to/project
```

## Advanced: Custom Scripts

Recipes can reference Ruby scripts for custom logic:

```yaml
# In recipe.yml
merge:
  add_missing: link_filter.rb  # Loads from recipe_name/link_filter.rb
```

```ruby
# In recipe_name/link_filter.rb
# Must return a callable
->(node, entry) {
  # Only add link reference definitions
  entry[:signature].is_a?(Array) && 
    entry[:signature].first == :link_ref
}
```

## Example: Gem Family Section Updater

See `.merge-recipes/gem_family_section.yml` for a real-world example that updates the gem family documentation section across all README files in a monorepo.

## See Also

- [ast-merge README](../../../README.md) - Main documentation
- [Detector namespace](../detector/README.md) - Region detection
- [bin/ast-merge-recipe](../../../bin/ast-merge-recipe) - CLI implementation

