# How to Add a New Merge Gem

## Pattern A (dest-iterate, for structured formats with AST/tree nodes)

```ruby
class ConflictResolver < Ast::Merge::ConflictResolverBase
  include ::Ast::Merge::TrailingGroups::DestIterate

  # Optional: override for freeze-node detection
  def trailing_group_node_matched?(node, _signature)
    freeze_node?(node)
  end

  def merge_nodes(template_nodes, dest_nodes)
    # 1. Build
    groups, matched = build_dest_iterate_trailing_groups(
      template_nodes: template_nodes,
      dest_sigs: dest_sig_set,
      signature_for: ->(node) { analysis.generate_signature(node) },
    )
    # 2. Prefix
    emit_prefix_trailing_group(groups, consumed) { |info| emit(info[:node]) }
    # 3. Dest loop with flush
    dest_nodes.each { |dn| ...; flush_ready_trailing_groups(...) { |info| emit(info[:node]) } }
    # 4. Remaining
    emit_remaining_trailing_groups(...) { |info| emit(info[:node]) }
  end
end
```

## Pattern B (alignment, for line-oriented formats)

```ruby
class FileAligner
  include ::Ast::Merge::TrailingGroups::AlignmentSort

  def align
    # ... build alignment array ...
    sort_alignment_with_template_position(alignment, dest_size)
  end

  private

  # Override if default 4-tuple keys don't fit
  def template_only_sort_key(entry, dest_size)
    [dest_size + entry[:template_index], 1]
  end
end
```

## Tools and Patterns in ast-merge (`lib/ast/merge/trailing_groups/`)

**`Ast::Merge::TrailingGroups`** — Namespace module with autoloads for:

1. **`Core`** — Three stateless primitives (the algorithm backbone):
    - `build_trailing_groups(template_nodes:, matched_predicate:, entry_builder:)` — Walks template nodes, classifies each as matched/unmatched via predicate, groups consecutive unmatched nodes under the preceding matched anchor (`:prefix` for nodes before first match)
    - `flush_ready_trailing_groups(trailing_groups:, matched_indices:, consumed_indices:, &block)` — Deferred-flush: only emits a group when ALL preceding matched template indices have been consumed (handles dest reordering)
    - `emit_remaining_trailing_groups(trailing_groups:, consumed_indices:, &block)` — Safety-net: emits all remaining groups after the dest loop

2. **`DestIterate`** (Pattern A) — Wrapper for dest-iterate gems:
    - Includes `Core`
    - `build_dest_iterate_trailing_groups(...)` — Builds predicate from dest_sigs + refined IDs + hook, with `add_template_only_nodes` gate
    - `emit_prefix_trailing_group(groups, consumed, &block)` — Emits `:prefix` group
    - `trailing_group_node_matched?(node, sig)` — Override hook for freeze-node detection etc.

3. **`AlignmentSort`** (Pattern B) — Wrapper for alignment-based gems:
    - `sort_alignment_with_template_position(alignment, dest_size)` — Sorts alignment array
    - `match_sort_key(entry)` — Override hook (default: 4-tuple)
    - `dest_only_sort_key(entry)` — Override hook
    - `template_only_sort_key(entry, dest_size)` — Override hook

## Existing Examples in the *-merge family.

### Pattern A (DestIterate) — 6 gems

| Gem             | File                        | Include                                             | Hook Override                                                                                                               |
|-----------------|-----------------------------|-----------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------|
| **json-merge**  | `conflict_resolver.rb`      | `include ::Ast::Merge::TrailingGroups::DestIterate` | None needed                                                                                                                 |
| **jsonc-merge** | `conflict_resolver.rb`      | `include ::Ast::Merge::TrailingGroups::DestIterate` | `trailing_group_node_matched?` → `freeze_node?`                                                                             |
| **toml-merge**  | `conflict_resolver.rb`      | `include ::Ast::Merge::TrailingGroups::DestIterate` | None needed                                                                                                                 |
| **psych-merge** | `conflict_resolver.rb`      | `include ::Ast::Merge::TrailingGroups::DestIterate` | `trailing_group_node_matched?` → `freeze_node?`; sequences use `build_trailing_groups` directly with custom `entry_builder` |
| **prism-merge** | `top_level_merge_runner.rb` | `include ::Ast::Merge::TrailingGroups::DestIterate` | None needed                                                                                                                 |
| **bash-merge**  | `smart_merger.rb`           | `include ::Ast::Merge::TrailingGroups::DestIterate` | `trailing_group_node_matched?` → freeze check                                                                               |

### Pattern B (AlignmentSort) — 3 gems (+2 inherited)

| Gem                    | File                            | Include                                               | Hook Overrides                                            |
|------------------------|---------------------------------|-------------------------------------------------------|-----------------------------------------------------------|
| **dotenv-merge**       | `smart_merger.rb`               | `include ::Ast::Merge::TrailingGroups::AlignmentSort` | All 3 sort keys overridden (2-tuple style)                |
| **rbs-merge**          | `file_aligner.rb`               | `include ::Ast::Merge::TrailingGroups::AlignmentSort` | All 3 sort keys overridden (4-tuple with freeze handling) |
| **markdown-merge**     | `file_aligner.rb`               | `include ::Ast::Merge::TrailingGroups::AlignmentSort` | All 3 sort keys overridden (2-tuple style)                |
| **markly-merge**       | (inherited from markdown-merge) | —                                                     | —                                                         |
| **commonmarker-merge** | (inherited from markdown-merge) | —                                                     | —                                                         |
