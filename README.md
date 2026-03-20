[![Galtzo FLOSS Logo by Aboling0, CC BY-SA 4.0][🖼️galtzo-i]][🖼️galtzo-discord] [![ruby-lang Logo, Yukihiro Matsumoto, Ruby Visual Identity Team, CC BY-SA 2.5][🖼️ruby-lang-i]][🖼️ruby-lang] [![kettle-rb Logo by Aboling0, CC BY-SA 4.0][🖼️kettle-rb-i]][🖼️kettle-rb]

[🖼️galtzo-i]: https://logos.galtzo.com/assets/images/galtzo-floss/avatar-192px.svg
[🖼️galtzo-discord]: https://discord.gg/3qme4XHNKN
[🖼️ruby-lang-i]: https://logos.galtzo.com/assets/images/ruby-lang/avatar-192px.svg
[🖼️ruby-lang]: https://www.ruby-lang.org/
[🖼️kettle-rb-i]: https://logos.galtzo.com/assets/images/kettle-rb/avatar-192px.svg
[🖼️kettle-rb]: https://github.com/kettle-rb

# ☯️ Ast::Merge

[![Version][👽versioni]][👽dl-rank] [![GitHub tag (latest SemVer)][⛳️tag-img]][⛳️tag] [![License: MIT][📄license-img]][📄license-ref] [![Downloads Rank][👽dl-ranki]][👽dl-rank] [![Open Source Helpers][👽oss-helpi]][👽oss-help] [![CodeCov Test Coverage][🏀codecovi]][🏀codecov] [![Coveralls Test Coverage][🏀coveralls-img]][🏀coveralls] [![QLTY Test Coverage][🏀qlty-covi]][🏀qlty-cov] [![QLTY Maintainability][🏀qlty-mnti]][🏀qlty-mnt] [![CI Heads][🚎3-hd-wfi]][🚎3-hd-wf] [![CI Runtime Dependencies @ HEAD][🚎12-crh-wfi]][🚎12-crh-wf] [![CI Current][🚎11-c-wfi]][🚎11-c-wf] [![CI Truffle Ruby][🚎9-t-wfi]][🚎9-t-wf] [![Deps Locked][🚎13-🔒️-wfi]][🚎13-🔒️-wf] [![Deps Unlocked][🚎14-🔓️-wfi]][🚎14-🔓️-wf] [![CI Supported][🚎6-s-wfi]][🚎6-s-wf] [![CI Test Coverage][🚎2-cov-wfi]][🚎2-cov-wf] [![CI Style][🚎5-st-wfi]][🚎5-st-wf] [![CodeQL][🖐codeQL-img]][🖐codeQL] [![Apache SkyWalking Eyes License Compatibility Check][🚎15-🪪-wfi]][🚎15-🪪-wf]

`if ci_badges.map(&:color).detect { it != "green"}` ☝️ [let me know][🖼️galtzo-discord], as I may have missed the [discord notification][🖼️galtzo-discord].

-----

`if ci_badges.map(&:color).all? { it == "green"}` 👇️ send money so I can do more of this. FLOSS maintenance is now my full-time job.

[![OpenCollective Backers][🖇osc-backers-i]][🖇osc-backers] [![OpenCollective Sponsors][🖇osc-sponsors-i]][🖇osc-sponsors] [![Sponsor Me on Github][🖇sponsor-img]][🖇sponsor] [![Liberapay Goal Progress][⛳liberapay-img]][⛳liberapay] [![Donate on PayPal][🖇paypal-img]][🖇paypal] [![Buy me a coffee][🖇buyme-small-img]][🖇buyme] [![Donate on Polar][🖇polar-img]][🖇polar] [![Donate at ko-fi.com][🖇kofi-img]][🖇kofi]

<details>
    <summary>👣 How will this project approach the September 2025 hostile takeover of RubyGems? 🚑️</summary>

I've summarized my thoughts in [this blog post](https://dev.to/galtzo/hostile-takeover-of-rubygems-my-thoughts-5hlo).

</details>

## 🌻 Synopsis

Ast::Merge is **not typically used directly** - instead, use one of the format-specific gems built on top of it.

### The `*-merge` Gem Family

The `*-merge` gem family provides intelligent, AST-based merging for various file formats. At the foundation is [tree_haver][tree_haver], which provides a unified cross-Ruby parsing API that works seamlessly across MRI, JRuby, and TruffleRuby.

| Gem                                      |                                                         Version / CI                                                         | Language<br>/ Format | Parser Backend(s)                                                                                     | Description                                                                      |
|------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------:|----------------------|-------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| [tree_haver][tree_haver]                 |                 [![Version][tree_haver-gem-i]][tree_haver-gem] <br/> [![CI][tree_haver-ci-i]][tree_haver-ci]                 | Multi                | Supported Backends: MRI C, Rust, FFI, Java, Prism, Psych, Commonmarker, Markly, Citrus, Parslet       | **Foundation**: Cross-Ruby adapter for parsing libraries (like Faraday for HTTP) |
| [ast-merge][ast-merge]                   |                   [![Version][ast-merge-gem-i]][ast-merge-gem] <br/> [![CI][ast-merge-ci-i]][ast-merge-ci]                   | Text                 | internal                                                                                              | **Infrastructure**: Shared base classes and merge logic for all `*-merge` gems   |
| [bash-merge][bash-merge]                 |                 [![Version][bash-merge-gem-i]][bash-merge-gem] <br/> [![CI][bash-merge-ci-i]][bash-merge-ci]                 | Bash                 | [tree-sitter-bash][ts-bash] (via tree_haver)                                                          | Smart merge for Bash scripts                                                     |
| [commonmarker-merge][commonmarker-merge] | [![Version][commonmarker-merge-gem-i]][commonmarker-merge-gem] <br/> [![CI][commonmarker-merge-ci-i]][commonmarker-merge-ci] | Markdown             | [Commonmarker][commonmarker] (via tree_haver)                                                         | Smart merge for Markdown (CommonMark via comrak Rust)                            |
| [dotenv-merge][dotenv-merge]             |             [![Version][dotenv-merge-gem-i]][dotenv-merge-gem] <br/> [![CI][dotenv-merge-ci-i]][dotenv-merge-ci]             | Dotenv               | internal                                                                                              | Smart merge for `.env` files                                                     |
| [json-merge][json-merge]                 |                 [![Version][json-merge-gem-i]][json-merge-gem] <br/> [![CI][json-merge-ci-i]][json-merge-ci]                 | JSON                 | [tree-sitter-json][ts-json] (via tree_haver)                                                          | Smart merge for JSON files                                                       |
| [jsonc-merge][jsonc-merge]               |               [![Version][jsonc-merge-gem-i]][jsonc-merge-gem] <br/> [![CI][jsonc-merge-ci-i]][jsonc-merge-ci]               | JSONC                | [tree-sitter-jsonc][ts-jsonc] (via tree_haver)                                                        | ⚠️ Proof of concept; Smart merge for JSON with Comments                          |
| [markdown-merge][markdown-merge]         |         [![Version][markdown-merge-gem-i]][markdown-merge-gem] <br/> [![CI][markdown-merge-ci-i]][markdown-merge-ci]         | Markdown             | [Commonmarker][commonmarker] / [Markly][markly] (via tree_haver), [Parslet][parslet]                  | **Foundation**: Shared base for Markdown mergers with inner code block merging   |
| [markly-merge][markly-merge]             |             [![Version][markly-merge-gem-i]][markly-merge-gem] <br/> [![CI][markly-merge-ci-i]][markly-merge-ci]             | Markdown             | [Markly][markly] (via tree_haver)                                                                     | Smart merge for Markdown (CommonMark via cmark-gfm C)                            |
| [prism-merge][prism-merge]               |               [![Version][prism-merge-gem-i]][prism-merge-gem] <br/> [![CI][prism-merge-ci-i]][prism-merge-ci]               | Ruby                 | [Prism][prism] (`prism` std lib gem)                                                                  | Smart merge for Ruby source files                                                |
| [psych-merge][psych-merge]               |               [![Version][psych-merge-gem-i]][psych-merge-gem] <br/> [![CI][psych-merge-ci-i]][psych-merge-ci]               | YAML                 | [Psych][psych] (`psych` std lib gem)                                                                  | Smart merge for YAML files                                                       |
| [rbs-merge][rbs-merge]                   |                   [![Version][rbs-merge-gem-i]][rbs-merge-gem] <br/> [![CI][rbs-merge-ci-i]][rbs-merge-ci]                   | RBS                  | [tree-sitter-rbs][ts-rbs] (via tree_haver), [RBS][rbs] (`rbs` std lib gem)                            | Smart merge for Ruby type signatures                                             |
| [toml-merge][toml-merge]                 |                 [![Version][toml-merge-gem-i]][toml-merge-gem] <br/> [![CI][toml-merge-ci-i]][toml-merge-ci]                 | TOML                 | [Parslet + toml][toml], [Citrus + toml-rb][toml-rb], [tree-sitter-toml][ts-toml] (all via tree_haver) | Smart merge for TOML files                                                       |

#### Backend Platform Compatibility

tree_haver supports multiple parsing backends, but not all backends work on all Ruby platforms:

| Platform 👉️<br> TreeHaver Backend 👇️          | MRI | JRuby | TruffleRuby | Notes                                                                      |
|-------------------------------------------------|:---:|:-----:|:-----------:|----------------------------------------------------------------------------|
| **MRI** ([ruby_tree_sitter][ruby_tree_sitter])  |  ✅  |   ❌   |      ❌      | C extension, MRI only                                                      |
| **Rust** ([tree_stump][tree_stump])             |  ✅  |   ❌   |      ❌      | Rust extension via magnus/rb-sys, MRI only                                 |
| **FFI** ([ffi][ffi])                            |  ✅  |   ✅   |      ❌      | TruffleRuby's FFI doesn't support `STRUCT_BY_VALUE`                        |
| **Java** ([jtreesitter][jtreesitter])           |  ❌  |   ✅   |      ❌      | JRuby only, requires grammar JARs                                          |
| **Prism** ([prism][prism])                      |  ✅  |   ✅   |      ✅      | Ruby parsing, stdlib in Ruby 3.4+                                          |
| **Psych** ([psych][psych])                      |  ✅  |   ✅   |      ✅      | YAML parsing, stdlib                                                       |
| **Citrus** ([citrus][citrus])                   |  ✅  |   ✅   |      ✅      | Pure Ruby PEG parser, no native dependencies                               |
| **Parslet** ([parslet][parslet])                |  ✅  |   ✅   |      ✅      | Pure Ruby PEG parser, no native dependencies                               |
| **Commonmarker** ([commonmarker][commonmarker]) |  ✅  |   ❌   |      ❓      | Rust extension for Markdown (via [commonmarker-merge][commonmarker-merge]) |
| **Markly** ([markly][markly])                   |  ✅  |   ❌   |      ❓      | C extension for Markdown  (via [markly-merge][markly-merge])               |

**Legend**: ✅ = Works, ❌ = Does not work, ❓ = Untested

**Why some backends don't work on certain platforms**:

- **JRuby**: Runs on the JVM; cannot load native C/Rust extensions (`.so` files)
- **TruffleRuby**: Has C API emulation via Sulong/LLVM, but it doesn't expose all MRI internals that native extensions require (e.g., `RBasic.flags`, `rb_gc_writebarrier`)
- **FFI on TruffleRuby**: TruffleRuby's FFI implementation doesn't support returning structs by value, which tree-sitter's C API requires

**Example implementations** for the gem templating use case:

| Gem                      | Purpose         | Description                                   |
|--------------------------|-----------------|-----------------------------------------------|
| [kettle-dev][kettle-dev] | Gem Development | Gem templating tool using `*-merge` gems      |
| [kettle-jem][kettle-jem] | Gem Templating  | Gem template library with smart merge support |

[tree_haver]: https://github.com/kettle-rb/tree_haver
[ast-merge]: https://github.com/kettle-rb/ast-merge
[prism-merge]: https://github.com/kettle-rb/prism-merge
[psych-merge]: https://github.com/kettle-rb/psych-merge
[json-merge]: https://github.com/kettle-rb/json-merge
[jsonc-merge]: https://github.com/kettle-rb/jsonc-merge
[bash-merge]: https://github.com/kettle-rb/bash-merge
[rbs-merge]: https://github.com/kettle-rb/rbs-merge
[dotenv-merge]: https://github.com/kettle-rb/dotenv-merge
[toml-merge]: https://github.com/kettle-rb/toml-merge
[markdown-merge]: https://github.com/kettle-rb/markdown-merge
[markly-merge]: https://github.com/kettle-rb/markly-merge
[commonmarker-merge]: https://github.com/kettle-rb/commonmarker-merge
[kettle-dev]: https://github.com/kettle-rb/kettle-dev
[kettle-jem]: https://github.com/kettle-rb/kettle-jem
[tree_haver-gem]: https://bestgems.org/gems/tree_haver
[ast-merge-gem]: https://bestgems.org/gems/ast-merge
[prism-merge-gem]: https://bestgems.org/gems/prism-merge
[psych-merge-gem]: https://bestgems.org/gems/psych-merge
[json-merge-gem]: https://bestgems.org/gems/json-merge
[jsonc-merge-gem]: https://bestgems.org/gems/jsonc-merge
[bash-merge-gem]: https://bestgems.org/gems/bash-merge
[rbs-merge-gem]: https://bestgems.org/gems/rbs-merge
[dotenv-merge-gem]: https://bestgems.org/gems/dotenv-merge
[toml-merge-gem]: https://bestgems.org/gems/toml-merge
[markdown-merge-gem]: https://bestgems.org/gems/markdown-merge
[markly-merge-gem]: https://bestgems.org/gems/markly-merge
[commonmarker-merge-gem]: https://bestgems.org/gems/commonmarker-merge
[kettle-dev-gem]: https://bestgems.org/gems/kettle-dev
[kettle-jem-gem]: https://bestgems.org/gems/kettle-jem
[tree_haver-gem-i]: https://img.shields.io/gem/v/tree_haver.svg
[ast-merge-gem-i]: https://img.shields.io/gem/v/ast-merge.svg
[prism-merge-gem-i]: https://img.shields.io/gem/v/prism-merge.svg
[psych-merge-gem-i]: https://img.shields.io/gem/v/psych-merge.svg
[json-merge-gem-i]: https://img.shields.io/gem/v/json-merge.svg
[jsonc-merge-gem-i]: https://img.shields.io/gem/v/jsonc-merge.svg
[bash-merge-gem-i]: https://img.shields.io/gem/v/bash-merge.svg
[rbs-merge-gem-i]: https://img.shields.io/gem/v/rbs-merge.svg
[dotenv-merge-gem-i]: https://img.shields.io/gem/v/dotenv-merge.svg
[toml-merge-gem-i]: https://img.shields.io/gem/v/toml-merge.svg
[markdown-merge-gem-i]: https://img.shields.io/gem/v/markdown-merge.svg
[markly-merge-gem-i]: https://img.shields.io/gem/v/markly-merge.svg
[commonmarker-merge-gem-i]: https://img.shields.io/gem/v/commonmarker-merge.svg
[kettle-dev-gem-i]: https://img.shields.io/gem/v/kettle-dev.svg
[kettle-jem-gem-i]: https://img.shields.io/gem/v/kettle-jem.svg
[tree_haver-ci-i]: https://github.com/kettle-rb/tree_haver/actions/workflows/current.yml/badge.svg
[ast-merge-ci-i]: https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml/badge.svg
[prism-merge-ci-i]: https://github.com/kettle-rb/prism-merge/actions/workflows/current.yml/badge.svg
[psych-merge-ci-i]: https://github.com/kettle-rb/psych-merge/actions/workflows/current.yml/badge.svg
[json-merge-ci-i]: https://github.com/kettle-rb/json-merge/actions/workflows/current.yml/badge.svg
[jsonc-merge-ci-i]: https://github.com/kettle-rb/jsonc-merge/actions/workflows/current.yml/badge.svg
[bash-merge-ci-i]: https://github.com/kettle-rb/bash-merge/actions/workflows/current.yml/badge.svg
[rbs-merge-ci-i]: https://github.com/kettle-rb/rbs-merge/actions/workflows/current.yml/badge.svg
[dotenv-merge-ci-i]: https://github.com/kettle-rb/dotenv-merge/actions/workflows/current.yml/badge.svg
[toml-merge-ci-i]: https://github.com/kettle-rb/toml-merge/actions/workflows/current.yml/badge.svg
[markdown-merge-ci-i]: https://github.com/kettle-rb/markdown-merge/actions/workflows/current.yml/badge.svg
[markly-merge-ci-i]: https://github.com/kettle-rb/markly-merge/actions/workflows/current.yml/badge.svg
[commonmarker-merge-ci-i]: https://github.com/kettle-rb/commonmarker-merge/actions/workflows/current.yml/badge.svg
[kettle-dev-ci-i]: https://github.com/kettle-rb/kettle-dev/actions/workflows/current.yml/badge.svg
[kettle-jem-ci-i]: https://github.com/kettle-rb/kettle-jem/actions/workflows/current.yml/badge.svg
[tree_haver-ci]: https://github.com/kettle-rb/tree_haver/actions/workflows/current.yml
[ast-merge-ci]: https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml
[prism-merge-ci]: https://github.com/kettle-rb/prism-merge/actions/workflows/current.yml
[psych-merge-ci]: https://github.com/kettle-rb/psych-merge/actions/workflows/current.yml
[json-merge-ci]: https://github.com/kettle-rb/json-merge/actions/workflows/current.yml
[jsonc-merge-ci]: https://github.com/kettle-rb/jsonc-merge/actions/workflows/current.yml
[bash-merge-ci]: https://github.com/kettle-rb/bash-merge/actions/workflows/current.yml
[rbs-merge-ci]: https://github.com/kettle-rb/rbs-merge/actions/workflows/current.yml
[dotenv-merge-ci]: https://github.com/kettle-rb/dotenv-merge/actions/workflows/current.yml
[toml-merge-ci]: https://github.com/kettle-rb/toml-merge/actions/workflows/current.yml
[markdown-merge-ci]: https://github.com/kettle-rb/markdown-merge/actions/workflows/current.yml
[markly-merge-ci]: https://github.com/kettle-rb/markly-merge/actions/workflows/current.yml
[commonmarker-merge-ci]: https://github.com/kettle-rb/commonmarker-merge/actions/workflows/current.yml
[kettle-dev-ci]: https://github.com/kettle-rb/kettle-dev/actions/workflows/current.yml
[kettle-jem-ci]: https://github.com/kettle-rb/kettle-jem/actions/workflows/current.yml
[prism]: https://github.com/ruby/prism
[psych]: https://github.com/ruby/psych
[ffi]: https://github.com/ffi/ffi
[ts-json]: https://github.com/tree-sitter/tree-sitter-json
[ts-jsonc]: https://gitlab.com/WhyNotHugo/tree-sitter-jsonc
[ts-bash]: https://github.com/tree-sitter/tree-sitter-bash
[ts-rbs]: https://github.com/joker1007/tree-sitter-rbs
[ts-toml]: https://github.com/tree-sitter-grammars/tree-sitter-toml
[dotenv]: https://github.com/bkeepers/dotenv
[rbs]: https://github.com/ruby/rbs
[toml-rb]: https://github.com/emancu/toml-rb
[toml]: https://github.com/jm/toml
[markly]: https://github.com/ioquatix/markly
[commonmarker]: https://github.com/gjtorikian/commonmarker
[ruby_tree_sitter]: https://github.com/Faveod/ruby-tree-sitter
[tree_stump]: https://github.com/joker1007/tree_stump
[jtreesitter]: https://central.sonatype.com/artifact/io.github.tree-sitter/jtreesitter
[citrus]: https://github.com/mjackson/citrus
[parslet]: https://github.com/kschiess/parslet

### Architecture: tree\_haver + ast-merge + family layers

The `*-merge` gem family is built on a layered architecture:

#### Layer 1: tree\_haver (Parsing Foundation)

[tree\_haver][tree_haver] provides cross-Ruby parsing capabilities:

- **Universal Backend Support**: Automatically selects the best parsing backend for your Ruby implementation (MRI, JRuby, TruffleRuby)
- **10 Backend Options**: MRI C extensions, Rust bindings, FFI, Java (JRuby), language-specific parsers (Prism, Psych, Commonmarker, Markly), and pure Ruby fallback (Citrus)
- **Unified API**: Write parsing code once, run on any Ruby implementation
- **Grammar Discovery**: Built-in `GrammarFinder` for platform-aware grammar library discovery
- **Thread-Safe**: Language registry with thread-safe caching

#### Layer 2: ast-merge (Cross-format Merge Substrate)

Ast::Merge builds on tree\_haver to provide:

- **Base Classes**: `SmartMergerBase`, `ConflictResolverBase`, `MergeResultBase`, `FreezeNodeBase`, `PartialTemplateMergerBase`, and `DiffMapperBase`
- **Shared Modules and helpers**: `FileAnalyzable`, `MergerConfig`, `DebugLogger`, `NodeTyping`, `SectionTyping`, and `TrailingGroups`
- **Freeze Block Support**: Configurable marker patterns for multiple comment syntaxes
- **Region Detection**: `Ast::Merge::Detector::Base`, `FencedCodeBlock`, `YamlFrontmatter`, `TomlFrontmatter`, and `Detector::Mergeable`
- **Error Classes**: `ParseError`, `TemplateParseError`, `DestinationParseError`, and `PlaceholderCollisionError`
- **RSpec Shared Examples**: Test helpers for implementing new merge gems

#### Layer 3: Family-specialized shared layers

Some format families justify a shared middle layer above `ast-merge`.

Current example:

- **`markdown-merge`** — shared Markdown-family behavior such as parser-neutral Markdown orchestration, link-reference handling, and code-block delegation that should be shared across Markdown parser wrappers without forcing Markdown-specific logic into `ast-merge`

#### Layer 4: Thin wrappers and leaf format gems

- Thin wrappers such as `commonmarker-merge` and `markly-merge` provide backend-specific defaults on top of `markdown-merge`
- Leaf gems such as `prism-merge`, `psych-merge`, `json-merge`, and `bash-merge` adapt `ast-merge` to a specific format and parser stack

### AST-over-regex layer map

When deciding where new behavior belongs, use this routing rule:

| If the behavior is shared by... | Put it in... |
|---|---|
| multiple unrelated formats | `ast-merge` |
| multiple Markdown parser wrappers | `markdown-merge` |
| one wrapper's backend defaults only | that wrapper gem |
| one format/parser combination only | that leaf `*-merge` gem |

This keeps `ast-merge` focused on cross-format substrate while preserving room for intentional family-specialized layers.

### Shared capability inventory

These are the first shared capabilities to check before building a bespoke helper:

| Capability | Shared owner | Reach for it when you need... |
|---|---|---|
| `Ast::Merge::Comment::*` | `ast-merge` | normalized comment nodes, attachments, tracked comment regions, or comment-aware merge behavior |
| `Ast::Merge::Layout::*` | `ast-merge` | blank-line ownership, shared gap control, or edit-safe layout preservation |
| `Ast::Merge::StructuralEdit::*` | `ast-merge` | contiguous structural replace/remove/rehome primitives that preserve untouched source and can carry comment/layout boundary metadata |
| `Ast::Merge::TrailingGroups::*` | `ast-merge` | position-aware insertion of template-only nodes |
| `Ast::Merge::NodeTyping` / `SectionTyping` | `ast-merge` | type-aware preferences or section-aware merge policy |
| `Ast::Merge::PartialTemplateMergerBase` | `ast-merge` | section-scoped or region-scoped merges driven by structural boundaries |
| `Ast::Merge::Recipe::{Preset, Config, Runner}` | `ast-merge` | reusable recipe-backed merge policies, normalized partial-target contracts (`anchor`/`boundary` or `key_path`), and parser-family dispatch |
| `markdown-merge` shared layer | `markdown-merge` | behavior shared across Markdown parsers but not appropriate for the cross-format substrate |

If a prospective solution fits one of these rows, prefer extending that shared layer before introducing regex- or line-oriented merge logic.

For recipe-driven partial merges, the stock contract in `ast-merge` is now: exactly one normalized partial target per recipe, either a navigable structural target (`anchor` + optional `boundary`) or a hierarchical `key_path` target. That targeting contract is shared substrate; the parser-specific merger that fulfills it still belongs in the relevant leaf gem or family layer.

### Normalization ownership boundary

`ast-merge` deliberately does **not** treat every post-merge cleanup as shared substrate.

Use this routing rule:

- `ast-merge` owns **structural splice invariants** and **syntax-agnostic output guarantees**
- family layers such as `markdown-merge` own **family-specific normalization**
- leaf `*-merge` gems own **format/parser-local emitter polish**

In practice, `ast-merge` is the right place for things like:

- preserving structural ownership while recombining content
- guaranteeing stable section replacement / insertion boundaries
- preserving comment and layout attachments across edits
- exposing normalized recipe contracts and partial-target routing

It is **not** automatically the right place for things like:

- Markdown link-reference rehydration
- Markdown whitespace canon or other serializer-specific cleanup
- parser-local quoting, delimiter, or formatter preferences

If a normalization rule depends on one syntax family's rendering semantics, keep it in that family layer or leaf emitter unless it clearly proves reusable across unrelated formats.

### Current family hotspot focus

These are the highest-value places to look before adding new bespoke merge logic:

| Repo / layer | Current hotspot | Prefer to reuse or extend... |
|---|---|---|
| `ast-merge` | parser-family partial-template routing, structural edit primitives, shared capability discoverability | `ast-merge` substrate |
| `markdown-merge` | boundary between Markdown-family behavior and cross-format substrate | `markdown-merge` first, `ast-merge` only for proven cross-format needs |
| `kettle-jem` | README/CHANGELOG section parsing, Gemfile/Gemspec/Appraisals post-merge surgery | recipes, shared partial merges, and shared AST edit primitives |
| hash-comment family repos | repeated `comment_tracker.rb` implementations | `Ast::Merge::Comment::*` plus shared tracker bases |
| JSONC / C-style comment flows | repeated line/block comment tracking logic | shared C-style tracker primitives |

If your new work lands in one of these rows, assume there is probably a shared solution or a missing shared primitive worth extracting.

### Building a New `*-merge` Gem

`ast-merge` is the authoring foundation for the `*-merge` family, and the implementation guide is organized across these references:

- **Canonical guide**: [`BUILD_A_MERGE_GEM.md`](BUILD_A_MERGE_GEM.md)
- **Per-gem architecture reference**: [`MERGE_APPROACH.md`](MERGE_APPROACH.md)
- **Shared blank-line/layout model**: [`lib/ast/merge/layout/README.md`](lib/ast/merge/layout/README.md)
- **RSpec shared examples and registration**: [`lib/ast/merge/rspec/README.md`](lib/ast/merge/rspec/README.md)
- **Reference implementation**: [`lib/ast/merge/text/README.md`](lib/ast/merge/text/README.md)

If you are creating a new merge gem, the usual path is:

1. implement a `FileAnalysis` that exposes stable mergeable statements and signatures
2. choose either an inline `SmartMerger` or a delegated `ConflictResolver`
3. use cursor-based positional matching for duplicate signatures
4. adopt `Ast::Merge::TrailingGroups` for position-aware template-only insertion
5. add comments, freeze markers, recursive merge, regions, or partial-template support only as the format requires
6. wire the gem into the shared RSpec support and `MergeGemRegistry`

### Base Classes Reference

| Base Class             | Purpose                     | Key Methods to Implement               |
|------------------------|-----------------------------|----------------------------------------|
| `SmartMergerBase`      | Main merge orchestration    | `analysis_class`, `perform_merge`      |
| `ConflictResolverBase` | Resolve node conflicts      | `resolve_batch` or `resolve_node_pair` |
| `MergeResultBase`      | Track merge results         | `to_s`, format-specific output         |
| `PartialTemplateMergerBase` | Section-scoped merges | `create_analysis`, `create_smart_merger`, `find_section_end`, `node_to_text` |
| `DiffMapperBase`       | Unified diff parsing + AST path mapping foundation | `create_analysis`, `map_hunk_to_paths`, `build_path_for_node` |
| `MatchRefinerBase`     | Fuzzy node matching         | `similarity`                           |
| `ContentMatchRefiner`  | Text content fuzzy matching | Ready to use                           |
| `FileAnalyzable`       | File parsing/analysis       | `compute_node_signature`               |

`DiffMapperBase` and `PartialTemplateMergerBase` are opt-in authoring primitives. Format-specific gems provide the path-mapping, section-rendering logic, and any syntax-aware output cleanup that makes those workflows concrete for a particular syntax.

### ContentMatchRefiner

`Ast::Merge::ContentMatchRefiner` is a built-in match refiner for fuzzy text content matching using Levenshtein distance. Unlike signature-based matching which requires exact content hashes, this refiner allows matching nodes with similar (but not identical) content.

```ruby
# Basic usage - match nodes with 70% similarity
refiner = Ast::Merge::ContentMatchRefiner.new(threshold: 0.7)

# Only match specific node types
refiner = Ast::Merge::ContentMatchRefiner.new(
  threshold: 0.6,
  node_types: [:paragraph, :heading],
)

# Custom weights for scoring
refiner = Ast::Merge::ContentMatchRefiner.new(
  threshold: 0.7,
  weights: {
    content: 0.8,   # Levenshtein similarity (default: 0.7)
    length: 0.1,    # Length similarity (default: 0.15)
    position: 0.1,   # Position in document (default: 0.15)
  },
)

# Custom content extraction
refiner = Ast::Merge::ContentMatchRefiner.new(
  threshold: 0.7,
  content_extractor: ->(node) { node.text_content.downcase.strip },
)

# Use with a merger
merger = MyFormat::SmartMerger.new(
  template,
  destination,
  preference: :template,
  match_refiner: refiner,
)
```

This is particularly useful for:

- Paragraphs with minor edits (typos, rewording)
- Headings with slight changes
- Comments with updated text
- Any text-based node that may have been slightly modified

### Namespace Reference

The `Ast::Merge` module is organized into several namespaces, each with detailed documentation:

#### Authoring Guides

- [`BUILD_A_MERGE_GEM.md`](BUILD_A_MERGE_GEM.md) — canonical guide for implementing a new `*-merge` family gem
- [`MERGE_APPROACH.md`](MERGE_APPROACH.md) — merge-strategy comparison and per-gem examples

| Namespace              | Purpose                            | Documentation                                                        |
|------------------------|------------------------------------|----------------------------------------------------------------------|
| `Ast::Merge::Detector` | Region detection and merging       | [lib/ast/merge/detector/README.md](lib/ast/merge/detector/README.md) |
| `Ast::Merge::Recipe`   | YAML-based merge recipes           | [lib/ast/merge/recipe/README.md](lib/ast/merge/recipe/README.md)     |
| `Ast::Merge::Comment`  | Comment parsing and representation | [lib/ast/merge/comment/README.md](lib/ast/merge/comment/README.md)   |
| `Ast::Merge::Layout`   | Shared blank-line layout ownership | [lib/ast/merge/layout/README.md](lib/ast/merge/layout/README.md)     |
| `Ast::Merge::Text`     | Plain text AST parsing             | [lib/ast/merge/text/README.md](lib/ast/merge/text/README.md)         |
| `Ast::Merge::RSpec`    | Shared RSpec examples              | [lib/ast/merge/rspec/README.md](lib/ast/merge/rspec/README.md)       |

**Key Classes by Namespace:**

- **Detector**: `Region`, `Base`, `Mergeable`, `FencedCodeBlock`, `YamlFrontmatter`, `TomlFrontmatter`
- **Recipe**: `Preset`, `Config`, `Runner`, `ScriptLoader`
- **Comment**: `Line`, `Block`, `Empty`, `Parser`, `Style`
- **Layout**: `Gap`, `Attachment`, `Augmenter`
- **Text**: `SmartMerger`, `FileAnalysis`, `LineNode`, `WordNode`, `Section`, `LineSectionSplitter`
- **RSpec**: Shared examples and dependency tags for testing `*-merge` implementations

## 💡 Info you can shake a stick at

| Tokens to Remember      | [![Gem name][⛳️name-img]][👽dl-rank] [![Gem namespace][⛳️namespace-img]][📜src-gh]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
|-------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Works with JRuby        | [![JRuby 10.0 Compat][💎jruby-c-i]][🚎11-c-wf] [![JRuby HEAD Compat][💎jruby-headi]][🚎3-hd-wf]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| Works with Truffle Ruby | [![Truffle Ruby 23.1 Compat][💎truby-23.1i]][🚎9-t-wf] [![Truffle Ruby 24.1 Compat][💎truby-c-i]][🚎11-c-wf]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| Works with MRI Ruby 3   | [![Ruby 3.2 Compat][💎ruby-3.2i]][🚎6-s-wf] [![Ruby 3.3 Compat][💎ruby-3.3i]][🚎6-s-wf] [![Ruby 3.4 Compat][💎ruby-c-i]][🚎11-c-wf] [![Ruby HEAD Compat][💎ruby-headi]][🚎3-hd-wf]                                                                                                                                 |
| Support & Community     | [![Join Me on Daily.dev's RubyFriends][✉️ruby-friends-img]][✉️ruby-friends] [![Live Chat on Discord][✉️discord-invite-img-ftb]][🖼️galtzo-discord] [![Get help from me on Upwork][👨🏼‍🏫expsup-upwork-img]][👨🏼‍🏫expsup-upwork] [![Get help from me on Codementor][👨🏼‍🏫expsup-codementor-img]][👨🏼‍🏫expsup-codementor]                                                             |
| Source                  | [![Source on GitLab.com][📜src-gl-img]][📜src-gl] [![Source on CodeBerg.org][📜src-cb-img]][📜src-cb] [![Source on Github.com][📜src-gh-img]][📜src-gh] [![The best SHA: dQw4w9WgXcQ\!](https://img.shields.io/badge/KLOC-3.271-FFDD67.svg?style=for-the-badge&logo=YouTube&logoColor=blue)][🧮kloc]                                                                                                                                                                                                               |
| Documentation           | [![Current release on RubyDoc.info][📜docs-cr-rd-img]][🚎yard-current] [![YARD on Galtzo.com][📜docs-head-rd-img]][🚎yard-head] [![Maintainer Blog][🚂maint-blog-img]][🚂maint-blog] [![GitLab Wiki][📜gl-wiki-img]][📜gl-wiki] [![GitHub Wiki][📜gh-wiki-img]][📜gh-wiki] |
| Compliance              | [![License: MIT][📄license-img]][📄license-ref] [![Compatible with Apache Software Projects: Verified by SkyWalking Eyes][📄license-compat-img]][📄license-compat] [![📄ilo-declaration-img][📄ilo-declaration-img]][📄ilo-declaration] [![Security Policy][🔐security-img]][🔐security] [![Contributor Covenant 2.1][🪇conduct-img]][🪇conduct] [![SemVer 2.0.0][📌semver-img]][📌semver]                    |
| Style                   | [![Enforced Code Style Linter][💎rlts-img]][💎rlts] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog] [![Gitmoji Commits][📌gitmoji-img]][📌gitmoji] [![Compatibility appraised by: appraisal2][💎appraisal2-img]][💎appraisal2]                                                                                                                                                                                                             |
| Maintainer 🎖️          | [![Follow Me on LinkedIn][💖🖇linkedin-img]][💖🖇linkedin] [![Follow Me on Ruby.Social][💖🐘ruby-mast-img]][💖🐘ruby-mast] [![Follow Me on Bluesky][💖🦋bluesky-img]][💖🦋bluesky] [![Contact Maintainer][🚂maint-contact-img]][🚂maint-contact] [![My technical writing][💖💁🏼‍♂️devto-img]][💖💁🏼‍♂️devto]                                                                    |
| `...` 💖                | [![Find Me on WellFound:][💖✌️wellfound-img]][💖✌️wellfound] [![Find Me on CrunchBase][💖💲crunchbase-img]][💖💲crunchbase] [![My LinkTree][💖🌳linktree-img]][💖🌳linktree] [![More About Me][💖💁🏼‍♂️aboutme-img]][💖💁🏼‍♂️aboutme] [🧊][💖🧊berg] [🐙][💖🐙hub]  [🛖][💖🛖hut] [🧪][💖🧪lab]                                                                                                                                                                                                  |

### Compatibility

Compatible with MRI Ruby 3.2.0+, and concordant releases of JRuby, and TruffleRuby.

| 🚚 *Amazing* test matrix was brought to you by | 🔎 appraisal2 🔎 and the color 💚 green 💚                                           |
|------------------------------------------------|--------------------------------------------------------------------------------------|
| 👟 Check it out\!                              | ✨ [github.com/appraisal-rb/appraisal2][💎appraisal2] ✨ |

### Federated DVCS

<details markdown="1">
  <summary>Find this repo on federated forges (Coming soon!)</summary>

| Federated [DVCS][💎d-in-dvcs] Repository | Status                                                                                                                                        | Issues                                                | PRs                                                           | Wiki                                                      | CI                                    | Discussions                                              |
|-----------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------|---------------------------------------------------------------|-----------------------------------------------------------|---------------------------------------|----------------------------------------------------------|
| 🧪 [kettle-rb/ast-merge on GitLab][📜src-gl]       | The Truth                                                                                                                                     | [💚][🤝gl-issues] | [💚][🤝gl-pulls] | [💚][📜gl-wiki] | 🐭 Tiny Matrix                        | ➖                                                        |
| 🧊 [kettle-rb/ast-merge on CodeBerg][📜src-cb]    | An Ethical Mirror ([Donate][🤝cb-donate])                                                                                    | [💚][🤝cb-issues] | [💚][🤝cb-pulls]          | ➖                                                         | ⭕️ No Matrix                          | ➖                                                        |
| 🐙 [kettle-rb/ast-merge on GitHub][📜src-gh]        | Another Mirror                                                                                                                                | [💚][🤝gh-issues]   | [💚][🤝gh-pulls]            | [💚][📜gh-wiki]         | 💯 Full Matrix                        | [💚][gh-discussions] |
| 🎮️ [Discord Server][🖼️galtzo-discord]                               | [![Live Chat on Discord][✉️discord-invite-img-ftb]][🖼️galtzo-discord] | [Let's][🖼️galtzo-discord]                | [talk][🖼️galtzo-discord]                         | [about][🖼️galtzo-discord]                    | [this][🖼️galtzo-discord] | [library\!][🖼️galtzo-discord]               |

</details>

[gh-discussions]: https://github.com/kettle-rb/ast-merge/discussions

### Enterprise Support [![Tidelift](https://tidelift.com/badges/package/rubygems/ast-merge)][🏙️entsup-tidelift]

Available as part of the Tidelift Subscription.

<details markdown="1">
  <summary>Need enterprise-level guarantees?</summary>

The maintainers of this and thousands of other packages are working with Tidelift to deliver commercial support and maintenance for the open source packages you use to build your applications. Save time, reduce risk, and improve code health, while paying the maintainers of the exact packages you use.

[![Get help from me on Tidelift][🏙️entsup-tidelift-img]][🏙️entsup-tidelift]

- 💡Subscribe for support guarantees covering *all* your FLOSS dependencies
- 💡Tidelift is part of [Sonar][🏙️entsup-tidelift-sonar]
- 💡Tidelift pays maintainers to maintain the software you depend on\!<br/>📊`@`Pointy Haired Boss: An [enterprise support][🏙️entsup-tidelift] subscription is "[never gonna let you down][🧮kloc]", and *supports* open source maintainers
  Alternatively:
- [![Live Chat on Discord][✉️discord-invite-img-ftb]][🖼️galtzo-discord]
- [![Get help from me on Upwork][👨🏼‍🏫expsup-upwork-img]][👨🏼‍🏫expsup-upwork]
- [![Get help from me on Codementor][👨🏼‍🏫expsup-codementor-img]][👨🏼‍🏫expsup-codementor]

</details>

## ✨ Installation

Install the gem and add to the application's Gemfile by executing:

```console
bundle add ast-merge
```

If bundler is not being used to manage dependencies, install the gem by executing:

```console
gem install ast-merge
```

### 🔒 Secure Installation

<details markdown="1">
  <summary>For Medium or High Security Installations</summary>

This gem is cryptographically signed, and has verifiable [SHA-256 and SHA-512][💎SHA_checksums] checksums by
[stone\_checksums][💎stone_checksums]. Be sure the gem you install hasn’t been tampered with
by following the instructions below.

Add my public key (if you haven’t already, expires 2045-04-29) as a trusted certificate:

```console
gem cert --add <(curl -Ls https://raw.github.com/galtzo-floss/certs/main/pboling.pem)
```

You only need to do that once.  Then proceed to install with:

```console
gem install ast-merge -P HighSecurity
```

The `HighSecurity` trust profile will verify signed gems, and not allow the installation of unsigned dependencies.

If you want to up your security game full-time:

```console
bundle config set --global trust-policy MediumSecurity
```

`MediumSecurity` instead of `HighSecurity` is necessary if not all the gems you use are signed.

NOTE: Be prepared to track down certs for signed gems and add them the same way you added mine.

</details>

## ⚙️ Configuration

`ast-merge` provides base classes and shared interfaces for building format-specific merge tools.
Each implementation (like `prism-merge`, `psych-merge`, etc.) has its own SmartMerger with format-specific configuration.

### Common Configuration Options

All SmartMerger implementations share these configuration options:

```ruby
merger = SomeFormat::Merge::SmartMerger.new(
  template,
  destination,
  # When conflicts occur, prefer template or destination values
  preference: :template,            # or :destination (default), or a Hash for per-node-type
  # Add nodes that only exist in template (Boolean or callable filter)
  add_template_only_nodes: true,    # default: false, or ->(node, entry) { ... }
  # Custom node type handling
  node_typing: {},                # optional, for per-node-type preference
)
```

### Signature Match Preference

Control which source wins when both files have the same structural element:

- **`:template`** - Template values replace destination values
- **`:destination`** (default) - Destination values are preserved
- **Hash** - Per-node-type preference (see Advanced Configuration)

### Template-Only Nodes

Control whether to add nodes that only exist in the template:

- **`true`** - Add all template-only nodes
- **`false`** (default) - Skip template-only nodes
- **Callable** - Filter which template-only nodes to add

#### Callable Filter

When you need fine-grained control over which template-only nodes are added, pass a callable (Proc/Lambda) that receives `(node, entry)` and returns truthy to add or falsey to skip:

```ruby
# Only add nodes with gem_family signatures
merger = SomeFormat::Merge::SmartMerger.new(
  template,
  destination,
  add_template_only_nodes: ->(node, entry) {
    sig = entry[:signature]
    sig.is_a?(Array) && sig.first == :gem_family
  },
)

# Only add link definitions that match a pattern
merger = Markly::Merge::SmartMerger.new(
  template,
  destination,
  add_template_only_nodes: ->(node, entry) {
    entry[:template_node].type == :link_definition &&
      entry[:signature]&.last&.include?("gem")
  },
)
```

The `entry` hash contains:

- `:template_node` - The node being considered for addition
- `:signature` - The node's signature (Array or other value)
- `:template_index` - Index in the template statements
- `:dest_index` - Always `nil` for template-only nodes

## 🔧 Basic Usage

### Using Shared Examples in Tests

```ruby
# spec/spec_helper.rb
require "ast/merge/rspec/shared_examples"

# spec/my_format/merge/freeze_node_spec.rb
RSpec.describe(MyFormat::Merge::FreezeNode) do
  it_behaves_like "Ast::Merge::FreezeNode" do
    let(:freeze_node_class) { described_class }
    let(:default_pattern_type) { :hash_comment }
    let(:build_freeze_node) do
      lambda { |start_line:, end_line:, **opts|
        # Build a freeze node for your format
      }
    end
  end
end
```

### Available Shared Examples

- `"Ast::Merge::FreezeNode"` - Tests for FreezeNode implementations
- `"Ast::Merge::MergeResult"` - Tests for MergeResult implementations
- `"Ast::Merge::DebugLogger"` - Tests for DebugLogger implementations
- `"Ast::Merge::FileAnalysisBase"` - Tests for FileAnalysis implementations
- `"Ast::Merge::MergerConfig"` - Tests for SmartMerger implementations

## 🎛️ Advanced Configuration

### Freeze Blocks

**Freeze blocks** are special comment-delimited regions in your files that tell the merge tool
to preserve content exactly as-is, preventing any changes from the template.
This is useful for hand-edited customizations you never want overwritten.

A freeze block consists of:

- A **start marker** comment (e.g., `# mytoken:freeze`)
- The protected content
- An **end marker** comment (e.g., `# mytoken:unfreeze`)

```ruby
# In a Ruby file with prism-merge:
class MyApp
  # prism-merge:freeze
  # Custom configuration that should never be overwritten
  CUSTOM_SETTING = "my-value"
  # prism-merge:unfreeze

  VERSION = "1.0.0"  # This can be updated by template
end
```

The `FreezeNode` class represents these protected regions internally.
Each format-specific merge gem (like `prism-merge`, `psych-merge`, etc.) configures its own
freeze token (the `token` in `token:freeze`), which defaults to the gem name (e.g., `prism-merge`).

### Supported Comment Patterns

Different file formats use different comment syntaxes. The merge tools detect freeze markers
using the appropriate pattern for each format:

| Pattern Type     | Start Marker            | End Marker                | Languages                                                                             |
|------------------|-------------------------|---------------------------|---------------------------------------------------------------------------------------|
| `:hash_comment`  | `# token:freeze`        | `# token:unfreeze`        | Ruby, Python, YAML, Bash, Shell                                                       |
| `:html_comment`  | `<!-- token:freeze -->` | `<!-- token:unfreeze -->` | HTML, XML, Markdown                                                                   |
| `:c_style_line`  | `// token:freeze`       | `// token:unfreeze`       | C (C99+), C++, JavaScript, TypeScript, Java, C\#, Go, Rust, Swift, Kotlin, PHP, JSONC |
| `:c_style_block` | `/* token:freeze */`    | `/* token:unfreeze */`    | C, C++, JavaScript, TypeScript, Java, C\#, Go, Rust, Swift, Kotlin, PHP, CSS          |

| 📍 NOTE                                                           |
|-------------------------------------------------------------------|
| CSS only supports block comments (`/* */`), not line comments.    |
| JSON does not support comments; use JSONC for JSON with comments. |

### Per-Node-Type Preference with `node_typing`

The `node_typing` option allows you to customize merge behavior on a per-node-type basis.
When combined with a Hash-based `preference`, you can specify different merge
preferences for different types of nodes (e.g., prefer template for linter configs but destination for everything else).

#### How It Works

1.  **Define a `node_typing`**: A Hash mapping node type symbols to callables that receive a node and return either:

    - The original node (no special handling)
    - A wrapped node with a `merge_type` attribute (via `Ast::Merge::NodeTyping::Wrapper`)

2.  **Use a Hash-based preference**: Instead of a simple `:destination` or `:template` Symbol, pass a Hash with:

    - `:default` key for the fallback preference
    - Custom keys matching the `merge_type` values from your `node_typing`

```ruby
# Example: Prefer template for lint gem configs, destination for everything else
node_typing = {
  call_node: ->(node) {
    if node.name == :gem && node.arguments&.arguments&.first&.unescaped&.match?(/rubocop|standard|reek/)
      Ast::Merge::NodeTyping::Wrapper.new(node, :lint_gem)
    else
      node
    end
  },
}

merger = Prism::Merge::SmartMerger.new(
  template_content,
  dest_content,
  node_typing: node_typing,
  preference: {
    default: :destination,
    lint_gem: :template,
  },
)
```

#### NodeTyping::Wrapper

The `Ast::Merge::NodeTyping::Wrapper` class wraps an AST node and adds a `merge_type` attribute.
It delegates all method calls to the wrapped node, so it can be used transparently in place of the original node.

```ruby
# Wrap a node with a custom merge_type
wrapped = Ast::Merge::NodeTyping::Wrapper.new(original_node, :special_config)
wrapped.merge_type  # => :special_config
wrapped.class       # => Ast::Merge::NodeTyping::Wrapper
wrapped.location    # => delegates to original_node.location
```

#### NodeTyping Utility Methods

```ruby
# Process a node through the node_typing configuration
processed = Ast::Merge::NodeTyping.process(node, node_typing_config)

# Check if a node has been wrapped with a merge_type
Ast::Merge::NodeTyping.typed_node?(node)  # => true/false

# Get the merge_type from a wrapped node (or nil)
Ast::Merge::NodeTyping.merge_type_for(node)  # => Symbol or nil

# Unwrap a node type wrapper to get the original
Ast::Merge::NodeTyping.unwrap(wrapped_node)  # => original_node
```

### Hash-Based Preference (without node\_typing)

Even without `node_typing`, you can use a Hash-based preference to set a default
and document your intention for future per-type customization:

```ruby
# Simple Hash preference (functionally equivalent to preference: :destination)
merger = MyMerger.new(
  template_content,
  dest_content,
  preference: {default: :destination},
)
```

### MergerConfig Factory Methods

The `MergerConfig` class provides factory methods that support all options:

```ruby
# Create config preferring destination
config = Ast::Merge::MergerConfig.destination_wins(
  freeze_token: "my-freeze",
  signature_generator: my_generator,
  node_typing: my_typing,
)

# Create config preferring template
config = Ast::Merge::MergerConfig.template_wins(
  freeze_token: "my-freeze",
  signature_generator: my_generator,
  node_typing: my_typing,
)
```

## 📋 YAML Merge Recipes

ast-merge includes a YAML-based recipe system for defining portable, distributable merge configurations. Recipes allow any project to ship merge knowledge as data — a YAML file (and optionally small companion Ruby scripts) — that consumers can load and execute without writing merge instrumentation.

### Preset vs Config (Recipe)

The recipe system provides two levels of configuration:

- **`Ast::Merge::Recipe::Preset`** — Merge configuration only (preference, signature generator, node typing, freeze token). Use when you have your own template/destination handling and just need the merge settings.
- **`Ast::Merge::Recipe::Config`** — Full recipe extending Preset with template file, target glob patterns, injection point configuration, and when_missing behavior.

`Recipe::Preset` is parser-agnostic and can be passed to any format-specific `SmartMerger`. `Recipe::Runner` is narrower: in the stock `ast-merge` gem it currently drives parser-specific partial-template mergers for Markdown via `:markly` / `:commonmarker` and for YAML via `:psych`.

### Minimal Recipe (Preset)

A simple preset recipe is just a YAML file — no companion folder or Ruby scripts required:

```yaml
name: my_config
description: Merge YAML config files with destination preference
parser: psych
merge:
  preference: destination
  add_missing: true
freeze_token: my-project
```

Load and use it:

```ruby
preset = Ast::Merge::Recipe::Preset.load("path/to/my_config.yml")
merger = Psych::Merge::SmartMerger.new(template, destination, **preset.to_h)
result = merger.merge
```

### Full Recipe (Config)

A full recipe adds template, targets, and partial-target configuration. In `ast-merge`, the built-in runner uses this flow for Markdown section updates:

```yaml
name: gem_family_section
description: Update gem family section in README files

# Template file (relative to recipe file)
template: GEM_FAMILY_SECTION.md

# Target files (supports globs)
targets:
  - README.md
  - vendor/*/README.md

# Where to inject/replace content
injection:
  anchor:
    type: heading
    text: "/Gem Family/"
  position: replace
  boundary:
    type: heading
    same_or_shallower: true

# Merge settings
merge:
  preference: template
  add_missing: true

# When anchor is not found in a target
when_missing: skip
```

Execute it:

```ruby
recipe = Ast::Merge::Recipe::Config.load("path/to/gem_family_section.yml")
runner = Ast::Merge::Recipe::Runner.new(recipe, dry_run: true, parser: :markly)
results = runner.run
puts runner.summary
# => { total: 10, updated: 5, unchanged: 3, skipped: 2 }
```

YAML partial recipes use `injection.key_path` instead of anchor/boundary targeting, for example:

```yaml
name: rubocop_excludes
template: rubocop_excludes.yml
targets:
  - .rubocop.yml

injection:
  key_path:
    - AllCops
    - Exclude

merge:
  preference: destination
  add_missing: true

when_missing: add
```

For other formats, the durable interface in this gem is still `Preset#to_h`; callers pass that option hash to the format-specific merger they are using.

Or via CLI:

```bash
bin/ast-merge-recipe path/to/gem_family_section.yml --dry-run --parser=markly
```

### Recipe YAML Schema

#### Preset Fields (used by both Preset and Config)

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Recipe identifier |
| `description` | No | Human-readable description |
| `parser` | No | Parser identifier stored on the preset/config. `Preset` defaults to `prism`; `Recipe::Runner` takes its parser separately and currently supports `markly`, `commonmarker`, and `psych`. |
| `merge.preference` | No | `:template` or `:destination`. Default: `:template` |
| `merge.add_missing` | No | `true`, `false`, or path to a Ruby script returning a callable filter. Default: `true` |
| `merge.signature_generator` | No | Path to companion Ruby script (relative to recipe folder) |
| `merge.node_typing` | No | Hash mapping node class names to companion Ruby script paths |
| `merge.match_refiner` | No | Path to companion Ruby script for match refinement |
| `merge.normalize_whitespace` | No | `true` to collapse excessive blank lines in markdown recipe flows |
| `merge.rehydrate_link_references` | No | `true` to convert inline links to reference style in markdown recipe flows |
| `freeze_token` | No | Token for freeze block preservation (e.g., `"my-project"`) |

#### Config-Only Fields (full recipes)

| Field | Required | Description |
|-------|----------|-------------|
| `template` | Yes | Path to template file (relative to recipe file or absolute) |
| `targets` | No | Array of glob patterns for target files. Default: `["*.md"]` |
| `injection.anchor.type` | No | Node type to match (e.g., `heading`, `paragraph`) |
| `injection.anchor.text` | No | Text pattern — string for exact match, `/regex/` for pattern |
| `injection.anchor.level` | No | Heading level (for heading anchors) |
| `injection.position` | No | `replace`, `before`, `after`, `first_child`, `last_child`. Default: `replace` |
| `injection.boundary.type` | No | Node type that marks the end of the section |
| `injection.boundary.same_or_shallower` | No | `true` to end at next same-level-or-higher heading |
| `injection.key_path` | No | Array path for parser-specific partial targets such as YAML keys (for example `['AllCops', 'Exclude']`) |
| `when_missing` | No | `skip`, `append`, `prepend`, or parser-specific options such as YAML `add`. Default: `skip` |

### Companion Scripts (Optional)

When a recipe needs custom signature matching or node categorization beyond the defaults, it can reference Ruby scripts in an optional companion folder. The folder name must match the recipe name (without `.yml`):

```
my-project/
  recipes/
    my_format.yml                    # The recipe
    my_format/                       # Optional companion folder
      signature_generator.rb         # Returns a lambda for node matching
      typing/
        call_node.rb                 # Returns a lambda for node categorization
```

Each script must return a callable (the last expression is the return value):

```ruby
# signature_generator.rb
lambda do |node|
  return node unless node.is_a?(Prism::CallNode)
  case node.name
  when :gem
    first_arg = node.arguments&.arguments&.first
    [:gem, first_arg.unescaped] if first_arg.is_a?(Prism::StringNode)
  when :source
    [:source]
  else
    node
  end
end
```

Scripts are loaded on demand via `Ast::Merge::Recipe::ScriptLoader` and cached for the lifetime of the preset.

### Text Matching in Anchor Patterns

When matching nodes by text content (e.g., heading anchors), the `.text` method returns **plain text without formatting**:

| Markdown Source | `.text` Returns |
|----------------|----------------|
| `` ### The `*-merge` Gem Family `` | `The *-merge Gem Family` |
| `**Bold text**` | `Bold text` |
| `[link text](url)` | `link text` |

Write patterns that match the plain text:

- Wrong: ``text: "/`\*-merge` Gem Family/"``
- Correct: ``text: "/\\*-merge Gem Family/"``

### Distributing Recipes

Recipes are designed to be portable. A project can ship recipes in its gem or repository:

- **Minimal recipes** (YAML only) need no companion folder — consumers only need `ast-merge`
- **Advanced recipes** (YAML + scripts) ship the companion folder alongside the YAML
- Consumers load recipes with `Ast::Merge::Recipe::Preset.load(path)` or `Config.load(path)` — no dependency on `kettle-jem` or any specific tool
- The [kettle-jem][kettle-jem] gem provides a collection of built-in recipes for common file types (Gemfile, gemspec, Rakefile, Appraisals, Markdown)

See [`lib/ast/merge/recipe/README.md`](lib/ast/merge/recipe/README.md) for additional details and examples.

## 🦷 FLOSS Funding

While kettle-rb tools are free software and will always be, the project would benefit immensely from some funding.
Raising a monthly budget of... "dollars" would make the project more sustainable.

We welcome both individual and corporate sponsors\! We also offer a
wide array of funding channels to account for your preferences
(although currently [Open Collective][🖇osc] is our preferred funding platform).

**If you're working in a company that's making significant use of kettle-rb tools we'd
appreciate it if you suggest to your company to become a kettle-rb sponsor.**

You can support the development of kettle-rb tools via
[GitHub Sponsors][🖇sponsor],
[Liberapay][⛳liberapay],
[PayPal][🖇paypal],
[Open Collective][🖇osc]
and [Tidelift][🏙️entsup-tidelift].

| 📍 NOTE |
| --- |
| If doing a sponsorship in the form of donation is problematic for your company <br/> from an accounting standpoint, we'd recommend the use of Tidelift, <br/> where you can get a support-like subscription instead. |

### Open Collective for Individuals

Support us with a monthly donation and help us continue our activities. \[[Become a backer][🖇osc-backers]\]

NOTE: [kettle-readme-backers][kettle-readme-backers] updates this list every day, automatically.

<!-- OPENCOLLECTIVE-INDIVIDUALS:START -->
No backers yet. Be the first!
<!-- OPENCOLLECTIVE-INDIVIDUALS:END -->

### Open Collective for Organizations

Become a sponsor and get your logo on our README on GitHub with a link to your site. \[[Become a sponsor][🖇osc-sponsors]\]

NOTE: [kettle-readme-backers][kettle-readme-backers] updates this list every day, automatically.

<!-- OPENCOLLECTIVE-ORGANIZATIONS:START -->
No sponsors yet. Be the first!
<!-- OPENCOLLECTIVE-ORGANIZATIONS:END -->

[kettle-readme-backers]: https://github.com/kettle-rb/ast-merge/blob/main/exe/kettle-readme-backers

### Another way to support open-source

I’m driven by a passion to foster a thriving open-source community – a space where people can tackle complex problems, no matter how small.  Revitalizing libraries that have fallen into disrepair, and building new libraries focused on solving real-world challenges, are my passions.  I was recently affected by layoffs, and the tech jobs market is unwelcoming. I’m reaching out here because your support would significantly aid my efforts to provide for my family, and my farm (11 🐔 chickens, 2 🐶 dogs, 3 🐰 rabbits, 8 🐈‍ cats).

If you work at a company that uses my work, please encourage them to support me as a corporate sponsor. My work on gems you use might show up in `bundle fund`.

I’m developing a new library, [floss\_funding][🖇floss-funding-gem], designed to empower open-source developers like myself to get paid for the work we do, in a sustainable way. Please give it a look.

**[Floss-Funding.dev][🖇floss-funding.dev]: 👉️ No network calls. 👉️ No tracking. 👉️ No oversight. 👉️ Minimal crypto hashing. 💡 Easily disabled nags**

[![OpenCollective Backers][🖇osc-backers-i]][🖇osc-backers] [![OpenCollective Sponsors][🖇osc-sponsors-i]][🖇osc-sponsors] [![Sponsor Me on Github][🖇sponsor-img]][🖇sponsor] [![Liberapay Goal Progress][⛳liberapay-img]][⛳liberapay] [![Donate on PayPal][🖇paypal-img]][🖇paypal] [![Buy me a coffee][🖇buyme-small-img]][🖇buyme] [![Donate on Polar][🖇polar-img]][🖇polar] [![Donate to my FLOSS efforts at ko-fi.com][🖇kofi-img]][🖇kofi] [![Donate to my FLOSS efforts using Patreon][🖇patreon-img]][🖇patreon]

## 🔐 Security

See [SECURITY.md][🔐security].

## 🤝 Contributing

If you need some ideas of where to help, you could work on adding more code coverage,
or if it is already 💯 (see [below](#code-coverage)) check [reek](REEK), [issues][🤝gh-issues], or [PRs][🤝gh-pulls],
or use the gem and think about how it could be better.

We [![Keep A Changelog][📗keep-changelog-img]][📗keep-changelog] so if you make changes, remember to update it.

See [CONTRIBUTING.md][🤝contributing] for more detailed instructions.

### 🚀 Release Instructions

See [CONTRIBUTING.md][🤝contributing].

### Code Coverage

[![Coverage Graph][🏀codecov-g]][🏀codecov]

[![Coveralls Test Coverage][🏀coveralls-img]][🏀coveralls]

[![QLTY Test Coverage][🏀qlty-covi]][🏀qlty-cov]

### 🪇 Code of Conduct

Everyone interacting with this project's codebases, issue trackers,
chat rooms and mailing lists agrees to follow the [![Contributor Covenant 2.1][🪇conduct-img]][🪇conduct].

## 🌈 Contributors

[![Contributors][🖐contributors-img]][🖐contributors]

Made with [contributors-img][🖐contrib-rocks].

Also see GitLab Contributors: <https://gitlab.com/kettle-rb/ast-merge/-/graphs/main>

<details>
    <summary>⭐️ Star History</summary>

<a href="https://star-history.com/#kettle-rb/ast-merge&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=kettle-rb/ast-merge&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=kettle-rb/ast-merge&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=kettle-rb/ast-merge&type=Date" />
 </picture>
</a>

</details>

## 📌 Versioning

This Library adheres to [![Semantic Versioning 2.0.0][📌semver-img]][📌semver].
Violations of this scheme should be reported as bugs.
Specifically, if a minor or patch version is released that breaks backward compatibility,
a new version should be immediately released that restores compatibility.
Breaking changes to the public API will only be introduced with new major versions.

> dropping support for a platform is both obviously and objectively a breaking change <br/>
> —Jordan Harband ([@ljharb](https://github.com/ljharb), maintainer of SemVer) [in SemVer issue 716][📌semver-breaking]

I understand that policy doesn't work universally ("exceptions to every rule\!"),
but it is the policy here.
As such, in many cases it is good to specify a dependency on this library using
the [Pessimistic Version Constraint][📌pvc] with two digits of precision.

For example:

```ruby
spec.add_dependency("ast-merge", "~> 4.0", ">= 4.0.0")                # ruby >= 3.2.0
```

<details markdown="1">
<summary>📌 Is "Platform Support" part of the public API? More details inside.</summary>

SemVer should, IMO, but doesn't explicitly, say that dropping support for specific Platforms
is a *breaking change* to an API, and for that reason the bike shedding is endless.

To get a better understanding of how SemVer is intended to work over a project's lifetime,
read this article from the creator of SemVer:

- ["Major Version Numbers are Not Sacred"][📌major-versions-not-sacred]

</details>

See [CHANGELOG.md][📌changelog] for a list of releases.

## 📄 License

The gem is available as open source under the terms of
the [MIT License][📄license] [![License: MIT][📄license-img]][📄license-ref].
See [LICENSE.txt][📄license] for the official [Copyright Notice][📄copyright-notice-explainer].

### © Copyright

<ul>
    <li>
        Copyright (c) 2025-2026 Peter H. Boling, of
        <a href="https://discord.gg/3qme4XHNKN">
            Galtzo.com
            <picture>
              <img src="https://logos.galtzo.com/assets/images/galtzo-floss/avatar-128px-blank.svg" alt="Galtzo.com Logo (Wordless) by Aboling0, CC BY-SA 4.0" width="24">
            </picture>
        </a>, and ast-merge contributors.
    </li>
</ul>

## 🤑 A request for help

Maintainers have teeth and need to pay their dentists.
After getting laid off in an RIF in March, and encountering difficulty finding a new one,
I began spending most of my time building open source tools.
I'm hoping to be able to pay for my kids' health insurance this month,
so if you value the work I am doing, I need your support.
Please consider sponsoring me or the project.

To join the community or get help 👇️ Join the Discord.

[![Live Chat on Discord][✉️discord-invite-img-ftb]][🖼️galtzo-discord]

To say "thanks\!" ☝️ Join the Discord or 👇️ send money.

[![Sponsor kettle-rb/ast-merge on Open Source Collective][🖇osc-all-bottom-img]][🖇osc] 💌 [![Sponsor me on GitHub Sponsors][🖇sponsor-bottom-img]][🖇sponsor] 💌 [![Sponsor me on Liberapay][⛳liberapay-bottom-img]][⛳liberapay] 💌 [![Donate on PayPal][🖇paypal-bottom-img]][🖇paypal]

### Please give the project a star ⭐ ♥.

Thanks for RTFM. ☺️

[⛳liberapay-img]: https://img.shields.io/liberapay/goal/pboling.svg?logo=liberapay&color=a51611&style=flat
[⛳liberapay-bottom-img]: https://img.shields.io/liberapay/goal/pboling.svg?style=for-the-badge&logo=liberapay&color=a51611
[⛳liberapay]: https://liberapay.com/pboling/donate
[🖇osc-all-img]: https://img.shields.io/opencollective/all/kettle-rb
[🖇osc-sponsors-img]: https://img.shields.io/opencollective/sponsors/kettle-rb
[🖇osc-backers-img]: https://img.shields.io/opencollective/backers/kettle-rb
[🖇osc-backers]: https://opencollective.com/kettle-rb#backer
[🖇osc-backers-i]: https://opencollective.com/kettle-rb/backers/badge.svg?style=flat
[🖇osc-sponsors]: https://opencollective.com/kettle-rb#sponsor
[🖇osc-sponsors-i]: https://opencollective.com/kettle-rb/sponsors/badge.svg?style=flat
[🖇osc-all-bottom-img]: https://img.shields.io/opencollective/all/kettle-rb?style=for-the-badge
[🖇osc-sponsors-bottom-img]: https://img.shields.io/opencollective/sponsors/kettle-rb?style=for-the-badge
[🖇osc-backers-bottom-img]: https://img.shields.io/opencollective/backers/kettle-rb?style=for-the-badge
[🖇osc]: https://opencollective.com/kettle-rb
[🖇sponsor-img]: https://img.shields.io/badge/Sponsor_Me!-pboling.svg?style=social&logo=github
[🖇sponsor-bottom-img]: https://img.shields.io/badge/Sponsor_Me!-pboling-blue?style=for-the-badge&logo=github
[🖇sponsor]: https://github.com/sponsors/pboling
[🖇polar-img]: https://img.shields.io/badge/polar-donate-a51611.svg?style=flat
[🖇polar]: https://polar.sh/pboling
[🖇kofi-img]: https://img.shields.io/badge/ko--fi-%E2%9C%93-a51611.svg?style=flat
[🖇kofi]: https://ko-fi.com/O5O86SNP4
[🖇patreon-img]: https://img.shields.io/badge/patreon-donate-a51611.svg?style=flat
[🖇patreon]: https://patreon.com/galtzo
[🖇buyme-small-img]: https://img.shields.io/badge/buy_me_a_coffee-%E2%9C%93-a51611.svg?style=flat
[🖇buyme-img]: https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20latte&emoji=&slug=pboling&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff
[🖇buyme]: https://www.buymeacoffee.com/pboling
[🖇paypal-img]: https://img.shields.io/badge/donate-paypal-a51611.svg?style=flat&logo=paypal
[🖇paypal-bottom-img]: https://img.shields.io/badge/donate-paypal-a51611.svg?style=for-the-badge&logo=paypal&color=0A0A0A
[🖇paypal]: https://www.paypal.com/paypalme/peterboling
[🖇floss-funding.dev]: https://floss-funding.dev
[🖇floss-funding-gem]: https://github.com/galtzo-floss/floss_funding
[✉️discord-invite]: https://discord.gg/3qme4XHNKN
[✉️discord-invite-img-ftb]: https://img.shields.io/discord/1373797679469170758?style=for-the-badge&logo=discord
[✉️ruby-friends-img]: https://img.shields.io/badge/daily.dev-%F0%9F%92%8E_Ruby_Friends-0A0A0A?style=for-the-badge&logo=dailydotdev&logoColor=white
[✉️ruby-friends]: https://app.daily.dev/squads/rubyfriends
[✇bundle-group-pattern]: https://gist.github.com/pboling/4564780
[⛳️gem-namespace]: https://github.com/kettle-rb/ast-merge
[⛳️namespace-img]: https://img.shields.io/badge/namespace-Ast::Merge-3C2D2D.svg?style=square&logo=ruby&logoColor=white
[⛳️gem-name]: https://bestgems.org/gems/ast-merge
[⛳️name-img]: https://img.shields.io/badge/name-ast--merge-3C2D2D.svg?style=square&logo=rubygems&logoColor=red
[⛳️tag-img]: https://img.shields.io/github/tag/kettle-rb/ast-merge.svg
[⛳️tag]: http://github.com/kettle-rb/ast-merge/releases
[🚂maint-blog]: http://www.railsbling.com/tags/ast-merge
[🚂maint-blog-img]: https://img.shields.io/badge/blog-railsbling-0093D0.svg?style=for-the-badge&logo=rubyonrails&logoColor=orange
[🚂maint-contact]: http://www.railsbling.com/contact
[🚂maint-contact-img]: https://img.shields.io/badge/Contact-Maintainer-0093D0.svg?style=flat&logo=rubyonrails&logoColor=red
[💖🖇linkedin]: http://www.linkedin.com/in/peterboling
[💖🖇linkedin-img]: https://img.shields.io/badge/PeterBoling-LinkedIn-0B66C2?style=flat&logo=newjapanprowrestling
[💖✌️wellfound]: https://wellfound.com/u/peter-boling
[💖✌️wellfound-img]: https://img.shields.io/badge/peter--boling-orange?style=flat&logo=wellfound
[💖💲crunchbase]: https://www.crunchbase.com/person/peter-boling
[💖💲crunchbase-img]: https://img.shields.io/badge/peter--boling-purple?style=flat&logo=crunchbase
[💖🐘ruby-mast]: https://ruby.social/@galtzo
[💖🐘ruby-mast-img]: https://img.shields.io/mastodon/follow/109447111526622197?domain=https://ruby.social&style=flat&logo=mastodon&label=Ruby%20@galtzo
[💖🦋bluesky]: https://bsky.app/profile/galtzo.com
[💖🦋bluesky-img]: https://img.shields.io/badge/@galtzo.com-0285FF?style=flat&logo=bluesky&logoColor=white
[💖🌳linktree]: https://linktr.ee/galtzo
[💖🌳linktree-img]: https://img.shields.io/badge/galtzo-purple?style=flat&logo=linktree
[💖💁🏼‍♂️devto]: https://dev.to/galtzo
[💖💁🏼‍♂️devto-img]: https://img.shields.io/badge/dev.to-0A0A0A?style=flat&logo=devdotto&logoColor=white
[💖💁🏼‍♂️aboutme]: https://about.me/peter.boling
[💖💁🏼‍♂️aboutme-img]: https://img.shields.io/badge/about.me-0A0A0A?style=flat&logo=aboutme&logoColor=white
[💖🧊berg]: https://codeberg.org/pboling
[💖🐙hub]: https://github.org/pboling
[💖🛖hut]: https://sr.ht/~galtzo/
[💖🧪lab]: https://gitlab.com/pboling
[👨🏼‍🏫expsup-upwork]: https://www.upwork.com/freelancers/~014942e9b056abdf86?mp_source=share
[👨🏼‍🏫expsup-upwork-img]: https://img.shields.io/badge/UpWork-13544E?style=for-the-badge&logo=Upwork&logoColor=white
[👨🏼‍🏫expsup-codementor]: https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github
[👨🏼‍🏫expsup-codementor-img]: https://img.shields.io/badge/CodeMentor-Get_Help-1abc9c?style=for-the-badge&logo=CodeMentor&logoColor=white
[🏙️entsup-tidelift]: https://tidelift.com/subscription/pkg/rubygems-ast-merge?utm_source=rubygems-ast-merge&utm_medium=referral&utm_campaign=readme
[🏙️entsup-tidelift-img]: https://img.shields.io/badge/Tidelift_and_Sonar-Enterprise_Support-FD3456?style=for-the-badge&logo=sonar&logoColor=white
[🏙️entsup-tidelift-sonar]: https://blog.tidelift.com/tidelift-joins-sonar
[💁🏼‍♂️peterboling]: http://www.peterboling.com
[🚂railsbling]: http://www.railsbling.com
[📜src-gl-img]: https://img.shields.io/badge/GitLab-FBA326?style=for-the-badge&logo=Gitlab&logoColor=orange
[📜src-gl]: https://gitlab.com/kettle-rb/ast-merge/
[📜src-cb-img]: https://img.shields.io/badge/CodeBerg-4893CC?style=for-the-badge&logo=CodeBerg&logoColor=blue
[📜src-cb]: https://codeberg.org/kettle-rb/ast-merge
[📜src-gh-img]: https://img.shields.io/badge/GitHub-238636?style=for-the-badge&logo=Github&logoColor=green
[📜src-gh]: https://github.com/kettle-rb/ast-merge
[📜docs-cr-rd-img]: https://img.shields.io/badge/RubyDoc-Current_Release-943CD2?style=for-the-badge&logo=readthedocs&logoColor=white
[📜docs-head-rd-img]: https://img.shields.io/badge/YARD_on_Galtzo.com-HEAD-943CD2?style=for-the-badge&logo=readthedocs&logoColor=white
[📜gl-wiki]: https://gitlab.com/kettle-rb/ast-merge/-/wikis/home
[📜gh-wiki]: https://github.com/kettle-rb/ast-merge/wiki
[📜gl-wiki-img]: https://img.shields.io/badge/wiki-examples-943CD2.svg?style=for-the-badge&logo=gitlab&logoColor=white
[📜gh-wiki-img]: https://img.shields.io/badge/wiki-examples-943CD2.svg?style=for-the-badge&logo=github&logoColor=white
[👽dl-rank]: https://bestgems.org/gems/ast-merge
[👽dl-ranki]: https://img.shields.io/gem/rd/ast-merge.svg
[👽oss-help]: https://www.codetriage.com/kettle-rb/ast-merge
[👽oss-helpi]: https://www.codetriage.com/kettle-rb/ast-merge/badges/users.svg
[👽version]: https://bestgems.org/gems/ast-merge
[👽versioni]: https://img.shields.io/gem/v/ast-merge.svg
[🏀qlty-mnt]: https://qlty.sh/gh/kettle-rb/projects/ast-merge
[🏀qlty-mnti]: https://qlty.sh/gh/kettle-rb/projects/ast-merge/maintainability.svg
[🏀qlty-cov]: https://qlty.sh/gh/kettle-rb/projects/ast-merge/metrics/code?sort=coverageRating
[🏀qlty-covi]: https://qlty.sh/gh/kettle-rb/projects/ast-merge/coverage.svg
[🏀codecov]: https://codecov.io/gh/kettle-rb/ast-merge
[🏀codecovi]: https://codecov.io/gh/kettle-rb/ast-merge/graph/badge.svg
[🏀coveralls]: https://coveralls.io/github/kettle-rb/ast-merge?branch=main
[🏀coveralls-img]: https://coveralls.io/repos/github/kettle-rb/ast-merge/badge.svg?branch=main
[🖐codeQL]: https://github.com/kettle-rb/ast-merge/security/code-scanning
[🖐codeQL-img]: https://github.com/kettle-rb/ast-merge/actions/workflows/codeql-analysis.yml/badge.svg
[🚎2-cov-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/coverage.yml
[🚎2-cov-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/coverage.yml/badge.svg
[🚎3-hd-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/heads.yml
[🚎3-hd-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/heads.yml/badge.svg
[🚎5-st-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/style.yml
[🚎5-st-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/style.yml/badge.svg
[🚎6-s-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/supported.yml
[🚎6-s-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/supported.yml/badge.svg
[🚎9-t-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/truffle.yml
[🚎9-t-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/truffle.yml/badge.svg
[🚎11-c-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml
[🚎11-c-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml/badge.svg
[🚎12-crh-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/dep-heads.yml
[🚎12-crh-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/dep-heads.yml/badge.svg
[🚎13-🔒️-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/locked_deps.yml
[🚎13-🔒️-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/locked_deps.yml/badge.svg
[🚎14-🔓️-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/unlocked_deps.yml
[🚎14-🔓️-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/unlocked_deps.yml/badge.svg
[🚎15-🪪-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/license-eye.yml
[🚎15-🪪-wfi]: https://github.com/kettle-rb/prism-merge/actions/workflows/license-eye.yml/badge.svg
[💎ruby-3.2i]: https://img.shields.io/badge/Ruby-3.2-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-3.3i]: https://img.shields.io/badge/Ruby-3.3-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[💎ruby-c-i]: https://img.shields.io/badge/Ruby-current-CC342D?style=for-the-badge&logo=ruby&logoColor=green
[💎ruby-headi]: https://img.shields.io/badge/Ruby-HEAD-CC342D?style=for-the-badge&logo=ruby&logoColor=blue
[💎truby-23.1i]: https://img.shields.io/badge/Truffle_Ruby-23.1-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink
[💎truby-c-i]: https://img.shields.io/badge/Truffle_Ruby-current-34BCB1?style=for-the-badge&logo=ruby&logoColor=green
[💎truby-headi]: https://img.shields.io/badge/Truffle_Ruby-HEAD-34BCB1?style=for-the-badge&logo=ruby&logoColor=blue
[💎jruby-c-i]: https://img.shields.io/badge/JRuby-current-FBE742?style=for-the-badge&logo=ruby&logoColor=green
[💎jruby-headi]: https://img.shields.io/badge/JRuby-HEAD-FBE742?style=for-the-badge&logo=ruby&logoColor=blue
[🤝gh-issues]: https://github.com/kettle-rb/ast-merge/issues
[🤝gh-pulls]: https://github.com/kettle-rb/ast-merge/pulls
[🤝gl-issues]: https://gitlab.com/kettle-rb/ast-merge/-/issues
[🤝gl-pulls]: https://gitlab.com/kettle-rb/ast-merge/-/merge_requests
[🤝cb-issues]: https://codeberg.org/kettle-rb/ast-merge/issues
[🤝cb-pulls]: https://codeberg.org/kettle-rb/ast-merge/pulls
[🤝cb-donate]: https://donate.codeberg.org/
[🤝contributing]: CONTRIBUTING.md
[🏀codecov-g]: https://codecov.io/gh/kettle-rb/ast-merge/graphs/tree.svg
[🖐contrib-rocks]: https://contrib.rocks
[🖐contributors]: https://github.com/kettle-rb/ast-merge/graphs/contributors
[🖐contributors-img]: https://contrib.rocks/image?repo=kettle-rb/ast-merge
[🚎contributors-gl]: https://gitlab.com/kettle-rb/ast-merge/-/graphs/main
[🪇conduct]: CODE_OF_CONDUCT.md
[🪇conduct-img]: https://img.shields.io/badge/Contributor_Covenant-2.1-259D6C.svg
[📌pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-259D6C.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📌changelog]: CHANGELOG.md
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-34495e.svg?style=flat
[📌gitmoji]: https://gitmoji.dev
[📌gitmoji-img]: https://img.shields.io/badge/gitmoji_commits-%20%F0%9F%98%9C%20%F0%9F%98%8D-34495e.svg?style=flat-square
[🧮kloc]: https://www.youtube.com/watch?v=dQw4w9WgXcQ
[🧮kloc-img]: https://img.shields.io/badge/KLOC-2.648-FFDD67.svg?style=for-the-badge&logo=YouTube&logoColor=blue
[🔐security]: SECURITY.md
[🔐security-img]: https://img.shields.io/badge/security-policy-259D6C.svg?style=flat
[📄copyright-notice-explainer]: https://opensource.stackexchange.com/questions/5778/why-do-licenses-such-as-the-mit-license-specify-a-single-year
[📄license]: LICENSE.txt
[📄license-ref]: https://opensource.org/licenses/MIT
[📄license-img]: https://img.shields.io/badge/License-MIT-259D6C.svg
[📄license-compat]: https://dev.to/galtzo/how-to-check-license-compatibility-41h0
[📄license-compat-img]: https://img.shields.io/badge/Apache_Compatible:_Category_A-%E2%9C%93-259D6C.svg?style=flat&logo=Apache
[📄ilo-declaration]: https://www.ilo.org/declaration/lang--en/index.htm
[📄ilo-declaration-img]: https://img.shields.io/badge/ILO_Fundamental_Principles-✓-259D6C.svg?style=flat
[🚎yard-current]: http://rubydoc.info/gems/ast-merge
[🚎yard-head]: https://ast-merge.galtzo.com
[💎stone_checksums]: https://github.com/galtzo-floss/stone_checksums
[💎SHA_checksums]: https://gitlab.com/kettle-rb/ast-merge/-/tree/main/checksums
[💎rlts]: https://github.com/rubocop-lts/rubocop-lts
[💎rlts-img]: https://img.shields.io/badge/code_style_&_linting-rubocop--lts-34495e.svg?plastic&logo=ruby&logoColor=white
[💎appraisal2]: https://github.com/appraisal-rb/appraisal2
[💎appraisal2-img]: https://img.shields.io/badge/appraised_by-appraisal2-34495e.svg?plastic&logo=ruby&logoColor=white
[💎d-in-dvcs]: https://railsbling.com/posts/dvcs/put_the_d_in_dvcs/
