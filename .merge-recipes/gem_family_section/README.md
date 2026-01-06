# gem_family_section Recipe Scripts

This directory contains scripts for the `gem_family_section` recipe.

## Current Status: UNUSED

**With `replace_mode: true` in the parent recipe, these scripts are not executed.**

The template content completely replaces the destination section without
node-by-node merging, so:

- `signature_generator.rb` - Not used (no node matching needed)
- `add_missing_filter.rb` - Not used (no add_missing logic)
- `typing/*.rb` - Not used (no per-type preferences)

## When These Would Be Used

These scripts become active when `replace_mode: false` is set in the recipe.
In that mode, PartialTemplateMerger uses SmartMerger for intelligent
node-by-node merging:

1. **signature_generator.rb** - Creates signatures to match nodes between
   template and destination
2. **add_missing_filter.rb** - Determines which unmatched template nodes
   should be added to the result
3. **typing/*.rb** - Tags nodes with merge types for per-type preference
   handling (e.g., always prefer template tables)

## Why Keep These Files?

They serve as documentation and examples for anyone who wants to:
- Switch to intelligent merge mode
- Create new recipes with fine-grained merge control
- Understand how the merge system works

