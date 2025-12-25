# TODO: Standardize `**options` Pattern Across Merge Gems

## Overview

All merge gems have classes that inherit from `Ast::Merge` base classes. These child classes need to:
1. Follow the `**options` pattern for forward compatibility
2. Document which base options are not supported and why
3. Identify shared features that could be extracted to `ast-merge`

## Phase 1: Inventory Base Classes in `ast-merge`

### Task 1.1: Analyze `Ast::Merge::SmartMergerBase` ✅

**Location:** `lib/ast/merge/smart_merger_base.rb` (418 lines)

**Standard Options in `#initialize`:**
```ruby
def initialize(
  template_content,           # Required: String
  dest_content,               # Required: String
  signature_generator: nil,   # Proc or nil - custom signature generation
  preference: :destination,   # Symbol or Hash - :destination, :template, or per-type Hash
  add_template_only_nodes: false,  # Boolean
  freeze_token: nil,          # String or nil - defaults to default_freeze_token
  match_refiner: nil,         # #call or nil - for fuzzy matching
  regions: nil,               # Array<Hash> or nil - nested region configs
  region_placeholder: nil,    # String or nil - defaults to "<<<AST_MERGE_REGION_"
  **format_options            # ✅ Catch-all for format-specific options
)
```

**Abstract Methods (MUST implement):**
- `analysis_class` - Returns the FileAnalysis class for this format
- `perform_merge` - Performs the format-specific merge logic

**Optional Override Hooks:**
- `default_freeze_token` - Returns format-specific freeze token (default: "ast-merge")
- `resolver_class` - Returns ConflictResolver class (default: nil)
- `result_class` - Returns MergeResult class (default: nil)
- `aligner_class` - Returns FileAligner class (default: nil)
- `build_analysis_options` - Additional options for FileAnalysis (default: {})
- `build_resolver_options` - Additional options for ConflictResolver (default: {})
- `build_full_analysis_options` - Complete control over analysis options
- `update_result_content(result, content)` - Update result after region substitution
- `template_parse_error_class` - Custom error class (default: TemplateParseError)
- `destination_parse_error_class` - Custom error class (default: DestinationParseError)

**Includes:** `RegionMergeable` module

### Task 1.2: Analyze `Ast::Merge::FileAnalysisBase` ❌ DOES NOT EXIST
- No base class exists for FileAnalysis
- Each gem implements its own FileAnalysis independently
- **Recommendation:** Consider creating `FileAnalysisBase` with common interface

### Task 1.3: Analyze `Ast::Merge::ConflictResolverBase` ✅

**Location:** `lib/ast/merge/conflict_resolver_base.rb` (400 lines)

**Constructor Signature:**
```ruby
def initialize(
  strategy:,              # Required: :node, :batch, or :boundary
  preference:,            # Required: Symbol or Hash
  template_analysis:,     # Required: Analysis object
  dest_analysis:,         # Required: Analysis object
  add_template_only_nodes: false  # Boolean
)
# ⚠️ Does NOT use **options pattern - all params explicit
```

**Three Resolution Strategies:**
- `:node` - Per-node resolution (calls `resolve_node_pair`)
- `:batch` - Batch resolution (calls `resolve_batch`)
- `:boundary` - Boundary resolution (calls `resolve_boundary`)

**Decision Constants:**
- `DECISION_DESTINATION`, `DECISION_TEMPLATE`, `DECISION_ADDED`
- `DECISION_FROZEN`, `DECISION_IDENTICAL`, `DECISION_KEPT_DEST`
- `DECISION_KEPT_TEMPLATE`, `DECISION_APPENDED`, `DECISION_FREEZE_BLOCK`
- `DECISION_RECURSIVE`, `DECISION_REPLACED`

### Task 1.4: Analyze other base classes ✅

#### `Ast::Merge::MergeResultBase`
**Location:** `lib/ast/merge/merge_result_base.rb` (170 lines)

**Constructor Signature:**
```ruby
def initialize(
  template_analysis: nil,
  dest_analysis: nil,
  conflicts: [],
  frozen_blocks: [],
  stats: {}
)
# ⚠️ Does NOT use **options pattern - all params explicit with defaults
```

**Decision Constants:** Same as ConflictResolverBase

#### `Ast::Merge::DebugLogger` (module, not class)
**Location:** `lib/ast/merge/debug_logger.rb` (276 lines)

- Module designed to be `extend`ed by child modules
- Configurable via `env_var_name` and `log_prefix` accessors
- No constructor - module methods only
- Child modules override via singleton methods (`def self.method_name`)

#### `Ast::Merge::RegionMergeable` (module)
**Location:** `lib/ast/merge/region_mergeable.rb` (365 lines)

- Mixin for SmartMerger classes
- `setup_regions(regions:, region_placeholder:)` - main entry point
- Provides `RegionConfig` and `ExtractedRegion` structs
- Handles extraction, placeholder substitution, nested regions

#### `Ast::Merge::FreezeNodeBase`
**Location:** `lib/ast/merge/freeze_node_base.rb` (435 lines)

- Base class for freeze block nodes
- Includes `Freezable` module
- Constructor varies by subclass - not standardized
- Configurable marker patterns (`:hash_comment`, `:html_comment`, etc.)

#### `Ast::Merge::MatchRefinerBase`
**Location:** `lib/ast/merge/match_refiner_base.rb` (313 lines)

**Constructor Signature:**
```ruby
def initialize(**options)  # ✅ Uses **options pattern
```

- Implements `#call(template_nodes, dest_nodes, context = {})` interface
- Provides helper methods: `greedy_match`, `find_best_match`, `filter_by_type`
- Used for fuzzy matching after signature-based matching

#### `Ast::Merge::RegionDetectorBase`
**Location:** `lib/ast/merge/region_detector_base.rb` (115 lines)

- No constructor (uses defaults)
- Abstract methods: `region_type`, `detect_all(source)`
- Optional override: `strip_delimiters?`, `name`

#### `Ast::Merge::MatchScoreBase`
**Location:** `lib/ast/merge/match_score_base.rb`

- Data class for match scoring results
- Used by MatchRefinerBase implementations

---

## Phase 2: Audit Each Merge Gem's SmartMerger

For each gem, check:
- Does it inherit from `SmartMergerBase`?
- Does it pass `**options` to `super()`?
- Which base options does it NOT support?
- Does it have unique options that could be generalized?

### Task 2.1: `markdown-merge` - `Markdown::Merge::SmartMerger` ✅

**Inheritance:** `SmartMerger < SmartMergerBase` (has its own `SmartMergerBase` in markdown-merge!)

**⚠️ ISSUE:** `markdown-merge` has its own `Markdown::Merge::SmartMergerBase` that does NOT inherit from `Ast::Merge::SmartMergerBase`. This is a separate implementation.

**Constructor:**
```ruby
def initialize(
  template_content,
  dest_content,
  backend: Backends::AUTO,
  signature_generator: nil,
  preference: :destination,
  add_template_only_nodes: false,
  inner_merge_code_blocks: false,
  freeze_token: FileAnalysis::DEFAULT_FREEZE_TOKEN,
  match_refiner: nil,
  node_typing: nil,
  **parser_options           # ✅ Uses **options pattern
)
```

**Unique Options:**
- `backend` - `:commonmarker`, `:markly`, or `:auto`
- `inner_merge_code_blocks` - Boolean or `CodeBlockMerger` instance

**Missing from Base:** Does NOT pass to `Ast::Merge::SmartMergerBase` - has own base class

### Task 2.2: `markly-merge` - `Markly::Merge::SmartMerger` ✅

**Inheritance:** `SmartMerger < Markdown::Merge::SmartMerger`

**Constructor:**
```ruby
def initialize(
  template_content,
  dest_content,
  signature_generator: nil,
  preference: :destination,
  add_template_only_nodes: false,
  inner_merge_code_blocks: DEFAULT_INNER_MERGE_CODE_BLOCKS,
  freeze_token: DEFAULT_FREEZE_TOKEN,
  flags: ::Markly::DEFAULT,
  extensions: [:table],
  match_refiner: nil,
  node_typing: nil
)
# ⚠️ Does NOT use **options - all params explicit
```

**Unique Options:**
- `flags` - Markly parse flags (e.g., `Markly::FOOTNOTES`)
- `extensions` - Array of symbols (`:table`, `:strikethrough`, etc.)

**Issues:**
- ⚠️ Does NOT use `**options` pattern - explicit params only
- Forces `backend: :markly` when calling super

### Task 2.3: `commonmarker-merge` - `Commonmarker::Merge::SmartMerger` ✅

**Inheritance:** `SmartMerger < Markdown::Merge::SmartMerger`

**Constructor:**
```ruby
def initialize(
  template_content,
  dest_content,
  signature_generator: nil,
  preference: :destination,
  add_template_only_nodes: false,
  freeze_token: DEFAULT_FREEZE_TOKEN,
  options: {},
  match_refiner: nil,
  node_typing: nil
)
# ⚠️ Does NOT use **options - all params explicit
```

**Unique Options:**
- `options` - CommonMarker parse options hash

**Issues:**
- ⚠️ Does NOT use `**options` pattern
- Missing `inner_merge_code_blocks` in constructor (hardcoded to default)
- Forces `backend: :commonmarker` when calling super

### Task 2.4: `prism-merge` - `Prism::Merge::SmartMerger` ✅

**Inheritance:** `SmartMerger < ::Ast::Merge::SmartMergerBase` ✅

**Constructor:**
```ruby
def initialize(
  template_content,
  dest_content,
  signature_generator: nil,
  preference: :destination,
  add_template_only_nodes: false,
  freeze_token: nil,
  node_typing: nil,
  max_recursion_depth: Float::INFINITY,
  current_depth: 0,
  match_refiner: nil,
  regions: nil,
  region_placeholder: nil,
  text_merger_options: nil
)
# ⚠️ Does NOT use **options - all params explicit
```

**Unique Options:**
- `node_typing` - Hash for per-node-type preferences
- `max_recursion_depth` - Safety limit for recursive merging
- `current_depth` - Internal tracking for recursion
- `text_merger_options` - Options for comment-only file handling

**Issues:**
- ⚠️ Does NOT use `**options` pattern
- Does NOT use aligner/resolver (custom implementation)

### Task 2.5: `toml-merge` - `Toml::Merge::SmartMerger` ✅

**Inheritance:** `SmartMerger < ::Ast::Merge::SmartMergerBase` ✅

**Constructor:**
```ruby
def initialize(
  template_content,
  dest_content,
  signature_generator: nil,
  preference: :destination,
  add_template_only_nodes: false,
  freeze_token: nil,
  match_refiner: nil,
  regions: nil,
  region_placeholder: nil,
  node_typing: nil
)
# ⚠️ Does NOT use **options - all params explicit
```

**Issues:**
- ⚠️ Does NOT use `**options` pattern
- Passes `node_typing` to super but SmartMergerBase doesn't accept it!

### Task 2.6: `json-merge` - `Json::Merge::SmartMerger` ✅

**Inheritance:** `SmartMerger < ::Ast::Merge::SmartMergerBase` ✅

**Constructor:** Same pattern as toml-merge

**Issues:**
- ⚠️ Does NOT use `**options` pattern
- Passes `node_typing` to super (but SmartMergerBase doesn't have this param)

### Task 2.7: `jsonc-merge` - `Jsonc::Merge::SmartMerger` ✅

**Inheritance:** `SmartMerger < ::Ast::Merge::SmartMergerBase` ✅

**Constructor:** Same pattern as json-merge

**Issues:**
- ⚠️ Does NOT use `**options` pattern

### Task 2.8: `psych-merge` - `Psych::Merge::SmartMerger` ✅

**Inheritance:** `SmartMerger < ::Ast::Merge::SmartMergerBase` ✅

**Constructor:**
```ruby
def initialize(
  template_content,
  dest_content,
  signature_generator: nil,
  preference: :destination,
  add_template_only_nodes: false,
  freeze_token: FileAnalysis::DEFAULT_FREEZE_TOKEN,
  match_refiner: nil,
  regions: nil,
  region_placeholder: nil,
  node_typing: nil
)
# ⚠️ Does NOT use **options - all params explicit
```

**Issues:**
- ⚠️ Does NOT use `**options` pattern

### Task 2.9: `dotenv-merge` - `Dotenv::Merge::SmartMerger` ✅

**Inheritance:** `SmartMerger < ::Ast::Merge::SmartMergerBase` ✅

**Constructor:** Same pattern as psych-merge

**Issues:**
- ⚠️ Does NOT use `**options` pattern

### Task 2.10: `bash-merge` - `Bash::Merge::SmartMerger` ✅

**Inheritance:** `SmartMerger < ::Ast::Merge::SmartMergerBase` ✅

**Constructor:** Same pattern as psych-merge

**Issues:**
- ⚠️ Does NOT use `**options` pattern

### Task 2.11: `rbs-merge` - `Rbs::Merge::SmartMerger` ✅

**Inheritance:** `SmartMerger < ::Ast::Merge::SmartMergerBase` ✅

**Constructor:**
```ruby
def initialize(
  template_content,
  dest_content,
  signature_generator: nil,
  preference: :destination,
  add_template_only_nodes: false,
  freeze_token: nil,
  match_refiner: nil,
  regions: nil,
  region_placeholder: nil,
  node_typing: nil,
  max_recursion_depth: Float::INFINITY
)
# ⚠️ Does NOT use **options - all params explicit
```

**Unique Options:**
- `max_recursion_depth` - Like prism-merge

**Issues:**
- ⚠️ Does NOT use `**options` pattern

---

## Phase 2 Summary

### Inheritance Patterns Found

| Gem | Inherits From | Uses `**options`? |
|-----|---------------|-------------------|
| markdown-merge | Own `SmartMergerBase` | ✅ Yes (`**parser_options`) |
| markly-merge | `Markdown::Merge::SmartMerger` | ❌ No |
| commonmarker-merge | `Markdown::Merge::SmartMerger` | ❌ No |
| prism-merge | `Ast::Merge::SmartMergerBase` | ❌ No |
| toml-merge | `Ast::Merge::SmartMergerBase` | ❌ No |
| json-merge | `Ast::Merge::SmartMergerBase` | ❌ No |
| jsonc-merge | `Ast::Merge::SmartMergerBase` | ❌ No |
| psych-merge | `Ast::Merge::SmartMergerBase` | ❌ No |
| dotenv-merge | `Ast::Merge::SmartMergerBase` | ❌ No |
| bash-merge | `Ast::Merge::SmartMergerBase` | ❌ No |
| rbs-merge | `Ast::Merge::SmartMergerBase` | ❌ No |

### Common Options Across All Gems
All gems support these options:
- `template_content`, `dest_content` (required)
- `signature_generator`
- `preference`
- `add_template_only_nodes`
- `freeze_token`
- `match_refiner`

### Options NOT in SmartMergerBase but Used by Multiple Gems
- `node_typing` - Used by: prism, toml, json, jsonc, psych, dotenv, bash, rbs, markdown, markly, commonmarker
- `max_recursion_depth` - Used by: prism, rbs
- `inner_merge_code_blocks` - Used by: markdown, markly, commonmarker

### Recommendations from Phase 2

1. **Add `node_typing` to `SmartMergerBase`** - It's used by ALL gems
2. **Add `**options` pattern to ALL child SmartMergers** for forward compatibility
3. **Consider adding `max_recursion_depth` to `SmartMergerBase`** - Used by multiple gems
4. **Fix markdown-merge hierarchy** - Should extend `Ast::Merge::SmartMergerBase`

---

## Phase 3: Audit Each Merge Gem's FileAnalysis

All FileAnalysis classes include `Ast::Merge::FileAnalyzable` module which provides:
- Common attr_readers: `source`, `lines`, `freeze_token`, `signature_generator`
- Methods: `statements`, `freeze_blocks`, `in_freeze_block?`, `freeze_block_at`, `signature_at`, `generate_signature`

### Task 3.1: `markdown-merge` - `Markdown::Merge::FileAnalysisBase` ✅

**Includes:** `Ast::Merge::FileAnalyzable`

**Constructor:**
```ruby
def initialize(source, freeze_token: DEFAULT_FREEZE_TOKEN, signature_generator: nil, **parser_options)
# ✅ Uses **parser_options pattern
```

**Unique:**
- Has its own `FileAnalysisBase` (not from ast-merge)
- Abstract class - subclassed by backend-specific implementations
- Subclass `FileAnalysis` wraps with backend detection

### Task 3.2: `prism-merge` - `Prism::Merge::FileAnalysis` ✅

**Includes:** `Ast::Merge::FileAnalyzable`

**Constructor:**
```ruby
def initialize(source, freeze_token: DEFAULT_FREEZE_TOKEN, signature_generator: nil)
# ⚠️ Does NOT use **options pattern - all params explicit
```

**Issues:**
- ⚠️ No `**options` pattern - cannot accept new options without breaking

### Task 3.3: `toml-merge` - `Toml::Merge::FileAnalysis` ✅

**Includes:** `Ast::Merge::FileAnalyzable`

**Constructor:**
```ruby
def initialize(source, signature_generator: nil, parser_path: nil, **options)
# ✅ Uses **options pattern
```

**Notes:**
- Does NOT use `freeze_token` (TOML has no comment syntax for freeze markers)
- `parser_path` - tree-sitter parser library path

### Task 3.4: `json-merge` - `Json::Merge::FileAnalysis` ✅

**Includes:** `Ast::Merge::FileAnalyzable`

**Constructor:**
```ruby
def initialize(source, signature_generator: nil, parser_path: nil, **options)
# ✅ Uses **options pattern
```

**Notes:**
- Does NOT use `freeze_token` (standard JSON has no comments)
- Same pattern as toml-merge

### Task 3.5: `jsonc-merge` - `Jsonc::Merge::FileAnalysis` ✅

**Includes:** `Ast::Merge::FileAnalyzable`

**Constructor:**
```ruby
def initialize(source, freeze_token: DEFAULT_FREEZE_TOKEN, signature_generator: nil, parser_path: nil, **options)
# ✅ Uses **options pattern
```

**Notes:**
- DOES use `freeze_token` (JSONC supports comments)
- Has `CommentTracker` for comment handling

### Task 3.6: `psych-merge` - `Psych::Merge::FileAnalysis` ✅

**Includes:** `Ast::Merge::FileAnalyzable`

**Constructor:**
```ruby
def initialize(source, freeze_token: DEFAULT_FREEZE_TOKEN, signature_generator: nil, **options)
# ✅ Uses **options pattern
```

**Notes:**
- Has `CommentTracker` for comment handling
- Supports freeze blocks via YAML comments

### Task 3.7: `bash-merge` - `Bash::Merge::FileAnalysis` ✅

**Includes:** `Ast::Merge::FileAnalyzable`

**Constructor:**
```ruby
def initialize(source, freeze_token: DEFAULT_FREEZE_TOKEN, signature_generator: nil, parser_path: nil, **options)
# ✅ Uses **options pattern
```

**Notes:**
- Uses tree-sitter-bash via TreeHaver
- Has `CommentTracker` for comment handling

### Task 3.8: `dotenv-merge` - `Dotenv::Merge::FileAnalysis` ✅

**Includes:** `Ast::Merge::FileAnalyzable`

**Constructor:**
```ruby
def initialize(source, freeze_token: DEFAULT_FREEZE_TOKEN, signature_generator: nil, **options)
# ✅ Uses **options pattern
```

**Notes:**
- Custom line-based parsing (no external parser)
- Has `EnvLine` for parsed lines

### Task 3.9: `rbs-merge` - `Rbs::Merge::FileAnalysis` ✅

**Includes:** `Ast::Merge::FileAnalyzable`

**Constructor:**
```ruby
def initialize(source, freeze_token: DEFAULT_FREEZE_TOKEN, signature_generator: nil, **options)
# ✅ Uses **options pattern
```

**Notes:**
- Uses `RBS::Parser` for parsing

---

## Phase 3 Summary

### `**options` Pattern Usage in FileAnalysis

| Gem | Uses `**options`? | Notes |
|-----|-------------------|-------|
| markdown-merge | ✅ Yes (`**parser_options`) | Has own FileAnalysisBase |
| prism-merge | ❌ No | Only explicit params |
| toml-merge | ✅ Yes | No freeze_token |
| json-merge | ✅ Yes | No freeze_token |
| jsonc-merge | ✅ Yes | With freeze_token |
| psych-merge | ✅ Yes | - |
| bash-merge | ✅ Yes | - |
| dotenv-merge | ✅ Yes | - |
| rbs-merge | ✅ Yes | - |

### Common Interface (from FileAnalyzable)
All FileAnalysis classes share these attributes/methods:
- `source` - Original source string
- `lines` - Array of lines
- `freeze_token` - Token for freeze markers
- `signature_generator` - Custom signature proc
- `statements` - All top-level nodes
- `freeze_blocks` - Freeze block nodes
- `generate_signature(node)` - Signature for matching

### Recommendations from Phase 3

1. **Add `**options` to `Prism::Merge::FileAnalysis`** - Only FileAnalysis missing it
2. **Standardize `freeze_token` handling** - json-merge and toml-merge don't use it because their formats don't support comments, but should still accept it for consistency
3. **Consider documenting which formats support freeze blocks** - Not all do

---

## Phase 4: Audit Other Inheriting Classes

### Task 4.1: ConflictResolver classes ✅

All ConflictResolver classes inherit from `Ast::Merge::ConflictResolverBase`.

| Gem | Inherits From | Strategy | Constructor Pattern |
|-----|---------------|----------|---------------------|
| toml-merge | `Ast::Merge::ConflictResolverBase` | `:batch` | Positional + keyword args, no `**options` |
| json-merge | `Ast::Merge::ConflictResolverBase` | `:batch` | Positional + keyword args, no `**options` |
| jsonc-merge | `Ast::Merge::ConflictResolverBase` | `:batch` | Positional + keyword args, no `**options` |
| psych-merge | `Ast::Merge::ConflictResolverBase` | `:batch` | Positional + keyword args, no `**options` |
| bash-merge | `Ast::Merge::ConflictResolverBase` | `:batch` | Positional + keyword args, no `**options` |
| rbs-merge | `Ast::Merge::ConflictResolverBase` | `:node` | All keyword args, no `**options` |
| markdown-merge | `Ast::Merge::ConflictResolverBase` | `:node` | All keyword args, no `**options` |
| prism-merge | N/A | Custom | No resolver (custom merge logic) |
| dotenv-merge | N/A | Custom | No resolver (custom merge logic) |

**Common Constructor Pattern (batch strategy):**
```ruby
def initialize(template_analysis, dest_analysis, preference: :destination, add_template_only_nodes: false, match_refiner: nil)
  super(
    strategy: :batch,
    preference: preference,
    template_analysis: template_analysis,
    dest_analysis: dest_analysis,
    add_template_only_nodes: add_template_only_nodes
  )
  @match_refiner = match_refiner
end
# ⚠️ Does NOT use **options - stores match_refiner separately
```

**Issues:**
- ⚠️ None use `**options` pattern
- `match_refiner` is stored locally, not passed to super
- Base class doesn't accept `match_refiner` option

### Task 4.2: MergeResult classes ✅

All MergeResult classes inherit from `Ast::Merge::MergeResultBase`.

| Gem | Inherits From | Constructor |
|-----|---------------|-------------|
| toml-merge | `Ast::Merge::MergeResultBase` | `def initialize` (no args) |
| json-merge | `Ast::Merge::MergeResultBase` | `def initialize` (no args) |
| jsonc-merge | `Ast::Merge::MergeResultBase` | `def initialize` (no args) |
| psych-merge | `Ast::Merge::MergeResultBase` | `def initialize` (no args) |
| bash-merge | `Ast::Merge::MergeResultBase` | `def initialize` (no args) |
| rbs-merge | `Ast::Merge::MergeResultBase` | `def initialize` (no args) |
| prism-merge | `Ast::Merge::MergeResultBase` | `def initialize` (no args) |
| dotenv-merge | `Ast::Merge::MergeResultBase` | `def initialize(template_analysis, dest_analysis)` |
| markdown-merge | `Ast::Merge::MergeResultBase` | `def initialize(content:, conflicts:, frozen_blocks:, stats:)` |

**Issues:**
- Inconsistent constructor signatures
- Some use no-arg constructors, some use keyword args, some use positional args
- markdown-merge MergeResult stores `@content_raw` as string, not `@lines` array
- ⚠️ None use `**options` pattern

### Task 4.3: MatchRefiner classes ✅

All MatchRefiner classes inherit from `Ast::Merge::MatchRefinerBase`.

| Gem | Class | Inherits From | Uses `**options`? |
|-----|-------|---------------|-------------------|
| prism-merge | `MethodMatchRefiner` | `Ast::Merge::MatchRefinerBase` | ✅ Yes |
| toml-merge | `TableMatchRefiner` | `Ast::Merge::MatchRefinerBase` | ✅ Yes |
| markdown-merge | `TableMatchRefiner` | `Ast::Merge::MatchRefinerBase` | ✅ Yes |
| psych-merge | `MappingMatchRefiner` | `Ast::Merge::MatchRefinerBase` | ✅ Yes |
| json-merge | `ObjectMatchRefiner` | `Ast::Merge::MatchRefinerBase` | ✅ Yes |

**Constructor Pattern (all use `**options`):**
```ruby
def initialize(threshold: DEFAULT_THRESHOLD, weights: {}, **options)
  super(threshold: threshold, node_types: [:table], **options)
  @weights = DEFAULT_WEIGHTS.merge(weights)
end
# ✅ Uses **options pattern correctly
```

**Notes:**
- ✅ All MatchRefiner classes properly use `**options`
- Base class `MatchRefinerBase` already uses `**options`
- This is the model pattern for all classes

---

## Phase 4 Summary

### Classes Using `**options` Pattern

| Class Type | Uses `**options`? |
|------------|-------------------|
| SmartMerger (most gems) | ❌ No |
| FileAnalysis (most gems) | ✅ Yes |
| ConflictResolver (all gems) | ❌ No |
| MergeResult (all gems) | ❌ No |
| MatchRefiner (all gems) | ✅ Yes |

### Recommendations from Phase 4

1. **Add `**options` to all ConflictResolver constructors** for forward compatibility
2. **Add `**options` to all MergeResult constructors** for forward compatibility
3. **Add `match_refiner` to `ConflictResolverBase`** - all batch resolvers use it
4. **Standardize MergeResult constructors** - inconsistent signatures make inheritance difficult
5. **Consider making markdown-merge MergeResult use `@lines` pattern** like others

---

## Consolidated Summary & Action Items

### Overall Findings

| Class Type | Base Class | Uses `**options`? | Status |
|------------|------------|-------------------|--------|
| SmartMerger | `Ast::Merge::SmartMergerBase` | ✅ Base has it | ✅ All children updated |
| FileAnalysis | `Ast::Merge::FileAnalyzable` (module) | ✅ All have it | ✅ prism-merge fixed |
| ConflictResolver | `Ast::Merge::ConflictResolverBase` | ✅ Base updated | ✅ All children updated |
| MergeResult | `Ast::Merge::MergeResultBase` | ✅ Base updated | ✅ All children updated |
| MatchRefiner | `Ast::Merge::MatchRefinerBase` | ✅ All have it | ✅ Complete |

### Priority 1: Add `node_typing` to `SmartMergerBase` ✅ DONE

- Added explicit `node_typing` parameter to SmartMergerBase
- Added `attr_reader :node_typing`
- Validates via `NodeTyping.validate!` if provided
- Updated CHANGELOG

### Priority 2: Add `**options` to `ConflictResolverBase` ✅ DONE

- Added `match_refiner` parameter (was being stored locally by all children)
- Added `**options` catch-all
- Updated CHANGELOG

### Priority 3: Add `**options` to `MergeResultBase` ✅ DONE

- Added `**options` catch-all
- Updated CHANGELOG

### Priority 4: Add `**options` to All Child SmartMergers ✅ DONE

Updated all 10 child SmartMergers (markdown-merge already had it):
- ✅ `vendor/prism-merge/lib/prism/merge/smart_merger.rb`
- ✅ `vendor/toml-merge/lib/toml/merge/smart_merger.rb`
- ✅ `vendor/json-merge/lib/json/merge/smart_merger.rb`
- ✅ `vendor/jsonc-merge/lib/jsonc/merge/smart_merger.rb`
- ✅ `vendor/psych-merge/lib/psych/merge/smart_merger.rb`
- ✅ `vendor/dotenv-merge/lib/dotenv/merge/smart_merger.rb`
- ✅ `vendor/bash-merge/lib/bash/merge/smart_merger.rb`
- ✅ `vendor/rbs-merge/lib/rbs/merge/smart_merger.rb`
- ✅ `vendor/markly-merge/lib/markly/merge/smart_merger.rb`
- ✅ `vendor/commonmarker-merge/lib/commonmarker/merge/smart_merger.rb`

All CHANGELOGs updated.

### Priority 5: Add `**options` to `Prism::Merge::FileAnalysis` ✅ DONE

- Added `**options` to Prism::Merge::FileAnalysis
- Updated CHANGELOG

### Priority 6: Add `**options` to All Child ConflictResolvers ✅ DONE

Updated all 7 child ConflictResolvers:
- ✅ `vendor/toml-merge/lib/toml/merge/conflict_resolver.rb`
- ✅ `vendor/json-merge/lib/json/merge/conflict_resolver.rb`
- ✅ `vendor/jsonc-merge/lib/jsonc/merge/conflict_resolver.rb`
- ✅ `vendor/psych-merge/lib/psych/merge/conflict_resolver.rb`
- ✅ `vendor/bash-merge/lib/bash/merge/conflict_resolver.rb`
- ✅ `vendor/rbs-merge/lib/rbs/merge/conflict_resolver.rb`
- ✅ `vendor/markdown-merge/lib/markdown/merge/conflict_resolver.rb`

All CHANGELOGs updated.

### Priority 7: Add `**options` to All Child MergeResults ✅ DONE

Updated all 9 child MergeResults:
- ✅ `vendor/prism-merge/lib/prism/merge/merge_result.rb`
- ✅ `vendor/toml-merge/lib/toml/merge/merge_result.rb`
- ✅ `vendor/json-merge/lib/json/merge/merge_result.rb`
- ✅ `vendor/jsonc-merge/lib/jsonc/merge/merge_result.rb`
- ✅ `vendor/psych-merge/lib/psych/merge/merge_result.rb`
- ✅ `vendor/dotenv-merge/lib/dotenv/merge/merge_result.rb`
- ✅ `vendor/bash-merge/lib/bash/merge/merge_result.rb`
- ✅ `vendor/rbs-merge/lib/rbs/merge/merge_result.rb`
- ✅ `vendor/markdown-merge/lib/markdown/merge/merge_result.rb`

All CHANGELOGs updated.

---

## Documentation Needed

### Options Matrix Table (for README/docs)

| Option | SmartMergerBase | prism | markdown | toml | json | psych | bash | dotenv | rbs |
|--------|-----------------|-------|----------|------|------|-------|------|--------|-----|
| `signature_generator` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `preference` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `add_template_only_nodes` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `freeze_token` | ✅ | ✅ | ✅ | ❌* | ❌* | ✅ | ✅ | ✅ | ✅ |
| `match_refiner` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `regions` | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `region_placeholder` | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `node_typing` | ❌** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `max_recursion_depth` | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| `inner_merge_code_blocks` | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `backend` | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

\* Format doesn't support comments for freeze markers  
\*\* Should be added to base class

---

## Completed Phases

- [x] Phase 1: Inventory Base Classes in `ast-merge`
- [x] Phase 2: Audit Each Merge Gem's SmartMerger
- [x] Phase 3: Audit Each Merge Gem's FileAnalysis
- [x] Phase 4: Audit Other Inheriting Classes (ConflictResolver, MergeResult, MatchRefiner)
- [x] Phase 5: Identify Shared Features for Extraction
- [x] Phase 6: Implementation - All priorities (1-7) completed
  - Priority 1: Added `node_typing` to `SmartMergerBase`
  - Priority 2: Added `**options` and `match_refiner` to `ConflictResolverBase`
  - Priority 3: Added `**options` to `MergeResultBase`
  - Priority 4: Added `**options` to all 10 child SmartMergers
  - Priority 5: Added `**options` to `Prism::Merge::FileAnalysis`
  - Priority 6: Added `**options` to all 7 child ConflictResolvers
  - Priority 7: Added `**options` to all 9 child MergeResults
- [x] Phase 7: Documentation
  - Updated `sig/ast/merge.rbs` with comprehensive type signatures for all base classes
  - Updated README with Standard Options table
  - Added Forward Compatibility section explaining `**options` pattern
  - Updated "Creating a New Merge Gem" example with all base classes
  - Added Base Classes Reference table
  - Updated CHANGELOG with all changes

---

## Phase 5: Identify Shared Features for Extraction

Features that appear in multiple gems and could move to `ast-merge`:

### Task 5.1: `NodeTypeNormalizer` pattern ✅

**Currently in:** `markdown-merge`, `toml-merge`

**Pattern:** Both implement nearly identical `NodeTypeNormalizer` modules that:
- Map backend-specific node types to canonical types
- Support runtime registration of new backends via `register_backend`
- Use `Ast::Merge::NodeTyping::Wrapper` to wrap nodes
- Provide `canonical_type(type)` lookup method

**Differences:**
- markdown-merge: Maps commonmarker/markly types → canonical markdown types (heading, paragraph, code_block, etc.)
- toml-merge: Maps tree-sitter/citrus types → canonical TOML types (table, pair, array_of_tables, etc.)

**Recommendation:** ✅ **Extract to `ast-merge`**

Create `Ast::Merge::NodeTypeNormalizerBase` module with:
```ruby
module Ast::Merge::NodeTypeNormalizerBase
  def self.included(base)
    base.extend(ClassMethods)
    base.instance_variable_set(:@backend_mappings, {})
  end

  module ClassMethods
    def register_backend(name, mappings)
      @backend_mappings[name] = mappings.freeze
    end

    def canonical_type(raw_type, backend: nil)
      # Lookup logic
    end

    def table_type?(type)  # Format-specific, override in child
      false
    end
  end
end
```

**Files affected:**
- `vendor/markdown-merge/lib/markdown/merge/node_type_normalizer.rb` (216 lines)
- `vendor/toml-merge/lib/toml/merge/node_type_normalizer.rb` (293 lines)

### Task 5.2: `CommentTracker` pattern ✅

**Currently in:** `psych-merge`, `bash-merge`, `jsonc-merge`

**Pattern:** All three implement nearly identical `CommentTracker` classes that:
- Parse source to extract comments with line numbers
- Provide `comment_at(line_num)` lookup
- Provide `comments_in_range(range)` lookup
- Provide `leading_comments_before(line_num)` lookup
- Provide `inline_comment_at(line_num)` lookup
- Track full-line vs inline comments

**Differences:**
- psych-merge/bash-merge: Use `#` for comments (identical regex)
- jsonc-merge: Uses `//` and `/* */` for comments (different regex)

**Recommendation:** ✅ **Extract to `ast-merge`**

Create `Ast::Merge::CommentTrackerBase` class with:
```ruby
class Ast::Merge::CommentTrackerBase
  attr_reader :comments, :lines

  def initialize(source)
    @source = source
    @lines = source.lines.map(&:chomp)
    @comments = extract_comments
    @comments_by_line = @comments.group_by { |c| c[:line] }
  end

  def comment_at(line_num)
    @comments_by_line[line_num]&.first
  end

  def comments_in_range(range)
    @comments.select { |c| range.cover?(c[:line]) }
  end

  def leading_comments_before(line_num)
    # Common implementation
  end

  def inline_comment_at(line_num)
    # Common implementation
  end

  protected

  # Abstract: subclasses implement format-specific comment extraction
  def extract_comments
    raise NotImplementedError
  end
end
```

**Subclasses:**
- `Ast::Merge::HashCommentTracker` - For `#` style (Ruby, YAML, Bash, Python, etc.)
- `Ast::Merge::CStyleCommentTracker` - For `//` and `/* */` style (JSONC, JS, etc.)

**Files affected:**
- `vendor/psych-merge/lib/psych/merge/comment_tracker.rb` (156 lines)
- `vendor/bash-merge/lib/bash/merge/comment_tracker.rb` (154 lines)
- `vendor/jsonc-merge/lib/jsonc/merge/comment_tracker.rb` (196 lines)

### Task 5.3: `node_typing` configuration ✅

**Currently in:** ALL merge gems pass `node_typing` option

**Status:** `Ast::Merge::NodeTyping` module already exists in ast-merge!

**Issue:** `SmartMergerBase` doesn't explicitly accept `node_typing` - it's only captured via `**format_options`

**Recommendation:** ✅ **Add explicit `node_typing` parameter to `SmartMergerBase`**

Already covered in Priority 1 action item.

### Task 5.4: `inner_merge_*` pattern ✅

**Currently in:** `markdown-merge` (CodeBlockMerger)

**Pattern:** `CodeBlockMerger` enables merging content inside fenced code blocks:
- Detects code block language (ruby, yaml, json, toml, etc.)
- Delegates to appropriate *-merge gem for that language
- Returns merged content to replace the code block

**Recommendation:** ⚠️ **Consider but defer**

This is currently markdown-specific. Could be generalized to:
- `Ast::Merge::InnerContentMerger` - Base class for merging nested content
- Allow any format to have "regions" that can be merged with different mergers

**Note:** The `regions` option in `SmartMergerBase` already provides similar functionality via `RegionMergeable`. The `CodeBlockMerger` could potentially use that infrastructure.

### Task 5.5: Comment-only file handling ✅

**Currently in:** `prism-merge` uses `Ast::Merge::Text::SmartMerger`

**Status:** `Ast::Merge::Text::SmartMerger` already exists in ast-merge!

**Pattern:** When prism-merge detects a file is comment-only (no Ruby code), it delegates to `Text::SmartMerger` for line-based merging.

**Recommendation:** ✅ **Document this pattern for other gems**

Other gems could benefit from similar fallback:
- `psych-merge`: Comment-only YAML files
- `bash-merge`: Comment-only scripts
- `toml-merge`: Comment-only TOML files (if that makes sense)

### Task 5.6: `Emitter` pattern ✅

**Currently in:** `psych-merge`, `json-merge`, `jsonc-merge`, `bash-merge`

**Pattern:** Several gems have `Emitter` classes that convert merged AST back to source:
- Take nodes/lines and produce formatted output
- Handle indentation, newlines, formatting
- May preserve comments

**Differences:** Each format has different emission rules, so harder to generalize.

**Recommendation:** ⚠️ **No extraction** - Too format-specific

### Task 5.7: `NodeWrapper` pattern ✅

**Currently in:** `psych-merge`, `json-merge`, `jsonc-merge`, `toml-merge`, `bash-merge`

**Pattern:** Many gems have `NodeWrapper` classes that:
- Wrap parser-specific nodes with common interface
- Provide `start_line`, `end_line` methods
- Provide `type`, `children` methods
- Support signature generation

**Recommendation:** ⚠️ **Consider creating interface/protocol**

Could create `Ast::Merge::NodeWrapperInterface` module that defines the expected interface without implementation:
```ruby
module Ast::Merge::NodeWrapperInterface
  # Expected methods:
  # - start_line, end_line
  # - type
  # - children (optional)
  # - signature (optional)
end
```

This would document the contract without forcing implementation.

---

## Phase 5 Summary

### Features Ready for Extraction

| Feature | Priority | Effort | Files Affected | Lines Saved |
|---------|----------|--------|----------------|-------------|
| `NodeTypeNormalizerBase` | High | Medium | 2 | ~400 |
| `CommentTrackerBase` | High | Medium | 3 | ~350 |
| `node_typing` in base | High | Low | 1 | 0 (adds clarity) |

### Features to Document/Recommend

| Feature | Action |
|---------|--------|
| `Text::SmartMerger` fallback | Document pattern for other gems |
| `RegionMergeable` | Document how it relates to `inner_merge_*` |
| `NodeWrapperInterface` | Consider creating interface module |

### Features Not Worth Extracting

| Feature | Reason |
|---------|--------|
| `Emitter` classes | Too format-specific |
| `CodeBlockMerger` | Markdown-specific, use `regions` instead |

### Recommended Extraction Order

1. **`CommentTrackerBase`** - High value, low risk, 3 gems benefit immediately
2. **`NodeTypeNormalizerBase`** - High value, 2 gems benefit, enables future standardization
3. **`NodeWrapperInterface`** - Low effort documentation, helps standardize patterns

---

## Phase 6: Documentation

### Task 6.1: Create Options Matrix
- [ ] Table showing which options each gem supports
- [ ] Document why unsupported options don't apply

### Task 6.2: Update COPILOT_INSTRUCTIONS.md
- [ ] Add section on options standardization
- [ ] Add examples of correct `**options` usage

---

## Notes

### Options from SmartMergerBase (current)
```ruby
def initialize(
  template_content,
  dest_content,
  signature_generator: nil,      # All gems should support
  preference: :destination,       # All gems should support
  add_template_only_nodes: false, # All gems should support
  freeze_token: nil,              # All gems should support
  match_refiner: nil,             # May not apply to all formats
  regions: nil,                   # May not apply to all formats
  region_placeholder: nil,        # May not apply to all formats
  **format_options                # Catch-all for format-specific
)
```

### Inheritance Patterns Observed

1. **Direct inheritance**: `Prism::Merge::SmartMerger < Ast::Merge::SmartMergerBase`
2. **Multi-level inheritance**: `Markly::Merge::SmartMerger < Markdown::Merge::SmartMerger < SmartMergerBase`
3. **Composition**: Some gems may use composition instead of inheritance

---

## Progress Tracking

| Gem | SmartMerger | FileAnalysis | ConflictResolver | MergeResult | MatchRefiner |
|-----|-------------|--------------|------------------|-------------|--------------|
| ast-merge | ✅ Base Class | ✅ Module | ✅ Base Class | ✅ Base Class | ✅ Base Class |
| prism-merge | ✅ Has **opts | ✅ Has **opts | N/A (custom) | ✅ Has **opts | ✅ Has **opts |
| markdown-merge | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts |
| markly-merge | ✅ Has **opts | ✅ (via md) | ✅ (via md) | ✅ (via md) | ✅ (via md) |
| commonmarker-merge | ✅ Has **opts | ✅ (via md) | ✅ (via md) | ✅ (via md) | ✅ (via md) |
| toml-merge | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts |
| json-merge | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts |
| jsonc-merge | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | N/A |
| psych-merge | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts |
| dotenv-merge | ✅ Has **opts | ✅ Has **opts | N/A (custom) | ✅ Has **opts | N/A |
| bash-merge | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | N/A |
| rbs-merge | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | ✅ Has **opts | N/A |

Legend: ✅ = Has **options, N/A = Not applicable

---

## Phase 1 Summary

### Classes with `**options` Pattern ✅
- `SmartMergerBase` - Uses `**format_options`
- `MatchRefinerBase` - Uses `**options`

### Classes WITHOUT `**options` Pattern ⚠️
- `ConflictResolverBase` - All params explicit (5 keyword args)
- `MergeResultBase` - All params explicit (5 keyword args with defaults)

### Missing Base Classes
- `FileAnalysisBase` - Does NOT exist, each gem implements independently

### Recommendations from Phase 1
1. **Consider adding `**options` to `ConflictResolverBase`** for forward compatibility
2. **Consider adding `**options` to `MergeResultBase`** for forward compatibility  
3. **Consider creating `FileAnalysisBase`** with common interface:
   - Standard options: `freeze_token`, `signature_generator`, `parser_path`
   - Abstract methods: `parse`, `statements`, `valid?`, `errors`

