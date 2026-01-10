# PRD: Git Diff to Partial Template Merge Tool

**Status**: ✅ Complete  
**Created**: 2026-01-09  
**Last Updated**: 2026-01-09

## Overview

Create a tool that parses unified git diffs, maps changes to AST node paths, generates partial templates, and merges into destinations. This enables propagating changes from one file to many similar files using AST-aware merging.

### Example Use Case

When adding a line to `rubocop.yml`:
```yaml
AllCops:
  Exclude:
    - examples/**/*  # ← new line added
```

The tool should be able to merge this change into any other `rubocop.yml` file, intelligently handling:
- Files that already have `AllCops.Exclude` (merge the new item)
- Files that don't have `AllCops.Exclude` (add the entire structure)

## Requirements

### Must Have

1. **Recursive merge support** for nested YAML/JSON structures (default: `true`)
2. **Remove template missing nodes** option for deletions
3. **Unified git diff parsing** with AST path mapping
4. **CLI executable** (`exe/ast-merge-diff`) that ships with the gem

### Nice to Have

1. Support for all `*-merge` gem formats
2. Recipe/preset support for common operations
3. Dry-run mode with diff preview

## Architecture

### New Components

| Component | Location | Purpose |
|-----------|----------|---------|
| `DiffMapperBase` | `lib/ast/merge/diff_mapper_base.rb` | Abstract base for diff-to-AST mapping |
| `Psych::Merge::DiffMapper` | `vendor/psych-merge/lib/psych/merge/diff_mapper.rb` | YAML-specific diff mapping |
| `Psych::Merge::PartialTemplateMerger` | `vendor/psych-merge/lib/psych/merge/partial_template_merger.rb` | YAML partial merge |
| `exe/ast-merge-diff` | `exe/ast-merge-diff` | CLI executable |

### Modified Components

| Component | Changes |
|-----------|---------|
| `ConflictResolverBase` | Add `remove_template_missing_nodes` option |
| `SmartMergerBase` | Thread through `recursive` and `remove_template_missing_nodes` |
| `Psych::Merge::ConflictResolver` | Implement recursive merge logic |
| `Psych::Merge::SmartMerger` | Add new options |

## Implementation Plan

### Step 1: Recursive Merge for psych-merge

**File**: `vendor/psych-merge/lib/psych/merge/conflict_resolver.rb`

**Changes**:
- [ ] Add `recursive: true | false | Integer` option (default: `true`)
- [ ] Validate: `0` raises `ArgumentError` ("recursive: 0 is invalid, use false to disable")
- [ ] When matching a MappingEntry by signature, recursively merge nested children
- [ ] For sequences (arrays), use union semantics with `add_template_only_nodes`

**Files to modify**:
- [ ] `vendor/psych-merge/lib/psych/merge/conflict_resolver.rb`
- [ ] `vendor/psych-merge/lib/psych/merge/smart_merger.rb`
- [ ] `vendor/psych-merge/spec/psych/merge/conflict_resolver_spec.rb`
- [ ] `vendor/psych-merge/spec/psych/merge/smart_merger_spec.rb`

### Step 2: Remove Template Missing Nodes Option

**File**: `lib/ast/merge/conflict_resolver_base.rb`

**Changes**:
- [ ] Add `remove_template_missing_nodes` attribute (default: `false`)
- [ ] Add to `initialize` parameter list
- [ ] Document the option

**Files to modify**:
- [ ] `lib/ast/merge/conflict_resolver_base.rb`
- [ ] `lib/ast/merge/smart_merger_base.rb`
- [ ] `vendor/psych-merge/lib/psych/merge/conflict_resolver.rb` (implement behavior)
- [ ] `vendor/psych-merge/lib/psych/merge/smart_merger.rb`
- [ ] Specs for all modified files

### Step 3: DiffMapperBase

**File**: `lib/ast/merge/diff_mapper_base.rb`

**New class providing**:
- [ ] `DiffHunk` struct: `{old_start:, old_count:, new_start:, new_count:, lines:}`
- [ ] `DiffMapping` struct: `{path:, operation:, lines:}`
- [ ] `parse_diff(diff_text)` - Parse unified git diff format
- [ ] Abstract `#map_hunk_to_paths(hunk, original_analysis)` for subclasses
- [ ] Operation detection: `:add`, `:remove`, `:modify`

**Tests**:
- [ ] `spec/ast/merge/diff_mapper_base_spec.rb`

### Step 4: Psych::Merge::DiffMapper

**File**: `vendor/psych-merge/lib/psych/merge/diff_mapper.rb`

**Implementation**:
- [ ] Inherit from `Ast::Merge::DiffMapperBase`
- [ ] Implement `#map_hunk_to_paths` using `FileAnalysis`
- [ ] Map line numbers to YAML key paths via indentation tracking
- [ ] Handle MappingEntry location data

**Tests**:
- [ ] `vendor/psych-merge/spec/psych/merge/diff_mapper_spec.rb`

### Step 5: exe/ast-merge-diff Executable

**File**: `exe/ast-merge-diff`

**Features**:
- [ ] Follow `exe/ast-merge-recipe` pattern with bundler/inline
- [ ] Pre-parse `--format` or auto-detect from `--original` extension
- [ ] Dynamic gemfile block based on format
- [ ] Clear error messages for missing format gems

**CLI Options**:
```
--diff <file|->      Unified diff (stdin default)
--original <file>    Required for path mapping
--destination <file> Target file to merge into
--format <format>    Override auto-detection
--dry-run            Show changes without writing
--verbose            Detailed output
```

**Format-to-Gem Mapping**:

| Extension | Format | Gem | Vendor Path |
|-----------|--------|-----|-------------|
| `.yml`, `.yaml` | yaml | psych-merge | `vendor/psych-merge` |
| `.json` | json | json-merge | `vendor/json-merge` |
| `.rb` | ruby | prism-merge | `vendor/prism-merge` |
| `.md`, `.markdown` | markdown | markly-merge | `vendor/markly-merge` |
| `.toml` | toml | toml-merge | `vendor/toml-merge` |
| `.env` | dotenv | dotenv-merge | `vendor/dotenv-merge` |
| `.sh`, `.bash` | bash | bash-merge | `vendor/bash-merge` |
| `.rbs` | rbs | rbs-merge | `vendor/rbs-merge` |

### Step 6: Psych::Merge::PartialTemplateMerger

**File**: `vendor/psych-merge/lib/psych/merge/partial_template_merger.rb`

**Implementation**:
- [ ] Follow `partial_template_merger_base.rb` pattern
- [ ] Key-path-based navigation (not heading-based)
- [ ] Navigate to specific YAML key paths
- [ ] Merge partial content at target location

**Tests**:
- [ ] `vendor/psych-merge/spec/psych/merge/partial_template_merger_spec.rb`

## Technical Details

### Recursive Merge Depth

- `true` = unlimited depth (default)
- `Integer > 0` = max depth
- `false` = disabled
- `0` = invalid, raises `ArgumentError`

### Sequence (Array) Merge Semantics

When recursively merging into an array like `Exclude`:

| Mode | Behavior |
|------|----------|
| `add_template_only_nodes: true` | Union - add template items not in destination |
| `remove_template_missing_nodes: true` | Remove destination items not in template |
| Default | Keep destination array intact |

Array items matched by exact value for scalars. For nested objects, use signature matching.

### Diff Operation Detection

From unified diff hunks:
- Lines starting with `+` (not `+++`) = addition
- Lines starting with `-` (not `---`) = removal
- Context lines (space prefix) = unchanged
- Hunk with only `+` lines at a path = `:add` operation
- Hunk with only `-` lines = `:remove` operation
- Mixed `+` and `-` = `:modify` operation

## Testing Strategy

### Unit Tests

- [ ] `DiffMapperBase` diff parsing
- [ ] `Psych::Merge::DiffMapper` YAML path mapping
- [ ] Recursive merge with various depths
- [ ] `remove_template_missing_nodes` behavior
- [ ] Sequence union semantics

### Integration Tests

- [ ] End-to-end diff → merge workflow
- [ ] `exe/ast-merge-diff` CLI
- [ ] Format auto-detection
- [ ] Error handling for missing gems

### Fixtures

Create fixtures in `vendor/psych-merge/spec/fixtures/`:
- [ ] `recursive_merge/` - nested structure scenarios
- [ ] `diff_mapper/` - diff parsing scenarios
- [ ] `remove_nodes/` - deletion scenarios

## Progress Tracking

### Completed
- [x] Plan finalized and approved
- [x] PRD created
- [x] Step 1: Recursive merge for psych-merge
- [x] Step 2: Remove template missing nodes option
- [x] Step 3: DiffMapperBase
- [x] Step 4: Psych::Merge::DiffMapper
- [x] Step 5: exe/ast-merge-diff executable
- [x] Step 6: Psych::Merge::PartialTemplateMerger

### In Progress
(none)

### Not Started
(none)

## Open Questions

None currently - all questions resolved during planning.

## References

- [exe/ast-merge-recipe](../exe/ast-merge-recipe) - Pattern for bundler/inline CLI
- [partial_template_merger_base.rb](../lib/ast/merge/partial_template_merger_base.rb) - Base class pattern
- [conflict_resolver_base.rb](../lib/ast/merge/conflict_resolver_base.rb) - Options pattern

