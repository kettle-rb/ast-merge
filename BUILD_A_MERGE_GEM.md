# Building a New `*-merge` Family Gem

This is the **canonical guide** for implementing a new format-specific merge gem on top of `ast-merge`.

If you are building `my-format-merge`, start here.

## What lives here vs elsewhere

This guide covers:

- how to choose the right merge architecture
- which classes and modules a new gem should implement
- the core matching and ordering contracts every `*-merge` gem must follow
- the shared helpers now available in `ast-merge`
- how to test and register a new gem in the family

Specialized details live in these companion docs:

- [`README.md`](README.md) — end-user overview of `ast-merge` and the merge-gem family
- [`MERGE_APPROACH.md`](MERGE_APPROACH.md) — per-gem strategy reference and real-world matching examples
- [`lib/ast/merge/rspec/README.md`](lib/ast/merge/rspec/README.md) — shared examples, dependency tags, and `MergeGemRegistry`
- [`lib/ast/merge/text/README.md`](lib/ast/merge/text/README.md) — complete reference implementation for a simple line-oriented merger
- [`lib/ast/merge/detector/README.md`](lib/ast/merge/detector/README.md) — nested region detection and delegated sub-merges
- [`lib/ast/merge/comment/README.md`](lib/ast/merge/comment/README.md) — normalized comment model and comment syntax support

---

## 1. Preconditions: what kind of gem are you building?

A `*-merge` gem usually has four moving parts:

1. **Parsing / analysis** — turn source text into mergeable nodes
2. **Matching** — identify which template and destination nodes correspond
3. **Resolution** — decide whether template, destination, or recursive merge wins
4. **Emission** — produce merged output while preserving required structure

Before writing code, decide:

- Is the format **flat** or **nested**?
- Is the output easiest to build **inline** or via an **emitter**?
- Are there **comments**, **freeze blocks**, **prefix metadata**, or **frontmatter** that need special handling?
- Does the format need **recursive merging**, **partial-template merging**, or **nested region detectors**?

---

## 2. The core contracts every merge gem should follow

### 2.1 Cursor-based positional matching is mandatory

All `*-merge` gems should treat signatures as a way to identify *what a node is*, not *how many copies exist*.

Two distinct nodes in the input must remain two distinct nodes in the output.

That means:

- build signature maps as `signature => [{ node:, index: }, ...]`
- track `consumed_template_indices`
- track a per-signature cursor such as `sig_cursor`
- match duplicate signatures **1:1 in order**

Do **not** use a plain `processed_signatures` set for matching. That collapses duplicates incorrectly.

See [`MERGE_APPROACH.md`](MERGE_APPROACH.md) for concrete examples across Ruby, YAML, JSON, TOML, dotenv, and Bash.

### 2.2 Recursive merges provide scope

For nested formats, matching is scoped by recursion.

If two nodes match at the current level and both are mergeable containers, recurse into their children rather than flattening the entire file into one comparison space.

### 2.3 Public constructors should accept `**options`

For forward compatibility with `ast-merge`, public constructors should end with `**options`.

Typical examples:

```ruby
def initialize(source, freeze_token: nil, signature_generator: nil, **options)
  # ...
end
```

```ruby
def initialize(template, dest, preference: :destination, **options)
  super(template, dest, **options)
end
```

This lets the family evolve shared options without forcing every downstream gem to update at the same time.

---

## 3. Choose a merge architecture

There are two primary architectural patterns, plus one specialization layer.

### Pattern A — Inline `SmartMerger`

Use this when merge orchestration is easiest to keep directly inside `SmartMerger#perform_merge`.

Common fits:

- flat formats
- formats with prefix / postlude control
- formats with custom emission ordering
- gems where a separate resolver adds more indirection than value

Examples:

- `prism-merge`
- `bash-merge`
- `dotenv-merge`

Typical shape:

```ruby
class SmartMerger < Ast::Merge::SmartMergerBase
  protected

  def resolver_class
    nil
  end

  def analysis_class
    FileAnalysis
  end

  def perform_merge
    # parse, align, merge, emit, return @result
  end
end
```

### Pattern B — `SmartMerger` + `ConflictResolver`

Use this when merge logic is substantial enough to isolate into a resolver, especially if you use an emitter or want resolver-focused tests.

Common fits:

- structured data formats
- recursive container merges
- emitter-driven output generation
- complex preference / recursion rules

Examples:

- `psych-merge`
- `json-merge`
- `jsonc-merge`
- `toml-merge`

Typical shape:

```ruby
class SmartMerger < Ast::Merge::SmartMergerBase
  protected

  def analysis_class
    FileAnalysis
  end

  def resolver_class
    ConflictResolver
  end
end

class ConflictResolver < Ast::Merge::ConflictResolverBase
  protected

  def resolve_batch(result)
    # populate result or emit merged content
  end
end
```

### Pattern C — Specialization layers

Some gems build on another family gem rather than directly on `ast-merge` alone.

Examples:

- `markdown-merge` as a shared Markdown foundation
- `markly-merge` / `commonmarker-merge` inheriting from it
- partial-template or region-aware flows that compose detectors and sub-mergers

If your new gem is really “a specialization of an existing merge gem”, prefer extending that higher-level abstraction rather than reimplementing all base plumbing.

---

## 4. Minimum class set for a new gem

A typical new gem implements these classes.

### Required

#### `SmartMerger`

Responsibilities:

- select the analysis class
- optionally select or build a resolver
- own top-level merge orchestration
- expose the public `merge` / `merge_result` interface inherited from `SmartMergerBase`

#### `FileAnalysis`

Usually includes `Ast::Merge::FileAnalyzable`.

Responsibilities:

- parse the source into mergeable statements / nodes
- expose `source`, `statements`, `valid?`, `errors`, and line helpers as needed
- implement `compute_node_signature(node)` or equivalent signature generation hooks
- detect freeze markers if the format supports them

#### `MergeResult`

Usually subclasses `Ast::Merge::MergeResultBase`.

Responsibilities:

- store merged lines / output content
- expose `to_s`
- optionally expose format-specific aliases such as `to_yaml`, `to_bash`, etc.

### Usually required

#### `ConflictResolver`

Needed for Pattern B.

Choose an appropriate `ConflictResolverBase` strategy:

- `:batch` — resolve the file or a node list as a whole
- `:node` — resolve node pairs individually
- `:boundary` — resolve by ranges / sections

#### `Emitter`

Useful when the format has structural output rules, comment emission, separators, commas, indentation, or table headers.

#### `FreezeNode`

Needed if the format has explicit freeze markers or frozen opaque regions.

#### `MatchRefiner`

Needed when exact signatures are insufficient and you want fuzzy matching between structurally similar nodes.

---

## 5. Recommended implementation order

1. **Start with `FileAnalysis`**
   - parse the source
   - expose top-level statements
   - implement stable signatures
2. **Add `MergeResult`**
   - get output capture working
3. **Choose Pattern A or B**
   - inline `SmartMerger` or delegated `ConflictResolver`
4. **Implement exact signature matching**
   - with cursor-based duplicate handling
5. **Add recursive merging** if the format needs it
6. **Add template-only insertion / destination-only removal**
7. **Add freeze blocks and comments** if supported by the format
8. **Add refiners, regions, or partial-template support** only after the basic merge works

---

## 6. Position-aware template-only insertion

This used to be reimplemented in many gems. It is now centralized in `Ast::Merge::TrailingGroups`.

### Why this exists

When `add_template_only_nodes: true`, unmatched template nodes should keep their position **relative to matched nodes in template order**.

They should not be blindly prepended or appended.

### Available shared helpers

#### `Ast::Merge::TrailingGroups::Core`

Stateless primitives:

- `build_trailing_groups(...)`
- `flush_ready_trailing_groups(...)`
- `emit_remaining_trailing_groups(...)`

#### `Ast::Merge::TrailingGroups::DestIterate`

Use this in destination-iterate merges.

Provides:

- `build_dest_iterate_trailing_groups(...)`
- `emit_prefix_trailing_group(...)`
- `trailing_group_node_matched?(node, signature)` override hook

#### `Ast::Merge::TrailingGroups::AlignmentSort`

Use this when you already build an alignment array and sort it.

Provides:

- `sort_alignment_with_template_position(...)`
- `match_sort_key(...)`
- `dest_only_sort_key(...)`
- `template_only_sort_key(...)`

### When to use which helper

#### Use `DestIterate`

If your algorithm looks like this:

- iterate destination nodes in order
- find the matching template node
- emit preferred output as you walk

Typical gems:

- `prism-merge`
- `psych-merge`
- `json-merge`
- `jsonc-merge`
- `toml-merge`
- `bash-merge`

Example skeleton:

```ruby
class ConflictResolver < Ast::Merge::ConflictResolverBase
  include Ast::Merge::TrailingGroups::DestIterate

  def trailing_group_node_matched?(node, _signature)
    freeze_node?(node)
  end

  def merge_nodes(template_nodes, dest_nodes)
    groups, matched = build_dest_iterate_trailing_groups(
      template_nodes: template_nodes,
      dest_sigs: dest_signature_set,
      signature_for: ->(node) { @template_analysis.generate_signature(node) },
      refined_template_ids: refined_template_ids,
      add_template_only_nodes: @add_template_only_nodes,
    )

    emit_prefix_trailing_group(groups, consumed_template_indices) do |info|
      emit_node(info[:node])
    end

    dest_nodes.each do |dest_node|
      # ... emit preferred node ...
      flush_ready_trailing_groups(
        trailing_groups: groups,
        matched_indices: matched,
        consumed_indices: consumed_template_indices,
      ) { |info| emit_node(info[:node]) }
    end

    emit_remaining_trailing_groups(
      trailing_groups: groups,
      consumed_indices: consumed_template_indices,
    ) { |info| emit_node(info[:node]) }
  end
end
```

#### Use `AlignmentSort`

If your algorithm looks like this:

- build an alignment array of `:match`, `:dest_only`, `:template_only`
- sort it for output
- process the sorted entries

Typical gems:

- `dotenv-merge`
- `rbs-merge`
- `markdown-merge`

Example skeleton:

```ruby
class FileAligner
  include Ast::Merge::TrailingGroups::AlignmentSort

  def align
    # ... build alignment entries ...
    sort_alignment_with_template_position(alignment, dest_size)
  end

  def template_only_sort_key(entry, dest_size)
    [dest_size + entry[:template_index], 1]
  end
end
```

### Important deferred-flush rule

If destination order can differ from template order, interior template-only groups must only flush when **all preceding matched template anchors have been consumed**.

This is exactly the bug these shared helpers are designed to avoid.

---

## 7. Skeleton: a new merge gem in practice

This is intentionally minimal but realistic.

```ruby
require "ast/merge"

module MyFormat
  module Merge
    class SmartMerger < Ast::Merge::SmartMergerBase
      DEFAULT_FREEZE_TOKEN = "myformat-merge"

      def initialize(template, dest, my_option: nil, **options)
        @my_option = my_option
        super(template, dest, **options)
      end

      protected

      def analysis_class
        FileAnalysis
      end

      def default_freeze_token
        DEFAULT_FREEZE_TOKEN
      end

      def resolver_class
        ConflictResolver
      end
    end

    class FileAnalysis
      include Ast::Merge::FileAnalyzable

      attr_reader :source, :statements, :errors

      def initialize(source, freeze_token: nil, signature_generator: nil, **options)
        @source = source
        @freeze_token = freeze_token
        @signature_generator = signature_generator
        @errors = []
        @statements = parse_source(source)
      end

      def valid?
        @errors.empty?
      end

      def compute_node_signature(node)
        [node.type, node.name]
      end

      private

      def parse_source(source)
        # return top-level mergeable nodes
      end
    end

    class ConflictResolver < Ast::Merge::ConflictResolverBase
      include Ast::Merge::TrailingGroups::DestIterate

      def initialize(template_analysis, dest_analysis, preference: :destination, add_template_only_nodes: false, match_refiner: nil, **options)
        super(
          strategy: :batch,
          preference: preference,
          template_analysis: template_analysis,
          dest_analysis: dest_analysis,
          add_template_only_nodes: add_template_only_nodes,
          match_refiner: match_refiner,
          **options,
        )
      end

      protected

      def resolve_batch(result)
        # merge template and destination analyses into result
      end
    end

    class MergeResult < Ast::Merge::MergeResultBase
      def to_my_format
        to_s
      end
    end
  end
end
```

---

## 8. Optional extension points

### `NodeTyping`

Use when certain node types need different merge preferences or wrappers.

Examples:

- prefer template for dependency declarations but destination for everything else
- wrap parser-native nodes into normalized merge-type wrappers

### `PartialTemplateMergerBase`

Use when the format benefits from merging only targeted sections rather than whole files.

### `Detector::Mergeable`

Use when the document contains nested regions that should be delegated to specialized sub-mergers.

Examples:

- YAML frontmatter inside Markdown
- Ruby fenced code blocks inside prose
- TOML frontmatter inside content files

### `Comment::*`

Use when the format supports comments and you want to adopt the normalized family-wide comment model instead of inventing format-local comment abstractions first.

### `Text::SmartMerger`

Use as:

- a reference implementation
- a fallback for line-based formats
- a sub-merge helper for embedded plain-text regions

---

## 9. Testing a new gem

At minimum, test:

- exact matching
- duplicate signatures
- template-only insertion
- destination-only preservation or removal
- recursive merges (if supported)
- freeze behavior (if supported)
- comment preservation and ownership (if supported)
- idempotence

### Shared examples

Use `ast-merge` RSpec shared examples where they fit your implementation.

See the full guide in [`lib/ast/merge/rspec/README.md`](lib/ast/merge/rspec/README.md).

Common categories include:

- base-class compliance
- merger config behavior
- reproducible merge behavior
- removal-mode compliance

### Register your gem for dependency tags

If your gem participates in the family test ecosystem, register it with `MergeGemRegistry`.

Typical pattern:

```ruby
if defined?(Ast::Merge::RSpec::MergeGemRegistry)
  Ast::Merge::RSpec::MergeGemRegistry.register(
    :my_merge,
    require_path: "my/merge",
    merger_class: "My::Merge::SmartMerger",
    test_source: "sample content",
    category: :other,
  )
end
```

Details and options are documented in [`lib/ast/merge/rspec/README.md`](lib/ast/merge/rspec/README.md).

---

## 10. Reference implementations in the family

Use these as examples rather than starting from scratch.

### Inline `SmartMerger`

- `prism-merge` — recursive Ruby merge with prefix/header concerns
- `bash-merge` — flat structured shell merge with freeze-aware ordering
- `dotenv-merge` — simple alignment-driven flat merge

### `ConflictResolver` pattern

- `psych-merge` — recursive YAML mapping and sequence merge
- `json-merge` — structural JSON object / array merge
- `jsonc-merge` — JSONC plus comment-aware recursive merge
- `toml-merge` — TOML tables and `[[array_of_tables]]`

### Shared foundation / specialization

- `markdown-merge` — shared Markdown foundation for backend-specific gems
- `markly-merge` / `commonmarker-merge` — backend specializations

### Simplest complete example

- `Ast::Merge::Text` — easiest complete reference for the full stack in one place

---

## 11. Author checklist

Before calling a new gem “ready”, confirm:

- [ ] `FileAnalysis` exposes stable mergeable statements
- [ ] signatures are stable and cursor-based matching is used
- [ ] duplicate signatures are preserved, not collapsed
- [ ] template-only insertion is position-aware
- [ ] recursive merges are scoped correctly, if applicable
- [ ] `**options` is accepted on public constructors
- [ ] freeze behavior is implemented or explicitly unsupported
- [ ] comment behavior is normalized or explicitly documented as unsupported
- [ ] shared RSpec examples and reproducibility tests pass
- [ ] `MergeGemRegistry` registration exists if the gem participates in family test tags
- [ ] README points users to the right parser/backends and limitations

---

## 12. See also

- [`README.md`](README.md)
- [`MERGE_APPROACH.md`](MERGE_APPROACH.md)
- [`lib/ast/merge/rspec/README.md`](lib/ast/merge/rspec/README.md)
- [`lib/ast/merge/text/README.md`](lib/ast/merge/text/README.md)
- [`lib/ast/merge/detector/README.md`](lib/ast/merge/detector/README.md)
- [`lib/ast/merge/comment/README.md`](lib/ast/merge/comment/README.md)
