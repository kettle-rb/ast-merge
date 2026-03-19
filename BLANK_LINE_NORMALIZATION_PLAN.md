# Blank Line Normalization Plan for `ast-merge`

_Date: 2026-03-19_

## Role in the family refactor

`ast-merge` is the primary implementation repo for this effort.

It should become the shared owner of merge-facing blank-line/layout semantics in the same way it already owns the shared comment model.

## Why `ast-merge` owns this

Current evidence already points here:

- `Ast::Merge::Comment::Empty` already treats blank lines as meaningful within comment structure
- `Ast::Merge::EmitterBase` reconstructs blank-line gaps heuristically during emission
- `Ast::Merge::PartialTemplateMergerBase` already applies section-spacing normalization policy
- multiple downstream `*-merge` gems currently duplicate gap-preservation logic that should be platform behavior instead

## Current evidence files

Primary files to evolve:

- `lib/ast/merge/ast_node.rb`
- `lib/ast/merge/file_analyzable.rb`
- `lib/ast/merge/emitter_base.rb`
- `lib/ast/merge/partial_template_merger_base.rb`
- `lib/ast/merge/comment/README.md`
- `lib/ast/merge/comment/empty.rb`

Relevant specs and regressions:

- `spec/integration/text_merge_spec.rb`
- `spec/integration/gem_family_section_merge_spec.rb`
- `spec/integration/partial_template_merger_table_merge_spec.rb`
- comment parser/spec coverage under `spec/ast/merge/comment*`

## Target design work

### Ownership directionality (must be explicit)

The same blank-line run can be adjacent to both a preceding and a following node.

For the shared `ast-merge` model:

- both adjacent nodes may reference the same shared gap object
- only one side may control output at a time
- interstitial gaps should default to the following node as controller
- preamble gaps should default to the first node as controller
- postlude gaps should default to the last node as controller

Fallback must remain deterministic:

- if the controlling node is removed during merge
- and the other adjacent node survives
- the surviving adjacent node can become the effective controller

This prevents duplicate output while still preserving exact gap identity and allowing final/initial file-edge blank lines to remain associated with the surviving edge node.

### 1. Introduce a shared layout-gap model

Probable additions:

- `Ast::Merge::Layout::Gap`
- `Ast::Merge::Layout::Attachment`
- `Ast::Merge::Layout::Augmenter`

The abstraction should model blank-line runs as interstitial layout rather than as ad hoc string fixes.

### 2. Define canonical gap semantics

`ast-merge` should define the shared vocabulary for:

- leading gap
- trailing gap
- interstitial gap
- separator blank line
- exact preservation
- normalized preservation

### 3. Add shared policy helpers

Shared policies should support at least:

- preserve exact gap count
- prefer destination gap count
- prefer template gap count
- collapse excessive runs
- normalize to a single separator blank line

### 4. Move emitters onto shared layout behavior

At minimum, shared emission should replace or centralize current gap reconstruction in:

- `EmitterBase`
- partial-template content assembly helpers

## Workstreams

### Workstream A: passive shared objects

- add layout namespace and passive value objects
- document them alongside the shared comment model
- avoid changing merge behavior in the first slice

### Workstream B: augmenter/attachment inference

- infer gaps from source lines plus owner ranges
- align gap ownership rules with the comment ownership model where useful
- keep parser capability separate from merge ownership

### Workstream C: shared emission and normalization

- emit exact gaps when policy says preserve exact
- emit normalized gaps when policy says normalize
- keep repeated merges idempotent

### Workstream D: shared compliance specs

Add shared examples for:

- exact blank-line preservation
- separator blank-line preservation
- no unwanted blank-line swallowing
- no duplicate blank-line accumulation
- idempotence after repeated merge runs

## Migration expectations for downstream gems

`ast-merge` should provide the contract that downstream gems can consume incrementally.

Strong adopters expected first:

- `prism-merge`
- `markdown-merge`

## Exit criteria

- shared layout/gap abstractions exist and are documented
- shared specs cover exact and normalized blank-line cases
- emitter and partial-template helpers use shared gap semantics
- downstream adopters can remove custom blank-line heuristics in favor of shared infrastructure
