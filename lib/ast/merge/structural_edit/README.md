# Ast::Merge::StructuralEdit

`Ast::Merge::StructuralEdit` is the shared home for passive structural edit primitives used by `ast-merge` and the sibling `*-merge` gems.

The namespace is intentionally narrow:

- parser-specific traversal still belongs in the relevant analysis / merger layer
- syntax-aware cleanup still belongs in the relevant family or leaf layer unless it proves cross-format
- structural edit primitives here should preserve untouched source exactly whenever they can

## Core types

### `Boundary`

`Ast::Merge::StructuralEdit::Boundary` captures one surviving edge adjacent to a splice.

A boundary can carry:

- `edge` (`:leading` or `:trailing`)
- `owner`
- `layout_attachment`
- `comment_attachment`
- `metadata`

It is passive metadata for structural edit planning. Replace, remove, and rehome operations can all use the same boundary shape.

### `SplicePlan`

`Ast::Merge::StructuralEdit::SplicePlan` is the first shared primitive.

It models exact contiguous line-range replacement:

- preserve source before the replaced range exactly
- replace only the requested line window
- preserve source after the replaced range exactly

A minimal example:

```ruby
plan = Ast::Merge::StructuralEdit::SplicePlan.new(
  source: source,
  replacement: replacement,
  replace_start_line: 10,
  replace_end_line: 14,
)

plan.before_content
plan.removed_content
plan.after_content
plan.merged_content
```

## Current scope

Today the shared primitive is contiguous `:replace` by line range.

That is already useful because it lets callers such as `Ast::Merge::PartialTemplateMergerBase` stop normalizing separators through ad hoc string surgery when the destination analysis exposes real source line ranges.

## Intended next steps

This namespace is the staging ground for richer shared edit operations, including:

- remove primitives that preserve or reassign surrounding layout ownership
- rehome primitives that move preserved comment/layout attachments to a surviving owner
- edit plans that can reason explicitly about shared `Comment::Region` and `Layout::Gap` ownership
