# Comment Normalization Work Items

This document atomizes `docs/PLAN.md` into smaller implementation slices.

## Status Legend

- `[ ]` not started
- `[~]` in progress
- `[x]` complete
- `[!]` blocked / depends on another repo

## Ordering Principles

1. Land passive shared abstractions in `ast-merge` first.
2. Do not disturb native AST merge behavior while shared contracts are forming.
3. Add shared tests before migrating format gems.
4. Defer `tree_haver` API lock-in until `ast-merge` has proven consumers.
5. Migrate one weak backend first (`psych-merge`), then one strong backend (`prism-merge`).

---

## Epic 0: Planning, vocabulary, and sequencing

### CMT-0.1 Link the implementation backlog from the design plan
- Status: `[x]`
- Repo: `ast-merge`
- Deliverable:
  - This document exists and is linked from `docs/PLAN.md`
- Acceptance criteria:
  - Contributors can move from architecture to execution without reinterpreting the plan

### CMT-0.2 Establish stable terminology for comment ownership
- Status: `[ ]`
- Repo: `ast-merge`
- Deliverable:
  - Define canonical terms: `leading`, `inline`, `trailing`, `orphan`, `preamble`, `postlude`
- Acceptance criteria:
  - Terms are documented once and reused across code, tests, and migration docs

### CMT-0.3 Build an initial backend capability inventory
- Status: `[ ]`
- Repo: `ast-merge`
- Depends on: `CMT-0.2`
- Deliverable:
  - Matrix of current support for `psych`, `prism`, `jsonc`, markdown backends, bash, toml
- Acceptance criteria:
  - Each backend is classified as `native_full`, `native_partial`, `native_comment_nodes_only`, `source_augmented`, or `none`

---

## Epic 1: Shared comment model in `ast-merge`

### CMT-1.1 Add `Ast::Merge::Comment::Capability`
- Status: `[x]`
- Repo: `ast-merge`
- Deliverable:
  - Passive value object describing comment support level and flags
- Acceptance criteria:
  - Supports the initial capability levels from `docs/PLAN.md`
  - Has focused unit tests
  - Does not yet affect merge behavior

### CMT-1.2 Add `Ast::Merge::Comment::Region`
- Status: `[x]`
- Repo: `ast-merge`
- Depends on: `CMT-0.2`
- Deliverable:
  - Passive merge-facing wrapper around one or more comment nodes
- Acceptance criteria:
  - Can represent ownership kind and source range
  - Can expose normalized content/signature
  - Has focused unit tests

### CMT-1.3 Add `Ast::Merge::Comment::Attachment`
- Status: `[x]`
- Repo: `ast-merge`
- Depends on: `CMT-1.2`
- Deliverable:
  - Passive per-node container for comment regions
- Acceptance criteria:
  - Supports leading/inline/trailing regions
  - Keeps ownership explicit without yet changing format gems
  - Has focused unit tests

### CMT-1.4 Add adapter helpers from raw hashes to comment nodes/regions
- Status: `[x]`
- Repo: `ast-merge`
- Depends on: `CMT-1.2`, `CMT-1.3`
- Deliverable:
  - Shared conversion helpers for existing hash-based comment trackers
- Acceptance criteria:
  - Existing format gems can adopt the shared model incrementally
  - No tree_haver dependency required for first adoption

### CMT-1.5 Add `Ast::Merge::Comment::Augmenter`
- Status: `[x]`
- Repo: `ast-merge`
- Depends on: `CMT-1.2`, `CMT-1.3`, `CMT-1.4`
- Deliverable:
  - Shared source-based augmentation pipeline
- Acceptance criteria:
  - Can produce normalized comment regions from source text + AST location data
  - Supports parsers with no native comment support

### CMT-1.6 Add shared RSpec examples for comment normalization
- Status: `[ ]`
- Repo: `ast-merge`
- Depends on: `CMT-1.2`, `CMT-1.3`, `CMT-1.5`
- Deliverable:
  - Shared examples for regions, ownership, blank lines, freeze markers
- Acceptance criteria:
  - Merge gems can opt into a shared compliance suite

---

## Epic 2: Bridge shared comments into merge infrastructure

### CMT-2.1 Define merge-facing comment hooks in wrappers/analyses
- Status: `[ ]`
- Repo: `ast-merge`
- Depends on: `CMT-1.2`, `CMT-1.3`
- Deliverable:
  - Standard methods or conventions for exposing attachments from wrappers/analyses
- Acceptance criteria:
  - `NodeWrapperBase` integration path is documented
  - Existing raw `leading_comments` / `inline_comment` flows can be migrated incrementally

### CMT-2.2 Define emitter-facing comment contracts
- Status: `[ ]`
- Repo: `ast-merge`
- Depends on: `CMT-2.1`
- Deliverable:
  - Shared conventions for emitting leading/inline/trailing/orphan regions
- Acceptance criteria:
  - Format emitters can consume normalized comment regions consistently

### CMT-2.3 Integrate freeze markers with normalized comment regions
- Status: `[ ]`
- Repo: `ast-merge`
- Depends on: `CMT-1.5`
- Deliverable:
  - Shared freeze detection on normalized comment nodes/regions
- Acceptance criteria:
  - Freeze behavior works for both native and augmented comment paths

### CMT-2.4 Decide where `Ast::Merge::Text` is used as a sub-merge engine
- Status: `[ ]`
- Repo: `ast-merge`
- Depends on: `CMT-1.5`
- Deliverable:
  - Explicit rules for when comment-only regions should be merged textually
- Acceptance criteria:
  - No ambiguity about top-level structured merge vs comment-region sub-merge

---

## Epic 3: `tree_haver` parser-facing capability contract

### CMT-3.1 Define comment capability reporting API
- Status: `[ ]`
- Repo: `tree_haver`
- Depends on: `CMT-1.1`
- Deliverable:
  - Backend-reported comment support level
- Acceptance criteria:
  - Can distinguish at least full / partial / nodes-only / none

### CMT-3.2 Define normalized comment wrapper contract
- Status: `[ ]`
- Repo: `tree_haver`
- Depends on: `CMT-3.1`
- Deliverable:
  - Parser-facing comment wrapper with text/type/location support
- Acceptance criteria:
  - `ast-merge` can map wrapper instances into `Ast::Merge::Comment::*`

### CMT-3.3 Add optional attachment hints for strong backends
- Status: `[ ]`
- Repo: `tree_haver`
- Depends on: `CMT-3.2`
- Deliverable:
  - Leading/trailing/inline hints where native parsers can provide them
- Acceptance criteria:
  - Hints are clearly optional and capability-gated

### CMT-3.4 Add backend capability tests
- Status: `[ ]`
- Repo: `tree_haver`
- Depends on: `CMT-3.1`, `CMT-3.2`
- Deliverable:
  - Tests for capability reporting and comment wrapper fidelity
- Acceptance criteria:
  - Backends can be validated consistently without merge-specific semantics

---

## Epic 4: Pilot migration in `psych-merge`

### CMT-4.1 Replace raw comment hashes with shared comment node conversion
- Status: `[~]`
- Repo: `psych-merge`
- Depends on: `CMT-1.4`
- Deliverable:
  - Adapter from `CommentTracker` output into shared comment nodes/regions
- Acceptance criteria:
  - Existing behavior preserved while moving off raw hashes

### CMT-4.2 Introduce shared attachments for YAML mapping entries and nodes
- Status: `[ ]`
- Repo: `psych-merge`
- Depends on: `CMT-1.3`, `CMT-4.1`
- Deliverable:
  - Mapping entries and node wrappers expose standardized comment attachments
- Acceptance criteria:
  - Section comments, inline comments, and EOF comment blocks survive merges

### CMT-4.3 Route YAML emission through normalized comment regions
- Status: `[ ]`
- Repo: `psych-merge`
- Depends on: `CMT-2.2`, `CMT-4.2`
- Deliverable:
  - Emitter/resolver uses shared region semantics instead of bespoke hash logic
- Acceptance criteria:
  - `kettle-jem` / `.kettle-jem.yml` regression remains green

### CMT-4.4 Add shared compliance specs to `psych-merge`
- Status: `[ ]`
- Repo: `psych-merge`
- Depends on: `CMT-1.6`, `CMT-4.3`
- Deliverable:
  - YAML-specific adoption of shared comment behavior suite
- Acceptance criteria:
  - `psych-merge` demonstrates the source-augmented path end-to-end

---

## Epic 5: Pilot migration in `prism-merge`

### CMT-5.1 Inventory current native comment support in Ruby/Prism path
- Status: `[ ]`
- Repo: `prism-merge`
- Depends on: `CMT-0.3`, `CMT-3.1`
- Deliverable:
  - Document which comments are native vs inferred today
- Acceptance criteria:
  - Strong backend migration scope is explicit before code changes

### CMT-5.2 Map native Ruby comments into shared attachments
- Status: `[ ]`
- Repo: `prism-merge`
- Depends on: `CMT-1.3`, `CMT-3.3`
- Deliverable:
  - Native comments converted into standardized merge-facing structures
- Acceptance criteria:
  - Ruby keeps native fidelity while sharing the same merge-facing model as YAML

### CMT-5.3 Preserve Ruby-specific comment semantics
- Status: `[ ]`
- Repo: `prism-merge`
- Depends on: `CMT-5.2`
- Deliverable:
  - Magic comments and Ruby-specific behavior stay in `prism-merge`
- Acceptance criteria:
  - Shared model does not erase Ruby-specific meaning

### CMT-5.4 Add shared compliance specs to `prism-merge`
- Status: `[ ]`
- Repo: `prism-merge`
- Depends on: `CMT-1.6`, `CMT-5.3`
- Deliverable:
  - Native-full path validated against the same comment behavior suite
- Acceptance criteria:
  - `prism-merge` proves standardization does not require synthetic downgrade

---

## Epic 6: Expand across the gem family

### CMT-6.1 `jsonc-merge`
- Status: `[ ]`
- Repo: `jsonc-merge`
- Notes:
  - High-value early adopter because comments are semantically important to the format

### CMT-6.2 Markdown-family merge gems
- Status: `[ ]`
- Repo: `markdown-merge`, `markly-merge`, `commonmarker-merge`
- Notes:
  - Special attention needed for HTML comments and text extraction semantics

### CMT-6.3 `bash-merge`
- Status: `[ ]`
- Repo: `bash-merge`

### CMT-6.4 `toml-merge`
- Status: `[ ]`
- Repo: `toml-merge`

---

## Suggested Immediate Slice

This is the smallest slice that moves the architecture forward without broad coordination:

1. `CMT-0.1` Link backlog from `docs/PLAN.md`
2. `CMT-1.1` Add `Ast::Merge::Comment::Capability`
3. `CMT-1.2` Add `Ast::Merge::Comment::Region`
4. `CMT-1.3` Add `Ast::Merge::Comment::Attachment`
5. Add focused unit tests for all three
6. Stop before changing any merge gem behavior

If we want an even smaller first slice, land only:

1. `CMT-0.1`
2. `CMT-1.1`

That gives us a stable capability vocabulary before introducing region/attachment semantics.
