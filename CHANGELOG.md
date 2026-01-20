# Changelog

[![SemVer 2.0.0][📌semver-img]][📌semver] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog]

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][📗keep-changelog],
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html),
and [yes][📌major-versions-not-sacred], platform and engine support are part of the [public API][📌semver-breaking].
Please file a bug if you notice a violation of semantic versioning.

[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-FFDD67.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-FFDD67.svg?style=flat

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [4.0.3] - 2026-01-19

- TAG: [v4.0.3][4.0.3t]
- COVERAGE: 97.30% -- 2739/2815 lines in 53 files
- BRANCH COVERAGE: 89.84% -- 893/994 branches in 53 files
- 98.81% documented

### Added

- **`Ast::Merge::RSpec::MergeGemRegistry.register_known_gems`**: Selective registration of known merge gems for RSpec dependency tags
  - Allows test suites to explicitly register only the merge gems they need, avoiding overhead of registering all known gems
  - Usage in `spec/config/tree_haver.rb`: `MergeGemRegistry.register_known_gems(:prism_merge, :commonmarker_merge)`
  - Enables proper RSpec tag-based test skipping for optional merge gem dependencies
  - Example: Tests tagged with `:prism_merge` are automatically skipped when prism-merge isn't available

### Changed

- Upgrade to [tree_haver v5.0.2](https://github.com/kettle-rb/tree_haver/releases/tag/v5.0.2)
- **RSpec dependency tag load order pattern**: Merge gems now load tree_haver and dependency tags early via `spec/config/tree_haver.rb`
  - Ensures `TreeHaver::RSpec::DependencyTags` is loaded before gems register themselves
  - Pattern: Load tree_haver/rspec → Load ast/merge/rspec → Register known gems → Load library
  - Applied to markdown-merge and markly-merge; other merge gems should follow this pattern

## [4.0.2] - 2026-01-12

- TAG: [v4.0.2][4.0.2t]
- COVERAGE: 97.30% -- 2739/2815 lines in 53 files
- BRANCH COVERAGE: 89.84% -- 893/994 branches in 53 files
- 98.81% documented

### Added

- **`Recipe::Runner` target file override**: Accept `target_files` parameter to override recipe targets
  - `Runner.new(recipe, target_files: ["file1.md", "file2.md"])` - Process only specified files
  - Paths are expanded relative to `base_dir`
  - When not specified, falls back to recipe's configured targets
- **`exe/ast-merge-recipe` file arguments**: Accept target files on command line
  - `ast-merge-recipe recipe.yml file1.md file2.md` - Override recipe targets
  - Updated help text and banner to document new usage
- **`bin/update_gem_family_section` file arguments**: Accept target files on command line
  - `bin/update_gem_family_section vendor/my-gem/README.md` - Process specific file(s)
  - If no files specified, defaults to `README.md` + `vendor/*/README.md`
  - Added `--skip-fix` option to skip the formatting fix step

### Changed

- **`bin/update_gem_family_section`**: Refactored to use `OptionParser` for clean option handling
  - Consistent with `bin/fix_readme_formatting` style
  - Properly separates options from file arguments

## [4.0.1] - 2026-01-11

- TAG: [v4.0.1][4.0.1t]
- COVERAGE: 96.45% -- 2553/2647 lines in 51 files
- BRANCH COVERAGE: 87.41% -- 812/929 branches in 51 files
- 98.80% documented

### Added

- **`Ast::Merge::RSpec::MergeGemRegistry`** - Fully dynamic merge gem registration for RSpec dependency tags
  - `register(tag_name, require_path:, merger_class:, test_source:, category:)` - Register a merge gem
  - `available?(tag_name)` - Check if a merge gem is available and functional
  - `registered_gems` - Get all registered gem tag names
  - `gems_by_category(category)` - Filter gems by category (:markdown, :data, :code, :config, :other)
  - `summary` - Get availability status of all registered gems
  - Automatically defines `*_available?` methods on `DependencyTags` at registration time
  - External merge gems can now get full RSpec tag support without modifying ast-merge

### Changed

- Upgrade to [tree_haver v5.0.1](https://github.com/kettle-rb/tree_haver/releases/tag/v5.0.1)
- **`Ast::Merge::AstNode` now inherits from `TreeHaver::Base::Node`**
  - Ensures synthetic nodes stay in sync with the canonical Node API
  - Inherits `Comparable`, `Enumerable` from base class
  - Retains all existing methods and behavior (Point, Location, signature, etc.)
  - Constructor calls `super(self, source: source)` to properly initialize base class
- **RSpec Dependency Tags refactored to use MergeGemRegistry**
  - Removed hardcoded merge gem availability checks
  - Removed `MERGE_GEM_TEST_SOURCES` constant
  - `*_available?` methods are now defined dynamically when gems register
  - `any_markdown_merge_available?` now queries registry by category
  - RSpec exclusion filters are configured dynamically from registry
- `Ast::Merge::Testing::TestableNode` now delegates to `TreeHaver::RSpec::TestableNode`
  - The TestableNode implementation has been moved to tree_haver for sharing across all merge gems
  - `spec/support/testable_node.rb` now requires and re-exports the tree_haver version
  - Backward compatible: existing tests continue to work unchanged
- `spec/ast/merge/node_wrapper_base_spec.rb` refactored to use `TestableNode` instead of mocks
  - Real TreeHaver::Node behavior for most tests
  - Mocks only retained for edge case testing (e.g., invalid end_line before start_line)

## [4.0.0] - 2026-01-11

- TAG: [v4.0.0][4.0.0t]
- COVERAGE: 96.52% -- 2555/2647 lines in 51 files
- BRANCH COVERAGE: 87.62% -- 814/929 branches in 51 files
- 98.80% documented

### Added

- `Recipe::Preset#normalize_whitespace` - option to collapse excessive blank lines in merged output
- `Recipe::Preset#rehydrate_link_references` - option to convert inline links to reference style
- `Recipe::Runner::Result#problems` - access document problems found during merge
- `exe/ast-merge-recipe --show-problems` - flag to display document problems in CLI output
- `Ast::Merge::DiffMapperBase` - Abstract base class for mapping unified git diffs to AST node paths
  - `DiffHunk` struct for representing diff hunks with line numbers and content
  - `DiffLine` struct for individual diff lines with type (`:context`, `:addition`, `:removal`)
  - `DiffMapping` struct for mapping changes to AST paths with operation type
  - `DiffParseResult` struct for parsed diff with file paths and hunks
  - `#parse_diff(diff_text)` - Parse unified git diff format into structured hunks
  - `#determine_operation(hunk)` - Detect `:add`, `:remove`, or `:modify` from hunk content
  - Abstract `#map_hunk_to_paths` for format-specific implementations
  - Abstract `#create_analysis` for format-specific file analysis
- `Ast::Merge::ConflictResolverBase` - New options for advanced merge control:
  - `recursive: true | false | Integer` - Control recursive merging of nested structures
    - `true` (default): Unlimited depth recursive merging
    - `false`: Disabled, replace entire matched nodes
    - `Integer > 0`: Maximum recursion depth
    - `0`: Invalid, raises `ArgumentError`
  - `remove_template_missing_nodes: false` - When `true`, removes destination nodes not present in template
  - `#should_recurse?(depth)` - Helper to check if recursion should continue at given depth
  - `#validate_recursive!` - Validation for recursive parameter
- `exe/ast-merge-diff` - CLI executable for applying git diffs via AST-aware merging
  - Auto-detects format from file extension (`.yml`, `.yaml`, `.json`, `.rb`, etc.)
  - `--diff FILE` - Path to unified diff file (use `-` for stdin, default: stdin)
  - `--original FILE` - Original file for AST path mapping (required)
  - `--destination FILE` - Destination file to merge into (required)
  - `--format FORMAT` - Override format auto-detection
  - `--dry-run` - Preview changes without writing
  - `--verbose` - Detailed output
  - `--add-only` - Only apply additions from diff
  - `--remove-only` - Only apply removals from diff
  - Uses bundler/inline with dynamic gem loading based on detected format

### Changed

- **BREAKING**: Upgrade to [tree_haver v5.0.0](https://github.com/kettle-rb/tree_haver/releases/tag/v5.0.0)
- **BREAKING**: Refactored navigation classes into `Ast::Merge::Navigable` namespace
  - `Ast::Merge::NavigableStatement` → `Ast::Merge::Navigable::Statement`
  - `Ast::Merge::InjectionPoint` → `Ast::Merge::Navigable::InjectionPoint`
  - `Ast::Merge::InjectionPointFinder` → `Ast::Merge::Navigable::InjectionPointFinder`
  - Each class is now in its own file under `lib/ast/merge/navigable/`
  - Uses autoload for lazy loading
- `bin/fix_readme_formatting` - Rewritten to use SmartMerger API
  - Now uses `Markdown::Merge::SmartMerger` with `normalize_whitespace: :link_refs` and `rehydrate_link_references: true`
  - The `:link_refs` mode collapses excessive blank lines AND removes blank lines between consecutive link reference definitions
  - Merges empty template with destination to apply cleanup transformations
  - Reports duplicate link definitions, link ref spacing fixes, and other problems from `MergeResult#problems`
  - Removed custom regex-based link rehydration and whitespace normalization

### Fixed

- `Ast::Merge::PartialTemplateMergerBase#normalize_matcher` now preserves `same_or_shallower` key from boundary config
- `Ast::Merge::PartialTemplateMergerBase#merge` now passes `boundary_same_or_shallower` to `InjectionPointFinder#find`

## [3.1.0] - 2026-01-08

- TAG: [v3.1.0][3.1.0t]
- COVERAGE: 96.89% -- 2465/2544 lines in 47 files
- BRANCH COVERAGE: 89.62% -- 794/886 branches in 47 files
- 98.75% documented

### Added

- `Ast::Merge::EmitterBase` - Abstract base class for format-specific emitters
  - Provides common infrastructure for converting AST structures back to text
  - Tracks indentation level with configurable `indent_size` (default: 2 spaces)
  - Manages output lines collection with `#lines` accessor
  - `#emit_blank_line` - Emit an empty line
  - `#emit_leading_comments` - Emit comments from CommentTracker
  - `#emit_raw_lines` - Emit lines without modification (preserves exact formatting)
  - `#to_s` - Get output as a single string with trailing newline
  - `#clear` - Reset emitter state
  - `#indent` / `#dedent` - Increase/decrease indentation level
  - Subclass hooks: `#initialize_subclass_state`, `#clear_subclass_state`, `#emit_tracked_comment`
  - Used by jsonc-merge, json-merge, bash-merge, toml-merge, and psych-merge emitters

### Changed

- tree_haver v4.0.0

## [3.0.0] - 2026-01-05

- TAG: [v3.0.0][3.0.0t]
- COVERAGE: 96.93% -- 2462/2540 lines in 47 files
- BRANCH COVERAGE: 89.62% -- 794/886 branches in 47 files
- 98.72% documented

### Added

- `TestableNode` spec helper class that wraps a mock in a real `TreeHaver::Node`, providing consistent API testing without relying on fragile mocks
- `Recipe::Preset#match_refiner` accessor method (was missing, causing errors in Recipe::Runner)
- Minimal reproduction specs for `to_commonmark` normalization behavior:
  - `spec/integration/link_reference_preservation_spec.rb` - tests link ref preservation
  - `spec/integration/table_formatting_preservation_spec.rb` - tests table padding preservation
- `Ast::Merge::PartialTemplateMergerBase` - Abstract base class for parser-agnostic partial template merging
  - `#build_position_based_signature_generator` - Creates signature generators that match elements by position
  - Position counters reset per document key, enabling tables at same position to match regardless of structure

### Changed

- **BREAKING**: `NavigableStatement#text` now requires nodes to conform to TreeHaver Node API (must have `#text` method)
  - Removed conditional fallbacks for `to_plaintext`, `to_commonmark`, `slice`
  - Nodes must now implement `#text` directly (all TreeHaver backends already do)
- **BREAKING**: `ContentMatchRefiner#extract_content` now requires nodes to conform to TreeHaver Node API
  - Removed conditional fallbacks for `text_content`, `string_content`, `content`, `to_s`
  - Custom `content_extractor` proc still supported for non-standard nodes
- Signature generators and typing scripts now receive TreeHaver nodes directly (no NavigableStatement wrapping)
- Removed NavigableStatement wrapping from `FileAnalyzable#generate_signature` and `NodeTyping.process`

### Removed

- **BREAKING**: `Ast::Merge::PartialTemplateMerger` removed. Use `Markdown::Merge::PartialTemplateMerger` directly.
  - The base class `Ast::Merge::PartialTemplateMergerBase` remains for other parsers to extend
  - Migration: change `Ast::Merge::PartialTemplateMerger.new(parser: :markly, ...)` to
    `Markdown::Merge::PartialTemplateMerger.new(backend: :markly, ...)`

### Fixed

- **Source-based rendering**: `Markdown::Merge::PartialTemplateMerger#node_to_text` now prefers extracting
  original source text using `analysis.source_range` instead of `to_commonmark`. This preserves:
  - Link reference definitions (no conversion to inline links)
  - Table column padding/alignment
  - Original formatting exactly as written

## [2.0.10] - 2026-01-04

- TAG: [v2.0.10][2.0.10t]
- COVERAGE: 97.10% -- 2642/2721 lines in 48 files
- BRANCH COVERAGE: 89.57% -- 893/997 branches in 48 files
- 98.72% documented

### Added

- Dependency tags for `rbs_merge` and `not_rbs_merge`

### Changed

- Upgraded to `tree_haver` v3.2.4 (major new features, and bug fixes, see [release notes](https://github.com/kettle-rb/tree_haver/releases/tag/v3.2.4))

### Fixed

- `PartialTemplateMerger#build_merged_content` previously always injected an extra newline between parts, now join is context-aware

## [2.0.9] - 2026-01-02

- TAG: [v2.0.9][2.0.9t]
- COVERAGE: 97.09% -- 2637/2716 lines in 48 files
- BRANCH COVERAGE: 89.64% -- 883/985 branches in 48 files
- 98.71% documented

### Fixed

- **`NavigableStatement.find_matching` now returns empty array when no criteria specified** -
  Previously, when both `type: nil` and `text: nil` and no block was given, the method would
  match ALL statements (since no conditions filtered anything out). This caused
  `PartialTemplateMerger` to incorrectly report `has_section: true` when `anchor: nil` was passed.
  Now returns an empty array when no criteria are specified.

## [2.0.8] - 2026-01-01

- TAG: [v2.0.8][2.0.8t]
- COVERAGE: 97.09% -- 2636/2715 lines in 48 files
- BRANCH COVERAGE: 89.73% -- 882/983 branches in 48 files
- 98.71% documented

### Added

- `Ast::Merge::NodeWrapperBase` abstract base class for format-specific node wrappers
  - Provides common functionality shared by `*::Merge::NodeWrapper` classes across gems
  - Handles source context (lines, source string), line info, comments, content extraction
  - Defines abstract `#compute_signature` that subclasses must implement
  - Includes `#node_wrapper?` to distinguish from `NodeTyping::Wrapper`
  - Includes `#underlying_node` to access the raw TreeHaver node (NOT `#unwrap` to avoid
    conflict with `NodeTyping::Wrapper#unwrap` semantics in `FileAnalyzable`)
  - Documents relationship between `NodeWrapperBase` and `NodeTyping::Wrapper`:
    - `NodeWrapperBase`: Format-specific functionality (line info, signatures, type predicates)
    - `NodeTyping::Wrapper`: Custom merge classification (`merge_type` attribute)
  - Nodes can be double-wrapped: `NodeTyping::Wrapper(Format::Merge::NodeWrapper(tree_sitter_node))`
  - Accepts `**options` in initialize for subclass-specific parameters (e.g., `backend`, `document_root`)

## [2.0.7] - 2026-01-01

- TAG: [v2.0.7][2.0.7t]
- COVERAGE: 97.31% -- 2569/2640 lines in 47 files
- BRANCH COVERAGE: 89.87% -- 869/967 branches in 47 files
- 98.84% documented

### Added

- `Ast::Merge::NodeTyping::Normalizer` module for thread-safe backend type normalization
  - Provides shared infrastructure for format-specific normalizers (toml-merge, markdown-merge)
  - Thread-safe backend registration via mutex-protected operations
  - `configure_normalizer` for initial backend mappings configuration
  - `register_backend` for runtime registration of new backends
  - `canonical_type` for mapping backend-specific types to canonical types
  - `wrap` for wrapping nodes with canonical merge_type
  - `registered_backends`, `backend_registered?`, `mappings_for`, `canonical_types` query methods
- `Ast::Merge::NodeTyping::FrozenWrapper` class for frozen AST nodes
  - Includes `Freezable` behavior for freeze marker support
  - `frozen_node?`, `slice`, `signature` methods
- Split `NodeTyping` module into separate files following autoload pattern:
  - `ast/merge/node_typing/wrapper.rb`
  - `ast/merge/node_typing/frozen_wrapper.rb`
  - `ast/merge/node_typing/normalizer.rb`
- Comprehensive specs for `NodeTyping::Normalizer` including thread-safety tests
- RBS type signatures for `NodeTyping::Normalizer` and `NodeTyping::FrozenWrapper`

## [2.0.6] - 2026-01-01

- TAG: [v2.0.6][2.0.6t]
- COVERAGE: 97.19% -- 2522/2595 lines in 44 files
- BRANCH COVERAGE: 89.91% -- 864/961 branches in 44 files
- 98.82% documented

### Added

- Comprehensive mocked tests for `Ast::Merge::Recipe::Runner` (47 new tests):
  - Tests for `#run` method with section found, changed, and unchanged scenarios
  - Tests for `#run` with section not found (skipped vs appended)
  - Tests for actual file writes in non-dry_run mode
  - Tests for exception handling during merge
  - Tests for `#summary` with all status counts (updated, would_update, unchanged, skipped, errors)
  - Tests for `#results_by_status` grouping
  - Tests for `#results_table` formatting (file, status, changed, message)
  - Tests for `#summary_table` in both dry_run and non-dry_run modes
  - Tests for `#make_relative` edge cases (base_dir, recipe base, unknown paths)
  - Tests for `#make_relative` without recipe_path

## [2.0.5] - 2025-12-31

- TAG: [v2.0.5][2.0.5t]
- COVERAGE: 91.68% -- 2379/2595 lines in 44 files
- BRANCH COVERAGE: 81.37% -- 782/961 branches in 44 files
- 98.82% documented

### Added

- Comprehensive tests for `Ast::Merge::AstNode` and nested structs (Point, Location)
- Tests for `Ast::Merge::Comment::Style` class methods and instance methods
- Tests for `Ast::Merge::Comment::Line` including freeze marker detection
- Tests for `Ast::Merge::Comment::Block` including raw_content and children modes
- Tests for `Ast::Merge::Comment::Parser` edge cases (unclosed blocks, mixed content, auto-detection)
- Tests for `Ast::Merge::NavigableStatement` tree navigation methods
- Tests for `Ast::Merge::InjectionPoint` (start_line, end_line, inspect)
- Tests for `Ast::Merge::InjectionPointFinder` boundary options (boundary_type, boundary_text, boundary_matcher, boundary_same_or_shallower)
- Tests for `Ast::Merge::PartialTemplateMerger::Result` including injection_point and default values
- Tests for `Ast::Merge::PartialTemplateMerger` text pattern normalization (regex strings, plain strings)
- Tests for `Ast::Merge::PartialTemplateMerger` anchor normalization with level options
- Tests for `Ast::Merge::PartialTemplateMerger` unknown when_missing fallback behavior
- Tests for `Ast::Merge::PartialTemplateMerger` section boundary detection and replace_mode behavior
- Tests for `Ast::Merge::PartialTemplateMerger` unknown parser error handling
- Tests for `Ast::Merge::Recipe::Runner::Result` stats and error attributes
- Tests for `Ast::Merge::Recipe::Runner` actual file writes (non-dry-run mode)
- Tests for `Ast::Merge::Recipe::Runner` error handling (unreadable files, missing template)
- Tests for `Ast::Merge::Recipe::Runner` when_missing with append behavior
- Tests for `Ast::Merge::Recipe::Config` same_or_shallower boundary, replace_mode, level options
- Tests for `Ast::Merge::Recipe::Config` injection parsing with empty/nil/Regexp patterns
- Tests for `Ast::Merge::Recipe::Config` expand_targets with absolute patterns
- Tests for `Ast::Merge::Recipe::Preset` callable add_missing and node_typing
- Tests for `Ast::Merge::Recipe::Preset` script_loader caching
- Tests for `Ast::Merge::Recipe::ScriptLoader` syntax error handling
- Tests for `Ast::Merge::Recipe::ScriptLoader` absolute path resolution
- Tests for `Ast::Merge::ContentMatchRefiner` extract_node_type with typed nodes
- Tests for `Ast::Merge::ContentMatchRefiner` filter_nodes with node_types

### Changed

- tree_haver v3.2.1
- Internal files now use autoload instead of `require_relative` for consistency

## [2.0.4] - 2025-12-31

- TAG: [v2.0.4][2.0.4t]
- COVERAGE: 88.61% -- 2903/3276 lines in 53 files
- BRANCH COVERAGE: 67.90% -- 700/1031 branches in 53 files
- 98.82% documented

### Added

- Many more tests

### Fixed

- RSpec shared examples for `Ast::Merge::DebugLogger` now handle Ruby 4.0+ where benchmark is a bundled gem
  - The `#time logs start and completion with timing` test now checks `BENCHMARK_AVAILABLE` constant
  - When benchmark is available: expects full timing output with "Starting:", "Completed:", and `real_ms`
  - When benchmark is unavailable: expects warning message about benchmark gem not being available
  - Fixes CI failures on Ruby 4.0.0 for downstream gems (e.g., bash-merge) using the shared examples

## [2.0.3] - 2025-12-30

- TAG: [v2.0.3][2.0.3t]
- COVERAGE: 88.45% -- 2894/3272 lines in 53 files
- BRANCH COVERAGE: 67.83% -- 698/1029 branches in 53 files
- 98.82% documented

### Fixed

- `Ast::Merge::DebugLogger::BENCHMARK_AVAILABLE` now correctly detects when benchmark gem is unavailable
  - Previous implementation used `autoload` which never raises `LoadError` (it only registers for lazy loading)
  - Now uses `require "benchmark"` which properly catches `LoadError` on Ruby 4.0+ where benchmark is a bundled gem
  - The `#time` method now correctly falls back to non-timed execution when benchmark is unavailable

## [2.0.2] - 2025-12-30

- TAG: [v2.0.2][2.0.2t]
- COVERAGE: 88.47% -- 2894/3271 lines in 53 files
- BRANCH COVERAGE: 67.83% -- 698/1029 branches in 53 files
- 98.82% documented

### Added

- Backend Platform Compatibility section to README and GEM_FAMILY_SECTION.md
  - Documents which tree_haver backends work on MRI, JRuby, and TruffleRuby
  - Explains why JRuby and TruffleRuby have limited tree-sitter backend support

### Changed

- Updated RSpec README documentation for tree_haver dependency tag changes
  - All tags now follow consistent naming conventions with suffixes
  - Backend tags use `*_backend` suffix
  - Engine tags use `*_engine` suffix
  - Grammar tags use `*_grammar` suffix
  - Parsing capability tags use `*_parsing` suffix
  - See [lib/ast/merge/rspec/README.md](lib/ast/merge/rspec/README.md) for complete tag reference

## [2.0.1] - 2025-12-29

- TAG: [v2.0.1][2.0.1t]
- COVERAGE: 88.47% -- 2894/3271 lines in 53 files
- BRANCH COVERAGE: 67.83% -- 698/1029 branches in 53 files
- 98.82% documented

### Changed

- Upgraded dependencies
  - yard-fence v0.8.1
  - tree_haver v3.1.2
  - kettle-test v1.0.7

### Fixed

- Documentation cleanup (via yard-fence)

## [2.0.0] - 2025-12-28

- TAG: [v2.0.0][2.0.0t]
- COVERAGE: 88.47% -- 2894/3271 lines in 53 files
- BRANCH COVERAGE: 67.83% -- 698/1029 branches in 53 files
- 98.82% documented

### Added

- **RSpec Dependency Tags**: Conditional test execution based on available merge gems
  - New `lib/ast/merge/rspec/dependency_tags.rb` provides automatic test filtering
  - Tags for all merge gems: `:markly_merge`, `:prism_merge`, `:json_merge`, `:toml_merge`, etc.
  - Composite tag `:any_markdown_merge` for tests that work with any markdown merger
  - Negated tags (e.g., `:not_prism_merge`) for testing fallback behavior
  - `AST_MERGE_DEBUG=1` environment variable prints dependency summary
  - Eliminates need for `require` statements inside spec files
  - See [lib/ast/merge/rspec/README.md](lib/ast/merge/rspec/README.md) for full documentation

- **Recipe::Preset**: Base class for merge configuration presets
  - Provides merge configuration (signature generators, node typing, preferences) without requiring template files
  - `Recipe::Config` now inherits from `Preset`, adding template/target handling
  - `to_h` method converts preset to SmartMerger-compatible options hash
  - Enables kettle-jem and other libraries to define reusable merge presets
  - Supports script loading for signature generators and node typing via `ScriptLoader`

- **exe/ast-merge-recipe**: Shipped executable for running merge recipes
  - Uses `bundler/inline` for dependency management
  - Supports `--dry-run`, `--verbose`, `--parser`, `--base-dir` options
  - Uses `optparse` for proper option parsing
  - Loads merge gems from recipe YAML `merge_gems` section
  - Development mode via `KETTLE_RB_DEV=true` or `--dev-root` option
  - All gems sourced from gem.coop

- **PartialTemplateMerger**: Section-based merging for partial templates
  - Find and merge specific sections in destination documents
  - Support for both `replace_mode` (full replacement) and merge mode (intelligent merging)
  - Configurable anchor and boundary matchers for section detection
  - Custom `signature_generator` and `node_typing` support for advanced matching
  - `when_missing` behavior: `:skip`, `:append`, `:prepend`

- **Recipe**: YAML-based recipe system for defining merge operations
  - Load recipes from YAML files with `Recipe.load(path)`
  - Define template, targets, injection point, merge preferences
  - Support for `when_missing: skip|add|error` behavior
  - Support for `replace_mode` option
  - Automatic path resolution relative to recipe file location

- **RecipeRunner**: Execute recipes against multiple target files
  - Uses PartialTemplateMerger for section-based merging
  - Dry-run mode with `--dry-run` flag
  - Results tracking with status, stats, and error reporting
  - TableTennis integration for formatted output
  - Support for different parsers (markly, commonmarker, prism, psych)

- **RecipeScriptLoader**: Load Ruby scripts referenced by recipes
  - Convention: scripts in folder matching recipe basename (e.g., `my_recipe/` for `my_recipe.yml`)
  - Support for inline lambda expressions in YAML
  - Script caching for performance
  - Validation that scripts return callable objects

- **bin/ast-merge-recipe**: CLI for running merge recipes
  - `bin/ast-merge-recipe RECIPE_FILE [--dry-run] [--verbose]`
  - Color-coded output with status symbols
  - Summary table with counts

- **NavigableStatement**: New wrapper class for uniform node navigation (language-agnostic)
  - Provides flat list navigation (`next`, `previous`, `index`) for all nodes
  - Tree depth calculation with `tree_depth` method
  - `same_or_shallower_than?` for level-based boundary detection
  - Language-agnostic section boundaries using tree hierarchy
  - Provides tree navigation (`tree_parent`, `tree_next`, `tree_previous`) for parser-backed nodes
  - `synthetic?` method to detect nodes without tree navigation (GapLineNode, LinkDefinitionNode, etc.)
  - `type?` and `text_matches?` helpers for node matching
  - `node_attribute` for accessing parser-specific attributes with fallbacks
  - `each_following` and `take_until` for sequential traversal
  - `find_matching` and `find_first` class methods for querying statement lists
  - `build_list` class method to create linked statement lists from raw statements

- **InjectionPoint**: New class for defining where content can be injected (language-agnostic)
  - Supports positions: `:before`, `:after`, `:first_child`, `:last_child`, `:replace`
  - Optional boundary for replacement ranges
  - `replacement?`, `child_injection?`, `sibling_injection?` predicates
  - `replaced_statements` to get all statements in a replacement range

- **InjectionPointFinder**: New class for finding injection points by matching criteria
  - `find` to locate a single injection point by type/text pattern
  - `find_all` to locate all matching injection points
  - Works with any `*-merge` gem (prism-merge, markly-merge, psych-merge, etc.)

- **SmartMergerBase**: `add_template_only_nodes` now accepts a callable filter
  - Boolean `true`/`false` still works as before (add all or none)
  - Callable (Proc/Lambda) receives `(node, entry)` and returns truthy to add the node
  - Enables selective addition of template-only nodes based on signature, type, or content
  - Example use case: Add missing link reference definitions while skipping other template content
  - Entry hash includes `:template_node`, `:signature`, `:template_index` for filtering decisions

- **ContentMatchRefiner**: New match refiner for fuzzy text content matching
  - Uses Levenshtein distance to pair nodes with similar (but not identical) text
  - Configurable scoring weights for content similarity, length, and position
  - Custom content extractor support for parser-specific text extraction
  - Node type filtering to limit which types are processed
  - Can be combined with other refiners (e.g., TableMatchRefiner)
  - Useful for matching paragraphs, headings, comments with minor edits

- **SmartMergerBase**: Added validity check after FileAnalysis creation
  - Checks `valid?` after creating FileAnalysis and raises appropriate parse error if invalid
  - Catches silent failures like grammar not available or parse errors
  - Documented the FileAnalysis error handling pattern for all *-merge gems

- **SmartMergerBase**: Added explicit `node_typing` parameter
  - All child SmartMergers were already using `node_typing` via `**format_options`
  - Now explicitly documented and accessible via `attr_reader :node_typing`
  - Validates node_typing configuration via `NodeTyping.validate!` if provided
  - Enables per-node-type merge preferences across all `*-merge` gems

- **ConflictResolverBase**: Added `match_refiner` parameter and `**options` for forward compatibility
  - All batch-strategy resolvers were storing `match_refiner` locally
  - Now explicitly accepted in base class with `attr_reader :match_refiner`
  - Added `**options` catch-all for future parameters without breaking child classes

- **MergeResultBase**: Added `**options` for forward compatibility
  - Allows subclasses to accept new parameters without modification
  - Maintains backward compatibility with existing no-arg and keyword-arg constructors

- **RBS Signatures**: Added comprehensive type signatures for base classes
  - `SmartMergerBase` with all standard options and abstract method declarations
  - `ConflictResolverBase` with strategy-based resolution methods
  - `MergeResultBase` with unified constructor and decision tracking
  - `MatchRefinerBase` with similarity computation interface
  - `RegionMergeable` module for nested content merging
  - `NodeTyping` module with `Wrapper` class for typed nodes
  - Type aliases: `node_typing_callable`, `node_typing_hash`, `preference_type`

- **Documentation**: Updated README with comprehensive base class documentation
  - Standard options table with all `SmartMergerBase` parameters
  - Forward compatibility section explaining the `**options` pattern
  - Complete "Creating a New Merge Gem" example with all base classes
  - Base Classes Reference table

### Changed

- **BREAKING - Namespace Reorganization**: Major restructuring for better organization
  - `Ast::Merge::Region` → `Ast::Merge::Detector::Region` (Struct moved into Detector namespace)
  - `Ast::Merge::RegionDetectorBase` → `Ast::Merge::Detector::Base`
  - `Ast::Merge::RegionMergeable` → `Ast::Merge::Detector::Mergeable`
  - `Ast::Merge::FencedCodeBlockDetector` → `Ast::Merge::Detector::FencedCodeBlock`
  - `Ast::Merge::YamlFrontmatterDetector` → `Ast::Merge::Detector::YamlFrontmatter`
  - `Ast::Merge::TomlFrontmatterDetector` → `Ast::Merge::Detector::TomlFrontmatter`
  - `Ast::Merge::Recipe` class → `Ast::Merge::Recipe::Config`
  - `Ast::Merge::RecipeRunner` → `Ast::Merge::Recipe::Runner`
  - `Ast::Merge::RecipeScriptLoader` → `Ast::Merge::Recipe::ScriptLoader`
  - `Ast::Merge::RegionMergeable::RegionConfig` → `Ast::Merge::Detector::Mergeable::Config`
  - `Ast::Merge::RegionMergeable::ExtractedRegion` → `Ast::Merge::Detector::Mergeable::ExtractedRegion`

## [1.1.0] - 2025-12-18

- TAG: [v1.1.0][1.1.0t]
- COVERAGE: 95.16% -- 2338/2457 lines in 44 files
- BRANCH COVERAGE: 82.59% -- 517/626 branches in 44 files
- 98.45% documented

### Added

- **tree_haver Integration**: Major architectural enhancement
  - Added `tree_haver` (~> 3.1) as a runtime dependency
  - `Ast::Merge::AstNode` now implements the TreeHaver::Node protocol for compatibility with tree_haver-based merge operations
    - Adds: `type`, `kind`, `text`, `start_byte`, `end_byte`, `start_point`, `end_point`, `children`, `child_count`, `child(index)`, `each`, `named?`, `structural?`, `has_error?`, `missing?`, `inner_node`
    - Adds `Point` struct compatible with `TreeHaver::Point`
    - Adds `SyntheticNode` alias for clarity (synthetic = not backed by a real parser)
  - `Comment::Line`, `Comment::Block`, `Comment::Empty` now have explicit `type` methods
  - `Text::LineNode` and `Text::WordNode` now inherit from `AstNode`, gaining TreeHaver::Node protocol compliance
  - This enables `*-merge` gems to leverage tree_haver's cross-Ruby parsing capabilities (MRI, JRuby, TruffleRuby)
- **Documentation**: Comprehensive updates across the gem family
  - Updated all vendor gem READMEs with standardized gem family tables
  - Added `tree_haver` as the foundation layer in architecture documentation
  - Clarified the two-layer architecture: tree_haver (parsing) → ast-merge (merge infrastructure)
  - Added detailed documentation to `FencedCodeBlockDetector` explaining when to use native AST nodes vs text-based detection
  - Updated markdown-merge documentation to highlight inner code block merging capabilities
- **Example Scripts**: Added comprehensive examples demonstrating inner-merge capabilities
  - `examples/markdown_code_merge.rb` - Shows how markdown-merge delegates to language-specific parsers for semantic merging
  - Documentation proving that language-specific parsers create full ASTs of embedded code blocks

### Changed

- **Architecture**: Refactored to use tree_haver as the parsing foundation
  - All tree-sitter-based gems (bash-merge, json-merge, jsonc-merge, toml-merge) now use tree_haver
  - Parser-specific gems (prism-merge, psych-merge, markdown-merge, markly-merge, commonmarker-merge) use tree_haver backends
  - Provides unified API across different Ruby implementations and parsing backends
- **Documentation Structure**: Standardized gem family tables across all 12 vendor gems
  - Changed from 3-column to 4-column format: Gem | Format | Parser Backend(s) | Description
  - All parser backends now annotated with "(via tree_haver)" where applicable
  - ast-merge description updated from "Shared infrastructure" to "**Infrastructure**: Shared base classes and merge logic"
  - markdown-merge description updated to "**Foundation**: Shared base for Markdown mergers with inner code block merging"
- **Configuration Documentation**: Enhanced backend selection documentation

### Fixed

- Fixed gemspec and Appraisals alignment with tree_haver requirements
- Fixed CI workflow conditions and retry logic
- Fixed badge rendering in documentation
- Fixed README structure issues (removed H3 duplicates, standardized gem family tables)

## [1.0.0] - 2025-12-12

- TAG: [v1.0.0][1.0.0t]
- COVERAGE: 96.60% -- 2301/2382 lines in 44 files
- BRANCH COVERAGE: 86.00% -- 522/607 branches in 44 files
- 99.29% documented

### Added

- Initial release

[Unreleased]: https://github.com/kettle-rb/ast-merge/compare/v4.0.3...HEAD
[4.0.3]: https://github.com/kettle-rb/ast-merge/compare/v4.0.2...v4.0.3
[4.0.3t]: https://github.com/kettle-rb/ast-merge/releases/tag/v4.0.3
[4.0.2]: https://github.com/kettle-rb/ast-merge/compare/v4.0.1...v4.0.2
[4.0.2t]: https://github.com/kettle-rb/ast-merge/releases/tag/v4.0.2
[4.0.1]: https://github.com/kettle-rb/ast-merge/compare/v4.0.0...v4.0.1
[4.0.1t]: https://github.com/kettle-rb/ast-merge/releases/tag/v4.0.1
[4.0.0]: https://github.com/kettle-rb/ast-merge/compare/v3.1.0...v4.0.0
[4.0.0t]: https://github.com/kettle-rb/ast-merge/releases/tag/v4.0.0
[3.1.0]: https://github.com/kettle-rb/ast-merge/compare/v3.0.0...v3.1.0
[3.1.0t]: https://github.com/kettle-rb/ast-merge/releases/tag/v3.1.0
[3.0.0]: https://github.com/kettle-rb/ast-merge/compare/v2.0.10...v3.0.0
[3.0.0t]: https://github.com/kettle-rb/ast-merge/releases/tag/v3.0.0
[2.0.10]: https://github.com/kettle-rb/ast-merge/compare/v2.0.9...v2.0.10
[2.0.10t]: https://github.com/kettle-rb/ast-merge/releases/tag/v2.0.10
[2.0.9]: https://github.com/kettle-rb/ast-merge/compare/v2.0.8...v2.0.9
[2.0.9t]: https://github.com/kettle-rb/ast-merge/releases/tag/v2.0.9
[2.0.8]: https://github.com/kettle-rb/ast-merge/compare/v2.0.7...v2.0.8
[2.0.8t]: https://github.com/kettle-rb/ast-merge/releases/tag/v2.0.8
[2.0.7]: https://github.com/kettle-rb/ast-merge/compare/v2.0.6...v2.0.7
[2.0.7t]: https://github.com/kettle-rb/ast-merge/releases/tag/v2.0.7
[2.0.6]: https://github.com/kettle-rb/ast-merge/compare/v2.0.5...v2.0.6
[2.0.6t]: https://github.com/kettle-rb/ast-merge/releases/tag/v2.0.6
[2.0.5]: https://github.com/kettle-rb/ast-merge/compare/v2.0.4...v2.0.5
[2.0.5t]: https://github.com/kettle-rb/ast-merge/releases/tag/v2.0.5
[2.0.4]: https://github.com/kettle-rb/ast-merge/compare/v2.0.3...v2.0.4
[2.0.4t]: https://github.com/kettle-rb/ast-merge/releases/tag/v2.0.4
[2.0.3]: https://github.com/kettle-rb/ast-merge/compare/v2.0.2...v2.0.3
[2.0.3t]: https://github.com/kettle-rb/ast-merge/releases/tag/v2.0.3
[2.0.2]: https://github.com/kettle-rb/ast-merge/compare/v2.0.1...v2.0.2
[2.0.2t]: https://github.com/kettle-rb/ast-merge/releases/tag/v2.0.2
[2.0.1]: https://github.com/kettle-rb/ast-merge/compare/v2.0.0...v2.0.1
[2.0.1t]: https://github.com/kettle-rb/ast-merge/releases/tag/v2.0.1
[2.0.0]: https://github.com/kettle-rb/ast-merge/compare/v1.1.0...v2.0.0
[2.0.0t]: https://github.com/kettle-rb/ast-merge/releases/tag/v2.0.0
[1.1.0]: https://github.com/kettle-rb/ast-merge/compare/v1.0.0...v1.1.0
[1.1.0t]: https://github.com/kettle-rb/ast-merge/releases/tag/v1.1.0
[1.0.0]: https://github.com/kettle-rb/ast-merge/compare/a63a4858cb229530c1706925bb209546695e8b3a...v1.0.0
[1.0.0t]: https://github.com/kettle-rb/ast-merge/tags/v1.0.0
