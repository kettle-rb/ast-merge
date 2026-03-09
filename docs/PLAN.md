# Plan: Standardized Comment Handling Across `tree_haver` and `ast-merge`

_Date: 2026-03-08_

## Executive Summary

The `*-merge` gem family should continue to use each format's **native AST as the primary merge structure**.
Comment handling should be standardized, but that standardization must **augment** native ASTs rather than replace them.

This plan recommends a **split-layer design**:

- **`tree_haver`** should define and expose a **normalized comment capability contract** for parser backends.
- **`ast-merge`** should define and own the **merge policy**, **attachment semantics**, and **fallback comment AST augmentation** used when native parser support is missing or inadequate.

This preserves the current architectural boundary:

- `tree_haver` owns parsing and normalized node capabilities
- `ast-merge` owns merge semantics and synthetic merge-oriented structures

Implementation backlog: see [`docs/COMMENT_WORK_ITEMS.md`](./COMMENT_WORK_ITEMS.md).

## Problem Statement

Today, comment handling across the `*-merge` family is inconsistent.

Some examples:

- Some parsers expose comments directly or indirectly through their ASTs.
- Some parsers expose location data but not comment nodes.
- Some parsers drop comments entirely, forcing format-specific side channels such as line scanning.
- `ast-merge` already includes `Ast::Merge::Comment::*`, but those classes are not yet the standardized runtime representation for attached comments across merge gems.
- `ast-merge` also includes `Ast::Merge::Text`, which can merge text regions, but it is not currently positioned as the shared comment-region merge layer.

The result is duplicated logic, inconsistent behavior, and unclear boundaries between:

1. parser-native comment support
2. normalized comment representation
3. merge-specific comment attachment and conflict handling

## Non-Negotiable Design Principles

1. **Native ASTs remain primary.**
   Every `*-merge` gem should keep using its current parser-native or `tree_haver`-normalized AST for smart structural merging.

2. **Comments must become a first-class normalized capability.**
   If comments are available from the underlying parser, they should be consumable through a consistent interface.

3. **Fallback augmentation must exist.**
   If a parser does not expose comments adequately, `ast-merge` must be able to augment the AST using source-based comment extraction.

4. **Merge policy stays in `ast-merge`.**
   Attachment rules, ownership, preference semantics, and merge conflict behavior are merge concerns, not parser concerns.

5. **`tree_haver` should normalize capabilities, not merge behavior.**
   `tree_haver` should expose comments in a normalized way when possible, but should not decide how merge gems resolve competing comments.

6. **The same standardized comment model must work for both cases:**
   - parsers with native comment support
   - parsers without native comment support

7. **Freeze markers must integrate with the same normalized comment system.**
   Freeze behavior should not remain a parallel ad hoc concept where comments are otherwise normalized.

## Key Insight

The correct question is not:

> Should comments live in `tree_haver` or in `ast-merge`?

The correct question is:

> Which parts of comment handling are parsing capabilities, and which parts are merge policy?

That split leads to the architecture below.

---

## Recommended Architecture

## Layer 1: `tree_haver` comment capability contract

`tree_haver` should expose a **normalized comment capability** for backends that can provide comments.

This does **not** mean every backend must suddenly yield comment nodes in the primary child list immediately.
It means the API must become capable of describing comments consistently.

### Proposed `tree_haver` responsibilities

`tree_haver` should eventually normalize the following comment-related capabilities where the backend can support them:

- comment node classification
- comment text access
- comment style metadata
- source positions / ranges
- parent/container association where available
- attachment hints where the underlying parser can provide them

### Possible API shape in `tree_haver`

This plan does **not** require final naming now, but the capability should support concepts like:

- `node.comment?`
- `node.leading_comments`
- `node.trailing_comments`
- `node.inline_comment`
- `root.comments`
- `analysis.comments`
- `backend.comment_support_level`

Where the parser cannot support some of these directly, the API may return:

- empty collections
- `nil`
- capability flags indicating unsupported / partial support

### Important boundary

`tree_haver` should normalize **comment access**, but should not decide:

- which side's comment wins during merge
- whether a comment belongs semantically to the preceding node or following node in merge policy
- how comment-only gaps are merged
- how freeze markers affect merge preference

Those are `ast-merge` concerns.

---

## Layer 2: `ast-merge` normalized comment model and merge policy

`ast-merge` should standardize comment handling for all merge gems by introducing a shared comment integration layer built around the existing `Ast::Merge::Comment::*` classes.

### `ast-merge` should own

1. **Normalized comment representation for merge use**
   - `Ast::Merge::Comment::Line`
   - `Ast::Merge::Comment::Block`
   - `Ast::Merge::Comment::Empty`
   - new attachment/region abstractions described below

2. **Attachment semantics**
   - leading comment block for a node
   - inline comment on a node
   - trailing/orphan comment block
   - preamble/postlude comment regions
   - comment-only separators between structural nodes

3. **Fallback comment extraction**
   - when native parser support is absent or incomplete
   - source scanning should produce the same normalized comment structures used by native-capable backends

4. **Merge behavior**
   - preserve destination vs template comments under preference rules
   - merge comment-only regions when both sides changed
   - reconcile blank lines and grouping
   - integrate freeze markers with the same normalized comment objects

5. **Emitter-facing output model**
   - emit normalized comments consistently regardless of whether they came from the parser or fallback extraction

---

## Why the recommendation is split-layer, not all-in-one

## Why not put everything in `tree_haver`?

Because `tree_haver` is a parsing adapter, not a merge engine.

If comment ownership and merge semantics move entirely into `tree_haver`, it risks leaking merge-specific policy into the parsing foundation.
That would violate the same architectural principle already documented for node normalization:

- `tree_haver` provides a normalized parsing API
- `ast-merge` trusts that API and performs merge semantics

## Why not keep everything in `ast-merge`?

Because then every merge gem would keep re-discovering comment capabilities parser-by-parser.

If `tree_haver` already exists to normalize parser behavior, comments are exactly the kind of capability that should be normalized there:

- comments are parser facts
- source ranges are parser facts
- comment node identity is a parser fact when available

`ast-merge` should consume that capability rather than re-implement parser-specific discovery forever.

## Therefore

The right split is:

- **`tree_haver`: normalize comment capability**
- **`ast-merge`: normalize comment merge behavior**

---

## Existing Assets We Should Reuse

## In `ast-merge`

### Already useful today

- `Ast::Merge::Comment::Style`
- `Ast::Merge::Comment::Line`
- `Ast::Merge::Comment::Block`
- `Ast::Merge::Comment::Empty`
- `Ast::Merge::Comment::Parser`
- `Ast::Merge::Text::*`
- `Ast::Merge::AstNode`
- `Ast::Merge::NodeWrapperBase` comment-related fields (`leading_comments`, `inline_comment`)
- `Ast::Merge::FreezeNodeBase` / `Freezable`

### Missing shared bridge

The missing piece is not the comment AST itself.
The missing piece is the shared bridge from:

- parser-native comments
- or source-scanned comments

into:

- a normalized merge-facing comment attachment model

## In `tree_haver`

`tree_haver` already normalizes node APIs like:

- `#text`
- `#type`
- `#children`
- position APIs

Comments should be treated as the next normalization frontier.

---

## Proposed New Concepts in `ast-merge`

The plan below assumes we keep and extend `Ast::Merge::Comment` instead of replacing it.

## 1. `Ast::Merge::Comment::Region`

A merge-facing unit representing a contiguous comment-related span.

Potential responsibilities:

- wraps one or more `Comment::*` nodes
- knows whether it is:
  - `:leading`
  - `:inline`
  - `:trailing`
  - `:orphan`
  - `:preamble`
  - `:postlude`
- preserves source range
- can expose normalized content/signature
- can merge with another region

## 2. `Ast::Merge::Comment::Attachment`

A per-structural-node container for comments associated with one AST node.

Potential responsibilities:

- `leading_region`
- `inline_region`
- `trailing_region`
- source of truth about how comments attach to a structural node

## 3. `Ast::Merge::Comment::Capability`

A small abstraction describing what the parser/backend can actually provide.

Potential levels:

- `:native_full`
- `:native_partial`
- `:native_comment_nodes_only`
- `:source_augmented`
- `:none`

This would let merge gems choose whether to:

- trust parser-provided attachment
- ask `ast-merge` to infer attachment
- fall back to source scanning

## 4. `Ast::Merge::Comment::Augmenter`

A shared augmentation pipeline in `ast-merge`.

Responsibilities:

- take native AST + source text + optional parser comment info
- produce normalized comment regions / attachments
- fill in missing comment support when parser-native support is absent

---

## Proposed `tree_haver` Concepts

These should be parser-facing, not merge-policy-facing.

## 1. Comment capability introspection

Backends should be able to report what kind of comment support they have.

Examples:

- comments present as actual nodes
- only leading/trailing comments available
- only token stream comments available
- no comment support at all

## 2. Normalized comment wrappers

Where backends can expose comments, they should expose them through a normalized wrapper with at least:

- text
- type
- location
- style or delimiter kind if knowable

These do **not** need to be `Ast::Merge::Comment::*` classes inside `tree_haver`.
That would create the wrong dependency direction.

Instead, `ast-merge` should be able to map `tree_haver` comment wrappers into `Ast::Merge::Comment::*`.

## 3. Optional attachment hints

Where native parsers can distinguish:

- leading comments
- trailing comments
- inline comments

`tree_haver` should expose those hints.

Where they cannot, `tree_haver` should expose raw comment nodes and locations, and let `ast-merge` infer attachments.

---

## Capability Matrix We Should Adopt

Each backend / merge gem should be classified using the following matrix.

| Capability | Meaning | Owner |
|---|---|---|
| Native structural AST | Main merge tree | parser / `tree_haver` |
| Native comment nodes | Parser can expose comments as nodes | parser / `tree_haver` |
| Native attachment hints | Parser can identify leading/trailing/inline comments | parser / `tree_haver` |
| Source-range accuracy | Comments and nodes have trustworthy locations | parser / `tree_haver` |
| Merge attachment policy | Which comments belong to which mergeable node | `ast-merge` |
| Comment-region merge policy | How two competing comment regions are combined | `ast-merge` |
| Fallback augmentation | Infer comments from raw source | `ast-merge` |
| Freeze integration | Interpret freeze markers within normalized comments | `ast-merge` |

---

## Decision on Native Comment Handling

A critical question raised in this discussion is:

> Should we normalize comments even for parsers that already handle them natively, such as Ruby / Prism?

## Recommendation: yes, normalize all comments at the merge boundary

Even when a parser already handles comments well, merge gems should map those comments into a **standardized comment model** before merge policy runs.

That does **not** mean throwing away parser-native power.
It means adopting a consistent merge-facing representation.

### Why this is the right move

1. It creates one merge-policy surface for all backends.
2. It prevents `psych-merge`, `prism-merge`, `jsonc-merge`, etc. from diverging forever.
3. It allows freeze markers, preserved blank lines, and comment-only spans to behave consistently.
4. It makes comment support testable through shared examples.
5. It aligns with the reason `tree_haver` exists at all: normalize parser differences.

### Important nuance

Normalization should happen at the **merge boundary**, not by forcing every parser to use the same internal AST model.

That means:

- parser-native comment structures remain valid upstream
- merge gems convert them into standardized merge-facing comment structures downstream

---

## Phased Rollout Plan

## Phase 0: Document the target architecture

Goal:
- agree on boundary and vocabulary before changing multiple repos

Deliverables:
- this plan
- glossary of comment capability terms
- backend capability inventory

## Phase 1: Standardize the merge-facing comment model in `ast-merge`

Goal:
- make `Ast::Merge::Comment` the canonical merge-facing model

Work:
- add `Region` / `Attachment` / `Augmenter` concepts
- define minimal API for merge gems
- define standard source/position contract
- define comment ownership categories

Deliverables:
- new classes/modules in `ast-merge`
- shared specs in `ast-merge`
- migration guide for merge gems

## Phase 2: Standardize comment capability introspection in `tree_haver`

Goal:
- expose a parser/backend comment capability contract

Work:
- add capability reporting
- add normalized comment wrappers or comment access APIs
- expose attachment hints where native parsers can provide them

Deliverables:
- `tree_haver` API additions
- backend capability matrix in docs/specs

## Phase 3: Bridge one weak backend first (`psych-merge`)

Goal:
- prove the fallback-augmentation design

Why `psych-merge` first:
- comments are the active pain point
- current implementation already demonstrates the need
- YAML has enough structure to test attachment correctness clearly

Work:
- replace raw hash comment side channel with standardized comment regions
- keep native YAML AST merge logic unchanged
- use augmentation only for missing comment support
- route emission through standardized comment attachments

Deliverables:
- migrated `psych-merge`
- shared regression specs for comment preservation and merging

## Phase 4: Normalize a strong backend (`prism-merge`)

Goal:
- prove that native-capable parsers also benefit from the same merge-facing model

Work:
- map native Prism comment handling into standardized comment attachments
- preserve Ruby-specific semantics like magic comments in `prism-merge`
- ensure no regression in native capabilities

Deliverables:
- migrated `prism-merge`
- examples of native-full comment support using the same contract

## Phase 5: Expand to other merge gems

Priority order should follow comment complexity and practical benefit:

1. `jsonc-merge`
2. markdown-family merge gems
3. `bash-merge`
4. `toml-merge`
5. other config/data formats

## Phase 6: Shared comment merge examples and compliance suite

Goal:
- make comment behavior part of the platform contract

Work:
- add RSpec shared examples for:
  - leading comments
  - inline comments
  - trailing/orphan comments
  - preamble/postlude comments
  - comment-only documents
  - freeze markers in comments
  - destination/template preference on comment regions
  - two-sided comment edits

---

## Migration Strategy by Backend Class

## Class A: native-full comment support

Examples may include parsers/backends that already expose comments clearly.

Strategy:
- keep native AST merge
- map native comments into standardized merge-facing attachments
- avoid fallback augmentation unless needed for gaps

## Class B: native-partial comment support

Examples may include parsers that expose comments or tokens but not ownership.

Strategy:
- consume native comment nodes/ranges from `tree_haver`
- let `ast-merge` infer ownership/attachments
- use fallback scanning only for holes

## Class C: no native comment support

Examples may include parsers like current YAML/Psych handling.

Strategy:
- keep native structural AST for merge
- add source-based augmentation in `ast-merge`
- produce the same standardized merge-facing comment structures used in Classes A/B

---

## Attachment Rules to Standardize

These must live in `ast-merge`, because they are merge rules, not parser facts.

## Leading comments

Default rule:
- contiguous comment block immediately preceding a node belongs to that node
- blank lines may or may not remain part of that attachment depending on region semantics

## Inline comments

Default rule:
- inline comments remain attached to the same physical line / node

## Trailing comments / orphan comments

Default rule:
- comments after the final structural node are preserved as postlude/orphan regions
- comments between siblings that do not clearly belong to a single node become standalone regions, not silently discarded

## Preamble / postlude

Default rule:
- comments before the first structural node are preamble
- comments after the last structural node are postlude

## Override hooks

Format gems should be able to override these defaults when format semantics require different ownership.

---

## How `Ast::Merge::Text` Fits In

`Ast::Merge::Text` should not replace native structured merges.
However, it should become an explicit tool for **comment-region merging**.

Recommended use:

- merge comment-only regions
- merge orphan comment spans
- merge section preambles/postludes
- potentially merge the textual body of comment blocks once attachment has already been determined

Not recommended use:

- replacing the top-level AST merge for YAML, Ruby, JSON, TOML, etc.

So the role of `Text` is:

- **sub-merge engine for comment regions**
- **not top-level merge engine for structured files**

---

## Freeze Marker Integration

Freeze markers should be treated as standardized comment content, not as an unrelated special case.

That means:

- parser-native comments and augmented comments should both be able to express freeze markers
- freeze marker detection should operate on normalized comment nodes/regions
- `FreezeNodeBase` and comment attachments should eventually share a clearer integration story

This does **not** require collapsing all freeze handling into comments immediately.
But it does require the new comment architecture to account for freeze semantics from the start.

---

## Testing Strategy

## In `ast-merge`

Add shared examples for:

- comment region normalization
- attachment inference
- fallback augmentation from raw source
- comment-region merge behavior
- comment preservation with blank lines
- freeze markers inside normalized comments

## In `tree_haver`

Add backend capability tests for:

- comment capability reporting
- comment wrapper location fidelity
- attachment hints where available
- consistent text/type/position APIs for comment wrappers

## In merge gems

Each gem should test:

- native AST merging remains primary
- comments are preserved correctly
- comment merging works consistently under destination/template preference
- comment-only trailing regions survive round trips
- native-supported backends and augmented backends yield equivalent merge-facing comment structures

---

## Risks and Guardrails

## Risk: forcing merge policy into `tree_haver`

Guardrail:
- keep `tree_haver` limited to capability normalization and parser facts

## Risk: creating two incompatible comment models

Guardrail:
- make `Ast::Merge::Comment::*` the merge-facing canonical representation
- ensure all parser-native comments are mappable into that model

## Risk: replacing strong native comment support with weaker synthetic logic

Guardrail:
- native support stays primary
- augmentation only fills gaps
- mapping should preserve native fidelity where available

## Risk: over-attaching comments that should remain standalone

Guardrail:
- support orphan/prelude/postlude regions explicitly
- do not force every comment into node ownership

## Risk: inconsistent behavior across merge gems during migration

Guardrail:
- provide shared examples and capability levels
- migrate in phases, starting with `psych-merge`, then `prism-merge`

---

## Recommended First Implementation Steps

1. **Adopt this split-layer decision explicitly.**
   - `tree_haver`: normalized comment capability
   - `ast-merge`: normalized comment merge model + fallback augmentation

2. **Create merge-facing abstractions in `ast-merge`.**
   - `Comment::Region`
   - `Comment::Attachment`
   - `Comment::Augmenter`
   - capability adapter helpers

3. **Define capability reporting for `tree_haver`.**
   - enough to distinguish native-full / native-partial / none

4. **Migrate `psych-merge` first.**
   - keep YAML AST merge intact
   - replace raw comment hash flow with standardized regions/attachments

5. **Migrate `prism-merge` second.**
   - prove that native-capable comment support also enters the same standardized merge-facing model

6. **Add shared compliance specs.**
   - make comment behavior part of the `*-merge` platform contract

---

## Final Recommendation

### Decision

Create the planning and rollout center in **`ast-merge`**, not `tree_haver`.

### Why

Because:

- the urgent integration problem is a merge-platform problem
- `ast-merge` already contains `Comment::*`, `Text::*`, `FreezeNodeBase`, and merge policy infrastructure
- `tree_haver` changes are necessary, but they should be driven by a merge-facing contract defined here first

### Practical implication

- `ast-merge/docs/PLAN.md` becomes the canonical design doc
- follow-up `tree_haver` work should implement the parsing-side capability contract called for here

### Architectural recommendation

Proceed with a **split-layer comment normalization strategy**:

- **Normalize parser comment capabilities in `tree_haver`**
- **Normalize merge-facing comment structures and semantics in `ast-merge`**
- **Map native-supported comments and fallback-augmented comments into the same `Ast::Merge::Comment`-based model**

That is the path most consistent with:

- the existing `tree_haver` / `ast-merge` architecture
- the node normalization work already documented
- the requirement to preserve native AST smart merging while standardizing comments across the `*-merge` family
