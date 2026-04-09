#<--rubocop/md-->[![Galtzo FLOSS Logo by Aboling0, CC BY-SA 4.0][🖼️galtzo-i]][🖼️galtzo-discord] [![ruby-lang Logo, Yukihiro Matsumoto, Ruby Visual Identity Team, CC BY-SA 2.5][🖼️ruby-lang-i]][🖼️ruby-lang] [![kettle-rb Logo by Aboling0, CC BY-SA 4.0][🖼️kettle-rb-i]][🖼️kettle-rb]
#<--rubocop/md-->
#<--rubocop/md-->[🖼️galtzo-i]: https://logos.galtzo.com/assets/images/galtzo-floss/avatar-192px.svg
#<--rubocop/md-->[🖼️galtzo-discord]: https://discord.gg/3qme4XHNKN
#<--rubocop/md-->[🖼️ruby-lang-i]: https://logos.galtzo.com/assets/images/ruby-lang/avatar-192px.svg
#<--rubocop/md-->[🖼️ruby-lang]: https://www.ruby-lang.org/
#<--rubocop/md-->[🖼️kettle-rb-i]: https://logos.galtzo.com/assets/images/kettle-rb/avatar-192px.svg
#<--rubocop/md-->[🖼️kettle-rb]: https://github.com/kettle-rb
#<--rubocop/md-->
#<--rubocop/md--># ☯️ Ast::Merge
#<--rubocop/md-->
#<--rubocop/md-->[![Version][👽versioni]][👽version] [![GitHub tag (latest SemVer)][⛳️tag-img]][⛳️tag] [![License: MIT][📄license-img]][📄license-ref] [![Downloads Rank][👽dl-ranki]][👽dl-rank] [![Open Source Helpers][👽oss-helpi]][👽oss-help] [![CodeCov Test Coverage][🏀codecovi]][🏀codecov] [![Coveralls Test Coverage][🏀coveralls-img]][🏀coveralls] [![QLTY Test Coverage][🏀qlty-covi]][🏀qlty-cov] [![QLTY Maintainability][🏀qlty-mnti]][🏀qlty-mnt] [![CI Heads][🚎3-hd-wfi]][🚎3-hd-wf] [![CI Runtime Dependencies @ HEAD][🚎12-crh-wfi]][🚎12-crh-wf] [![CI Current][🚎11-c-wfi]][🚎11-c-wf] [![CI Truffle Ruby][🚎9-t-wfi]][🚎9-t-wf] [![CI JRuby][🚎10-j-wfi]][🚎10-j-wf] [![Deps Locked][🚎13-🔒️-wfi]][🚎13-🔒️-wf] [![Deps Unlocked][🚎14-🔓️-wfi]][🚎14-🔓️-wf] [![CI Test Coverage][🚎2-cov-wfi]][🚎2-cov-wf] [![CI Style][🚎5-st-wfi]][🚎5-st-wf] [![CodeQL][🖐codeQL-img]][🖐codeQL] [![Apache SkyWalking Eyes License Compatibility Check][🚎15-🪪-wfi]][🚎15-🪪-wf]
#<--rubocop/md-->
#<--rubocop/md-->`if ci_badges.map(&:color).detect { it != "green"}` ☝️ [let me know][🖼️galtzo-discord], as I may have missed the [discord notification][🖼️galtzo-discord].
#<--rubocop/md-->
#<--rubocop/md-->---
#<--rubocop/md-->
#<--rubocop/md-->`if ci_badges.map(&:color).all? { it == "green"}` 👇️ send money so I can do more of this. FLOSS maintenance is now my full-time job.
#<--rubocop/md-->
#<--rubocop/md-->[![OpenCollective Backers][🖇osc-backers-i]][🖇osc-backers] [![OpenCollective Sponsors][🖇osc-sponsors-i]][🖇osc-sponsors] [![Sponsor Me on Github][🖇sponsor-img]][🖇sponsor] [![Liberapay Goal Progress][⛳liberapay-img]][⛳liberapay] [![Donate on PayPal][🖇paypal-img]][🖇paypal] [![Buy me a coffee][🖇buyme-small-img]][🖇buyme] [![Donate on Polar][🖇polar-img]][🖇polar] [![Donate at ko-fi.com][🖇kofi-img]][🖇kofi]
#<--rubocop/md-->
#<--rubocop/md--><details>
#<--rubocop/md-->    <summary>👣 How will this project approach the September 2025 hostile takeover of RubyGems? 🚑️</summary>
#<--rubocop/md-->
#<--rubocop/md-->I've summarized my thoughts in [this blog post](https://dev.to/galtzo/hostile-takeover-of-rubygems-my-thoughts-5hlo).
#<--rubocop/md-->
#<--rubocop/md--></details>
#<--rubocop/md-->
#<--rubocop/md-->## 🌻 Synopsis
#<--rubocop/md-->
#<--rubocop/md-->Ast::Merge is **not typically used directly** - instead, use one of the format-specific gems built on top of it.
#<--rubocop/md-->
#<--rubocop/md-->### The `*-merge` Gem Family
#<--rubocop/md-->
#<--rubocop/md-->The `*-merge` gem family provides intelligent, AST-based merging for various file formats. At the foundation is [tree_haver][tree_haver], which provides a unified cross-Ruby parsing API that works seamlessly across MRI, JRuby, and TruffleRuby.
#<--rubocop/md-->
#<--rubocop/md-->| Gem                                      | Version                                                        | CI                                                           |          | Language<br>/ Format                                                                                  | Parser Backend(s)                                                                | Description |
#<--rubocop/md-->|------------------------------------------|----------------------------------------------------------------|--------------------------------------------------------------|----------|-------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|-------------|
#<--rubocop/md-->| [tree_haver][tree_haver]                 | [![Version][tree_haver-gem-i]][tree_haver-gem]                 | [![Version][tree_haver-ci-i]][tree_haver-ci]                 | Multi    | MRI C, Rust, FFI, Java, Prism, Psych, Commonmarker, Markly, Citrus, Parslet                           | **Foundation**: Cross-Ruby adapter for parsing libraries (like Faraday for HTTP) |
#<--rubocop/md-->| [ast-merge][ast-merge]                   | [![Version][ast-merge-gem-i]][ast-merge-gem]                   | [![Version][ast-merge-ci-i]][ast-merge-ci]                   | Text     | internal                                                                                              | **Infrastructure**: Shared base classes and merge logic for all `*-merge` gems   |
#<--rubocop/md-->| [bash-merge][bash-merge]                 | [![Version][bash-merge-gem-i]][bash-merge-gem]                 | [![Version][bash-merge-ci-i]][bash-merge-ci]                 | Bash     | [tree-sitter-bash][ts-bash] (via tree_haver)                                                          | Smart merge for Bash scripts                                                     |
#<--rubocop/md-->| [commonmarker-merge][commonmarker-merge] | [![Version][commonmarker-merge-gem-i]][commonmarker-merge-gem] | [![Version][commonmarker-merge-ci-i]][commonmarker-merge-ci] | Markdown | [Commonmarker][commonmarker] (via tree_haver)                                                         | Smart merge for Markdown (CommonMark via comrak Rust)                            |
#<--rubocop/md-->| [dotenv-merge][dotenv-merge]             | [![Version][dotenv-merge-gem-i]][dotenv-merge-gem]             | [![Version][dotenv-merge-ci-i]][dotenv-merge-ci]             | Dotenv   | internal                                                                                              | Smart merge for `.env` files                                                     |
#<--rubocop/md-->| [json-merge][json-merge]                 | [![Version][json-merge-gem-i]][json-merge-gem]                 | [![Version][json-merge-ci-i]][json-merge-ci]                 | JSON     | [tree-sitter-json][ts-json] (via tree_haver)                                                          | Smart merge for JSON files                                                       |
#<--rubocop/md-->| [jsonc-merge][jsonc-merge]               | [![Version][jsonc-merge-gem-i]][jsonc-merge-gem]               | [![Version][jsonc-merge-ci-i]][jsonc-merge-ci]               | JSONC    | [tree-sitter-jsonc][ts-jsonc] (via tree_haver)                                                        | ⚠️ Proof of concept; Smart merge for JSON with Comments                          |
#<--rubocop/md-->| [markdown-merge][markdown-merge]         | [![Version][markdown-merge-gem-i]][markdown-merge-gem]         | [![Version][markdown-merge-ci-i]][markdown-merge-ci]         | Markdown | [Commonmarker][commonmarker] / [Markly][markly] (via tree_haver)                                      | **Foundation**: Shared base for Markdown mergers with inner code block merging   |
#<--rubocop/md-->| [markly-merge][markly-merge]             | [![Version][markly-merge-gem-i]][markly-merge-gem]             | [![Version][markly-merge-ci-i]][markly-merge-ci]             | Markdown | [Markly][markly] (via tree_haver)                                                                     | Smart merge for Markdown (CommonMark via cmark-gfm C)                            |
#<--rubocop/md-->| [prism-merge][prism-merge]               | [![Version][prism-merge-gem-i]][prism-merge-gem]               | [![Version][prism-merge-ci-i]][prism-merge-ci]               | Ruby     | [Prism][prism] (`prism` std lib gem)                                                                  | Smart merge for Ruby source files                                                |
#<--rubocop/md-->| [psych-merge][psych-merge]               | [![Version][psych-merge-gem-i]][psych-merge-gem]               | [![Version][psych-merge-ci-i]][psych-merge-ci]               | YAML     | [Psych][psych] (`psych` std lib gem)                                                                  | Smart merge for YAML files                                                       |
#<--rubocop/md-->| [rbs-merge][rbs-merge]                   | [![Version][rbs-merge-gem-i]][rbs-merge-gem]                   | [![Version][rbs-merge-ci-i]][rbs-merge-ci]                   | RBS      | [tree-sitter-bash][ts-rbs] (via tree_haver), [RBS][rbs] (`rbs` std lib gem)                           | Smart merge for Ruby type signatures                                             |
#<--rubocop/md-->| [toml-merge][toml-merge]                 | [![Version][toml-merge-gem-i]][toml-merge-gem]                 | [![Version][toml-merge-ci-i]][toml-merge-ci]                 | TOML     | [Parslet + toml][toml], [Citrus + toml-rb][toml-rb], [tree-sitter-toml][ts-toml] (all via tree_haver) | Smart merge for TOML files                                                       |
#<--rubocop/md-->
#<--rubocop/md-->#### Backend Platform Compatibility
#<--rubocop/md-->
#<--rubocop/md-->tree_haver supports multiple parsing backends, but not all backends work on all Ruby platforms:
#<--rubocop/md-->
#<--rubocop/md-->| Platform 👉️<br> TreeHaver Backend 👇️         | MRI | JRuby | TruffleRuby | Notes                                               |
#<--rubocop/md-->|------------------------------------------------|:---:|:-----:|:-----------:|-----------------------------------------------------|
#<--rubocop/md-->| **MRI** ([ruby_tree_sitter][ruby_tree_sitter]) |  ✅  |   ❌   |      ❌      | C extension, MRI only                               |
#<--rubocop/md-->| **Rust** ([tree_stump][tree_stump])            |  ✅  |   ❌   |      ❌      | Rust extension via magnus/rb-sys, MRI only          |
#<--rubocop/md-->| **FFI**                                        |  ✅  |   ✅   |      ❌      | TruffleRuby's FFI doesn't support `STRUCT_BY_VALUE` |
#<--rubocop/md-->| **Java** ([jtreesitter][jtreesitter])          |  ❌  |   ✅   |      ❌      | JRuby only, requires grammar JARs                   |
#<--rubocop/md-->| **Prism**                                      |  ✅  |   ✅   |      ✅      | Ruby parsing, stdlib in Ruby 3.4+                   |
#<--rubocop/md-->| **Psych**                                      |  ✅  |   ✅   |      ✅      | YAML parsing, stdlib                                |
#<--rubocop/md-->| **Citrus**                                     |  ✅  |   ✅   |      ✅      | Pure Ruby PEG parser, no native dependencies        |
#<--rubocop/md-->| **Parslet**                                    |  ✅  |   ✅   |      ✅      | Pure Ruby PEG parser, no native dependencies        |
#<--rubocop/md-->| **Commonmarker**                               |  ✅  |   ❌   |      ❓      | Rust extension for Markdown                         |
#<--rubocop/md-->| **Markly**                                     |  ✅  |   ❌   |      ❓      | C extension for Markdown                            |
#<--rubocop/md-->
#<--rubocop/md-->**Legend**: ✅ = Works, ❌ = Does not work, ❓ = Untested
#<--rubocop/md-->
#<--rubocop/md-->**Why some backends don't work on certain platforms**:
#<--rubocop/md-->
#<--rubocop/md-->- **JRuby**: Runs on the JVM; cannot load native C/Rust extensions (`.so` files)
#<--rubocop/md-->- **TruffleRuby**: Has C API emulation via Sulong/LLVM, but it doesn't expose all MRI internals that native extensions require (e.g., `RBasic.flags`, `rb_gc_writebarrier`)
#<--rubocop/md-->- **FFI on TruffleRuby**: TruffleRuby's FFI implementation doesn't support returning structs by value, which tree-sitter's C API requires
#<--rubocop/md-->
#<--rubocop/md-->**Example implementations** for the gem templating use case:
#<--rubocop/md-->
#<--rubocop/md-->| Gem                      | Purpose         | Description                                   |
#<--rubocop/md-->|--------------------------|-----------------|-----------------------------------------------|
#<--rubocop/md-->| [kettle-dev][kettle-dev] | Gem Development | Gem templating tool using `*-merge` gems      |
#<--rubocop/md-->| [kettle-jem][kettle-jem] | Gem Templating  | Gem template library with smart merge support |
#<--rubocop/md-->
#<--rubocop/md-->[tree_haver]: https://github.com/kettle-rb/tree_haver
#<--rubocop/md-->[ast-merge]: https://github.com/kettle-rb/ast-merge
#<--rubocop/md-->[prism-merge]: https://github.com/kettle-rb/prism-merge
#<--rubocop/md-->[psych-merge]: https://github.com/kettle-rb/psych-merge
#<--rubocop/md-->[json-merge]: https://github.com/kettle-rb/json-merge
#<--rubocop/md-->[jsonc-merge]: https://github.com/kettle-rb/jsonc-merge
#<--rubocop/md-->[bash-merge]: https://github.com/kettle-rb/bash-merge
#<--rubocop/md-->[rbs-merge]: https://github.com/kettle-rb/rbs-merge
#<--rubocop/md-->[dotenv-merge]: https://github.com/kettle-rb/dotenv-merge
#<--rubocop/md-->[toml-merge]: https://github.com/kettle-rb/toml-merge
#<--rubocop/md-->[markdown-merge]: https://github.com/kettle-rb/markdown-merge
#<--rubocop/md-->[markly-merge]: https://github.com/kettle-rb/markly-merge
#<--rubocop/md-->[commonmarker-merge]: https://github.com/kettle-rb/commonmarker-merge
#<--rubocop/md-->[kettle-dev]: https://github.com/kettle-rb/kettle-dev
#<--rubocop/md-->[kettle-jem]: https://github.com/kettle-rb/kettle-jem
#<--rubocop/md-->[tree_haver-gem]: https://bestgems.org/gems/tree_haver
#<--rubocop/md-->[ast-merge-gem]: https://bestgems.org/gems/ast-merge
#<--rubocop/md-->[prism-merge-gem]: https://bestgems.org/gems/prism-merge
#<--rubocop/md-->[psych-merge-gem]: https://bestgems.org/gems/psych-merge
#<--rubocop/md-->[json-merge-gem]: https://bestgems.org/gems/json-merge
#<--rubocop/md-->[jsonc-merge-gem]: https://bestgems.org/gems/jsonc-merge
#<--rubocop/md-->[bash-merge-gem]: https://bestgems.org/gems/bash-merge
#<--rubocop/md-->[rbs-merge-gem]: https://bestgems.org/gems/rbs-merge
#<--rubocop/md-->[dotenv-merge-gem]: https://bestgems.org/gems/dotenv-merge
#<--rubocop/md-->[toml-merge-gem]: https://bestgems.org/gems/toml-merge
#<--rubocop/md-->[markdown-merge-gem]: https://bestgems.org/gems/markdown-merge
#<--rubocop/md-->[markly-merge-gem]: https://bestgems.org/gems/markly-merge
#<--rubocop/md-->[commonmarker-merge-gem]: https://bestgems.org/gems/commonmarker-merge
#<--rubocop/md-->[kettle-dev-gem]: https://bestgems.org/gems/kettle-dev
#<--rubocop/md-->[kettle-jem-gem]: https://bestgems.org/gems/kettle-jem
#<--rubocop/md-->[tree_haver-gem-i]: https://img.shields.io/gem/v/tree_haver.svg
#<--rubocop/md-->[ast-merge-gem-i]: https://img.shields.io/gem/v/ast-merge.svg
#<--rubocop/md-->[prism-merge-gem-i]: https://img.shields.io/gem/v/prism-merge.svg
#<--rubocop/md-->[psych-merge-gem-i]: https://img.shields.io/gem/v/psych-merge.svg
#<--rubocop/md-->[json-merge-gem-i]: https://img.shields.io/gem/v/json-merge.svg
#<--rubocop/md-->[jsonc-merge-gem-i]: https://img.shields.io/gem/v/jsonc-merge.svg
#<--rubocop/md-->[bash-merge-gem-i]: https://img.shields.io/gem/v/bash-merge.svg
#<--rubocop/md-->[rbs-merge-gem-i]: https://img.shields.io/gem/v/rbs-merge.svg
#<--rubocop/md-->[dotenv-merge-gem-i]: https://img.shields.io/gem/v/dotenv-merge.svg
#<--rubocop/md-->[toml-merge-gem-i]: https://img.shields.io/gem/v/toml-merge.svg
#<--rubocop/md-->[markdown-merge-gem-i]: https://img.shields.io/gem/v/markdown-merge.svg
#<--rubocop/md-->[markly-merge-gem-i]: https://img.shields.io/gem/v/markly-merge.svg
#<--rubocop/md-->[commonmarker-merge-gem-i]: https://img.shields.io/gem/v/commonmarker-merge.svg
#<--rubocop/md-->[kettle-dev-gem-i]: https://img.shields.io/gem/v/kettle-dev.svg
#<--rubocop/md-->[kettle-jem-gem-i]: https://img.shields.io/gem/v/kettle-jem.svg
#<--rubocop/md-->[tree_haver-ci-i]: https://github.com/kettle-rb/tree_haver/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[ast-merge-ci-i]: https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[prism-merge-ci-i]: https://github.com/kettle-rb/prism-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[psych-merge-ci-i]: https://github.com/kettle-rb/psych-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[json-merge-ci-i]: https://github.com/kettle-rb/json-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[jsonc-merge-ci-i]: https://github.com/kettle-rb/jsonc-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[bash-merge-ci-i]: https://github.com/kettle-rb/bash-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[rbs-merge-ci-i]: https://github.com/kettle-rb/rbs-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[dotenv-merge-ci-i]: https://github.com/kettle-rb/dotenv-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[toml-merge-ci-i]: https://github.com/kettle-rb/toml-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[markdown-merge-ci-i]: https://github.com/kettle-rb/markdown-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[markly-merge-ci-i]: https://github.com/kettle-rb/markly-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[commonmarker-merge-ci-i]: https://github.com/kettle-rb/commonmarker-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[kettle-dev-ci-i]: https://github.com/kettle-rb/kettle-dev/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[kettle-jem-ci-i]: https://github.com/kettle-rb/kettle-jem/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[tree_haver-ci]: https://github.com/kettle-rb/tree_haver/actions/workflows/current.yml
#<--rubocop/md-->[ast-merge-ci]: https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml
#<--rubocop/md-->[prism-merge-ci]: https://github.com/kettle-rb/prism-merge/actions/workflows/current.yml
#<--rubocop/md-->[psych-merge-ci]: https://github.com/kettle-rb/psych-merge/actions/workflows/current.yml
#<--rubocop/md-->[json-merge-ci]: https://github.com/kettle-rb/json-merge/actions/workflows/current.yml
#<--rubocop/md-->[jsonc-merge-ci]: https://github.com/kettle-rb/jsonc-merge/actions/workflows/current.yml
#<--rubocop/md-->[bash-merge-ci]: https://github.com/kettle-rb/bash-merge/actions/workflows/current.yml
#<--rubocop/md-->[rbs-merge-ci]: https://github.com/kettle-rb/rbs-merge/actions/workflows/current.yml
#<--rubocop/md-->[dotenv-merge-ci]: https://github.com/kettle-rb/dotenv-merge/actions/workflows/current.yml
#<--rubocop/md-->[toml-merge-ci]: https://github.com/kettle-rb/toml-merge/actions/workflows/current.yml
#<--rubocop/md-->[markdown-merge-ci]: https://github.com/kettle-rb/markdown-merge/actions/workflows/current.yml
#<--rubocop/md-->[markly-merge-ci]: https://github.com/kettle-rb/markly-merge/actions/workflows/current.yml
#<--rubocop/md-->[commonmarker-merge-ci]: https://github.com/kettle-rb/commonmarker-merge/actions/workflows/current.yml
#<--rubocop/md-->[kettle-dev-ci]: https://github.com/kettle-rb/kettle-dev/actions/workflows/current.yml
#<--rubocop/md-->[kettle-jem-ci]: https://github.com/kettle-rb/kettle-jem/actions/workflows/current.yml
#<--rubocop/md-->[prism]: https://github.com/ruby/prism
#<--rubocop/md-->[psych]: https://github.com/ruby/psych
#<--rubocop/md-->[ts-json]: https://github.com/tree-sitter/tree-sitter-json
#<--rubocop/md-->[ts-jsonc]: https://gitlab.com/WhyNotHugo/tree-sitter-jsonc
#<--rubocop/md-->[ts-bash]: https://github.com/tree-sitter/tree-sitter-bash
#<--rubocop/md-->[ts-rbs]: https://github.com/joker1007/tree-sitter-rbs
#<--rubocop/md-->[ts-toml]: https://github.com/tree-sitter-grammars/tree-sitter-toml
#<--rubocop/md-->[dotenv]: https://github.com/bkeepers/dotenv
#<--rubocop/md-->[rbs]: https://github.com/ruby/rbs
#<--rubocop/md-->[toml-rb]: https://github.com/emancu/toml-rb
#<--rubocop/md-->[toml]: https://github.com/jm/toml
#<--rubocop/md-->[markly]: https://github.com/ioquatix/markly
#<--rubocop/md-->[commonmarker]: https://github.com/gjtorikian/commonmarker
#<--rubocop/md-->[ruby_tree_sitter]: https://github.com/Faveod/ruby-tree-sitter
#<--rubocop/md-->[tree_stump]: https://github.com/joker1007/tree_stump
#<--rubocop/md-->[jtreesitter]: https://central.sonatype.com/artifact/io.github.tree-sitter/jtreesitter
#<--rubocop/md-->
#<--rubocop/md-->### Architecture: tree\_haver + ast-merge
#<--rubocop/md-->
#<--rubocop/md-->The `*-merge` gem family is built on a two-layer architecture:
#<--rubocop/md-->
#<--rubocop/md-->#### Layer 1: tree\_haver (Parsing Foundation)
#<--rubocop/md-->
#<--rubocop/md-->[tree\_haver][tree_haver] provides cross-Ruby parsing capabilities:
#<--rubocop/md-->
#<--rubocop/md-->- **Universal Backend Support**: Automatically selects the best parsing backend for your Ruby implementation (MRI, JRuby, TruffleRuby)
#<--rubocop/md-->- **10 Backend Options**: MRI C extensions, Rust bindings, FFI, Java (JRuby), language-specific parsers (Prism, Psych, Commonmarker, Markly), and pure Ruby fallback (Citrus)
#<--rubocop/md-->- **Unified API**: Write parsing code once, run on any Ruby implementation
#<--rubocop/md-->- **Grammar Discovery**: Built-in `GrammarFinder` for platform-aware grammar library discovery
#<--rubocop/md-->- **Thread-Safe**: Language registry with thread-safe caching
#<--rubocop/md-->
#<--rubocop/md-->#### Layer 2: ast-merge (Merge Infrastructure)
#<--rubocop/md-->
#<--rubocop/md-->Ast::Merge builds on tree\_haver to provide:
#<--rubocop/md-->
#<--rubocop/md-->- **Base Classes**: `FreezeNode`, `MergeResult` base classes with unified constructors
#<--rubocop/md-->- **Shared Modules**: `FileAnalysisBase`, `FileAnalyzable`, `MergerConfig`, `DebugLogger`
#<--rubocop/md-->- **Freeze Block Support**: Configurable marker patterns for multiple comment syntaxes (preserve sections during merge)
#<--rubocop/md-->- **Node Typing System**: `NodeTyping` for canonical node type identification across different parsers
#<--rubocop/md-->- **Conflict Resolution**: `ConflictResolverBase` with pluggable strategies
#<--rubocop/md-->- **Error Classes**: `ParseError`, `TemplateParseError`, `DestinationParseError`
#<--rubocop/md-->- **Region Detection**: `RegionDetectorBase`, `FencedCodeBlockDetector` for text-based analysis
#<--rubocop/md-->- **RSpec Shared Examples**: Test helpers for implementing new merge gems
#<--rubocop/md-->
#<--rubocop/md-->### Creating a New Merge Gem
#<--rubocop/md-->
#<--rubocop/md-->```ruby
require "ast/merge"

module MyFormat
  module Merge
    # Inherit from base classes and pass **options for forward compatibility

    class SmartMerger < Ast::Merge::SmartMergerBase
      DEFAULT_FREEZE_TOKEN = "myformat-merge"

      def initialize(template, dest, my_custom_option: nil, **options)
        @my_custom_option = my_custom_option
        super(template, dest, **options)
      end

      protected

      def analysis_class
        FileAnalysis
      end

      def default_freeze_token
        DEFAULT_FREEZE_TOKEN
      end

      def perform_merge
        # Implement format-specific merge logic
        # Returns a MergeResult
      end
    end

    class FileAnalysis
      include Ast::Merge::FileAnalyzable

      def initialize(source, freeze_token: nil, signature_generator: nil, **options)
        @source = source
        @freeze_token = freeze_token
        @signature_generator = signature_generator
        # Process source...
      end

      def compute_node_signature(node)
        # Return signature array for node matching
      end
    end

    class ConflictResolver < Ast::Merge::ConflictResolverBase
      def initialize(template_analysis, dest_analysis, preference: :destination,
        add_template_only_nodes: false, match_refiner: nil, **options)
        super(
          strategy: :batch,  # or :node, :boundary
          preference: preference,
          template_analysis: template_analysis,
          dest_analysis: dest_analysis,
          add_template_only_nodes: add_template_only_nodes,
          match_refiner: match_refiner,
          **options
        )
      end

      protected

      def resolve_batch(result)
        # Implement batch resolution logic
      end
    end

    class MergeResult < Ast::Merge::MergeResultBase
      def initialize(**options)
        super(**options)
        @statistics = {merged_count: 0}
      end

      def to_my_format
        to_s
      end
    end

    class MatchRefiner < Ast::Merge::MatchRefinerBase
      def initialize(threshold: 0.7, node_types: nil, **options)
        super(threshold: threshold, node_types: node_types, **options)
      end

      def similarity(template_node, dest_node)
        # Return similarity score between 0.0 and 1.0
      end
    end
  end
end
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->### Base Classes Reference
#<--rubocop/md-->
#<--rubocop/md-->| Base Class             | Purpose                     | Key Methods to Implement               |
#<--rubocop/md-->|------------------------|-----------------------------|----------------------------------------|
#<--rubocop/md-->| `SmartMergerBase`      | Main merge orchestration    | `analysis_class`, `perform_merge`      |
#<--rubocop/md-->| `ConflictResolverBase` | Resolve node conflicts      | `resolve_batch` or `resolve_node_pair` |
#<--rubocop/md-->| `MergeResultBase`      | Track merge results         | `to_s`, format-specific output         |
#<--rubocop/md-->| `MatchRefinerBase`     | Fuzzy node matching         | `similarity`                           |
#<--rubocop/md-->| `ContentMatchRefiner`  | Text content fuzzy matching | Ready to use                           |
#<--rubocop/md-->| `FileAnalyzable`       | File parsing/analysis       | `compute_node_signature`               |
#<--rubocop/md-->
#<--rubocop/md-->### ContentMatchRefiner
#<--rubocop/md-->
#<--rubocop/md-->`Ast::Merge::ContentMatchRefiner` is a built-in match refiner for fuzzy text content matching using Levenshtein distance. Unlike signature-based matching which requires exact content hashes, this refiner allows matching nodes with similar (but not identical) content.
#<--rubocop/md-->
#<--rubocop/md-->```ruby
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
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->This is particularly useful for:
#<--rubocop/md-->
#<--rubocop/md-->- Paragraphs with minor edits (typos, rewording)
#<--rubocop/md-->- Headings with slight changes
#<--rubocop/md-->- Comments with updated text
#<--rubocop/md-->- Any text-based node that may have been slightly modified
#<--rubocop/md-->
#<--rubocop/md-->### JaccardSimilarity
#<--rubocop/md-->
#<--rubocop/md-->`Ast::Merge::JaccardSimilarity` provides set-based fuzzy matching of text blocks using Jaccard index with bigram and token overlap metrics. This is the foundation for detecting renamed or refactored nodes that share similar content.
#<--rubocop/md-->
#<--rubocop/md-->```ruby
# Calculate similarity between two text strings
Ast::Merge::JaccardSimilarity.jaccard("def process_users(data)", "def handle_users(data)")
# => 0.75 (high overlap due to shared tokens)

# Extract tokens from text for comparison
tokens = Ast::Merge::JaccardSimilarity.extract_tokens("data.each { |u| validate(u) }")
# => ["data", "each", "validate"]
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->### TokenMatchRefiner
#<--rubocop/md-->
#<--rubocop/md-->`Ast::Merge::TokenMatchRefiner` extends `MatchRefinerBase` for Jaccard-based fuzzy refinement of unmatched node pairs during alignment. It uses greedy best-first matching to pair orphan nodes that have similar body text.
#<--rubocop/md-->
#<--rubocop/md-->```ruby
refiner = Ast::Merge::TokenMatchRefiner.new(
  threshold: 0.6,                  # Minimum Jaccard similarity (default: 0.6)
  node_types: [:def, :class],       # Only match these node types
)

merger = MyFormat::SmartMerger.new(
  template,
destination,
  match_refiner: refiner
)
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->### CompositeMatchRefiner
#<--rubocop/md-->
#<--rubocop/md-->`Ast::Merge::CompositeMatchRefiner` chains multiple refiners sequentially, enabling multi-strategy matching in a single alignment pass. Each refiner operates on the residual unmatched nodes from the previous refiner.
#<--rubocop/md-->
#<--rubocop/md-->```ruby
composite = Ast::Merge::CompositeMatchRefiner.new(refiners: [
  Ast::Merge::ContentMatchRefiner.new(threshold: 0.8),  # strict text match first
  Ast::Merge::TokenMatchRefiner.new(threshold: 0.5),    # then looser token match
])

merger = MyFormat::SmartMerger.new(
  template,
destination,
  match_refiner: composite
)
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->### Namespace Reference
#<--rubocop/md-->
#<--rubocop/md-->The `Ast::Merge` module is organized into several namespaces, each with detailed documentation:
#<--rubocop/md-->
#<--rubocop/md-->| Namespace              | Purpose                            | Documentation                                                        |
#<--rubocop/md-->|------------------------|------------------------------------|----------------------------------------------------------------------|
#<--rubocop/md-->| `Ast::Merge::Detector` | Region detection and merging       | [lib/ast/merge/detector/README.md](lib/ast/merge/detector/README.md) |
#<--rubocop/md-->| `Ast::Merge::Recipe`   | YAML-based merge recipes           | [lib/ast/merge/recipe/README.md](lib/ast/merge/recipe/README.md)     |
#<--rubocop/md-->| `Ast::Merge::Comment`  | Comment parsing and representation | [lib/ast/merge/comment/README.md](lib/ast/merge/comment/README.md)   |
#<--rubocop/md-->| `Ast::Merge::Text`     | Plain text AST parsing             | [lib/ast/merge/text/README.md](lib/ast/merge/text/README.md)         |
#<--rubocop/md-->| `Ast::Merge::RSpec`    | Shared RSpec examples              | [lib/ast/merge/rspec/README.md](lib/ast/merge/rspec/README.md)       |
#<--rubocop/md-->
#<--rubocop/md-->**Key Classes by Namespace:**
#<--rubocop/md-->
#<--rubocop/md-->- **Detector**: `Region`, `Base`, `Mergeable`, `FencedCodeBlock`, `YamlFrontmatter`, `TomlFrontmatter`
#<--rubocop/md-->- **Recipe**: `Config`, `Runner`, `ScriptLoader`
#<--rubocop/md-->- **Comment**: `Line`, `Block`, `Empty`, `Parser`, `Style`
#<--rubocop/md-->- **Text**: `SmartMerger`, `FileAnalysis`, `LineNode`, `WordNode`, `Section`
#<--rubocop/md-->- **RSpec**: Shared examples and dependency tags for testing `*-merge` implementations
#<--rubocop/md-->
#<--rubocop/md-->## 💡 Info you can shake a stick at
#<--rubocop/md-->
#<--rubocop/md-->| Tokens to Remember      | [![Gem name][⛳️name-img]][⛳️gem-name] [![Gem namespace][⛳️namespace-img]][⛳️gem-namespace]                                                                                                                                                                                                                                                                          |
#<--rubocop/md-->|-------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
#<--rubocop/md-->| Works with JRuby        | [![JRuby current Compat][💎jruby-c-i]][🚎10-j-wf] [![JRuby HEAD Compat][💎jruby-headi]][🚎3-hd-wf]|
#<--rubocop/md-->| Works with Truffle Ruby | [![Truffle Ruby 24.2 Compat][💎truby-24.2i]][🚎truby-24.2-wf] [![Truffle Ruby 25.0 Compat][💎truby-25.0i]][🚎truby-25.0-wf] [![Truffle Ruby current Compat][💎truby-c-i]][🚎9-t-wf]|
#<--rubocop/md-->| Works with MRI Ruby 4   | [![Ruby 4.0 Compat][💎ruby-4.0i]][🚎11-c-wf] [![Ruby current Compat][💎ruby-c-i]][🚎11-c-wf] [![Ruby HEAD Compat][💎ruby-headi]][🚎3-hd-wf]|
#<--rubocop/md-->| Works with MRI Ruby 3   | [![Ruby 3.2 Compat][💎ruby-3.2i]][🚎ruby-3.2-wf] [![Ruby 3.3 Compat][💎ruby-3.3i]][🚎ruby-3.3-wf] [![Ruby 3.4 Compat][💎ruby-3.4i]][🚎ruby-3.4-wf]|
#<--rubocop/md-->| Support & Community     | [![Join Me on Daily.dev's RubyFriends][✉️ruby-friends-img]][✉️ruby-friends] [![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite] [![Get help from me on Upwork][👨🏼‍🏫expsup-upwork-img]][👨🏼‍🏫expsup-upwork] [![Get help from me on Codementor][👨🏼‍🏫expsup-codementor-img]][👨🏼‍🏫expsup-codementor]                                       |
#<--rubocop/md-->| Source                  | [![Source on GitLab.com][📜src-gl-img]][📜src-gl] [![Source on CodeBerg.org][📜src-cb-img]][📜src-cb] [![Source on Github.com][📜src-gh-img]][📜src-gh] [![The best SHA: dQw4w9WgXcQ!][🧮kloc-img]][🧮kloc]                                                                                                                                                         |
#<--rubocop/md-->| Documentation           | [![Current release on RubyDoc.info][📜docs-cr-rd-img]][🚎yard-current] [![YARD on Galtzo.com][📜docs-head-rd-img]][🚎yard-head] [![Maintainer Blog][🚂maint-blog-img]][🚂maint-blog] [![GitLab Wiki][📜gl-wiki-img]][📜gl-wiki] [![GitHub Wiki][📜gh-wiki-img]][📜gh-wiki]                                                                                          |
#<--rubocop/md-->| Compliance              | [![License: MIT][📄license-img]][📄license-ref] [![Compatible with Apache Software Projects: Verified by SkyWalking Eyes][📄license-compat-img]][📄license-compat] [![📄ilo-declaration-img]][📄ilo-declaration] [![Security Policy][🔐security-img]][🔐security] [![Contributor Covenant 2.1][🪇conduct-img]][🪇conduct] [![SemVer 2.0.0][📌semver-img]][📌semver] |
#<--rubocop/md-->| Style                   | [![Enforced Code Style Linter][💎rlts-img]][💎rlts] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog] [![Gitmoji Commits][📌gitmoji-img]][📌gitmoji] [![Compatibility appraised by: appraisal2][💎appraisal2-img]][💎appraisal2]                                                                                                                  |
#<--rubocop/md-->| Maintainer 🎖️          | [![Follow Me on LinkedIn][💖🖇linkedin-img]][💖🖇linkedin] [![Follow Me on Ruby.Social][💖🐘ruby-mast-img]][💖🐘ruby-mast] [![Follow Me on Bluesky][💖🦋bluesky-img]][💖🦋bluesky] [![Contact Maintainer][🚂maint-contact-img]][🚂maint-contact] [![My technical writing][💖💁🏼‍♂️devto-img]][💖💁🏼‍♂️devto]                                                      |
#<--rubocop/md-->| `...` 💖                | [![Find Me on WellFound:][💖✌️wellfound-img]][💖✌️wellfound] [![Find Me on CrunchBase][💖💲crunchbase-img]][💖💲crunchbase] [![My LinkTree][💖🌳linktree-img]][💖🌳linktree] [![More About Me][💖💁🏼‍♂️aboutme-img]][💖💁🏼‍♂️aboutme] [🧊][💖🧊berg] [🐙][💖🐙hub]  [🛖][💖🛖hut] [🧪][💖🧪lab]                                                                   |
#<--rubocop/md-->
#<--rubocop/md-->### Compatibility
#<--rubocop/md-->
#<--rubocop/md-->Compatible with MRI Ruby 3.2.0+, and concordant releases of JRuby, and TruffleRuby.
#<--rubocop/md-->
#<--rubocop/md-->| 🚚 _Amazing_ test matrix was brought to you by | 🔎 appraisal2 🔎 and the color 💚 green 💚             |
#<--rubocop/md-->|------------------------------------------------|--------------------------------------------------------|
#<--rubocop/md-->| 👟 Check it out!                               | ✨ [github.com/appraisal-rb/appraisal2][💎appraisal2] ✨ |
#<--rubocop/md-->
#<--rubocop/md-->### Federated DVCS
#<--rubocop/md-->
#<--rubocop/md--><details markdown="1">
#<--rubocop/md-->  <summary>Find this repo on federated forges (Coming soon!)</summary>
#<--rubocop/md-->
#<--rubocop/md-->| Federated [DVCS][💎d-in-dvcs] Repository        | Status                                                                | Issues                    | PRs                      | Wiki                      | CI                       | Discussions                  |
#<--rubocop/md-->|-------------------------------------------------|-----------------------------------------------------------------------|---------------------------|--------------------------|---------------------------|--------------------------|------------------------------|
#<--rubocop/md-->| 🧪 [kettle-rb/ast-merge on GitLab][📜src-gl]   | The Truth                                                             | [💚][🤝gl-issues]         | [💚][🤝gl-pulls]         | [💚][📜gl-wiki]           | 🐭 Tiny Matrix           | ➖                            |
#<--rubocop/md-->| 🧊 [kettle-rb/ast-merge on CodeBerg][📜src-cb] | An Ethical Mirror ([Donate][🤝cb-donate])                             | [💚][🤝cb-issues]         | [💚][🤝cb-pulls]         | ➖                         | ⭕️ No Matrix             | ➖                            |
#<--rubocop/md-->| 🐙 [kettle-rb/ast-merge on GitHub][📜src-gh]   | Another Mirror                                                        | [💚][🤝gh-issues]         | [💚][🤝gh-pulls]         | [💚][📜gh-wiki]           | 💯 Full Matrix           | [💚][gh-discussions]         |
#<--rubocop/md-->| 🎮️ [Discord Server][✉️discord-invite]          | [![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite] | [Let's][✉️discord-invite] | [talk][✉️discord-invite] | [about][✉️discord-invite] | [this][✉️discord-invite] | [library!][✉️discord-invite] |
#<--rubocop/md-->
#<--rubocop/md--></details>
#<--rubocop/md-->
#<--rubocop/md-->[gh-discussions]: https://github.com/kettle-rb/ast-merge/discussions
#<--rubocop/md-->
#<--rubocop/md-->### Enterprise Support [![Tidelift](https://tidelift.com/badges/package/rubygems/ast-merge)](https://tidelift.com/subscription/pkg/rubygems-ast-merge?utm_source=rubygems-ast-merge&utm_medium=referral&utm_campaign=readme)
#<--rubocop/md-->
#<--rubocop/md-->Available as part of the Tidelift Subscription.
#<--rubocop/md-->
#<--rubocop/md--><details markdown="1">
#<--rubocop/md-->  <summary>Need enterprise-level guarantees?</summary>
#<--rubocop/md-->
#<--rubocop/md-->The maintainers of this and thousands of other packages are working with Tidelift to deliver commercial support and maintenance for the open source packages you use to build your applications. Save time, reduce risk, and improve code health, while paying the maintainers of the exact packages you use.
#<--rubocop/md-->
#<--rubocop/md-->[![Get help from me on Tidelift][🏙️entsup-tidelift-img]][🏙️entsup-tidelift]
#<--rubocop/md-->
#<--rubocop/md-->- 💡Subscribe for support guarantees covering _all_ your FLOSS dependencies
#<--rubocop/md-->- 💡Tidelift is part of [Sonar][🏙️entsup-tidelift-sonar]
#<--rubocop/md-->- 💡Tidelift pays maintainers to maintain the software you depend on!<br/>📊`@`Pointy Haired Boss: An [enterprise support][🏙️entsup-tidelift] subscription is "[never gonna let you down][🧮kloc]", and *supports* open source maintainers
#<--rubocop/md-->
#<--rubocop/md-->Alternatively:
#<--rubocop/md-->
#<--rubocop/md-->- [![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite]
#<--rubocop/md-->- [![Get help from me on Upwork][👨🏼‍🏫expsup-upwork-img]][👨🏼‍🏫expsup-upwork]
#<--rubocop/md-->- [![Get help from me on Codementor][👨🏼‍🏫expsup-codementor-img]][👨🏼‍🏫expsup-codementor]
#<--rubocop/md-->
#<--rubocop/md--></details>
#<--rubocop/md-->
#<--rubocop/md-->## ✨ Installation
#<--rubocop/md-->
#<--rubocop/md-->Install the gem and add to the application's Gemfile by executing:
#<--rubocop/md-->
#<--rubocop/md-->```console
#<--rubocop/md-->bundle add ast-merge
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->If bundler is not being used to manage dependencies, install the gem by executing:
#<--rubocop/md-->
#<--rubocop/md-->```console
#<--rubocop/md-->gem install ast-merge
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->### 🔒 Secure Installation
#<--rubocop/md-->
#<--rubocop/md--><details markdown="1">
#<--rubocop/md-->  <summary>For Medium or High Security Installations</summary>
#<--rubocop/md-->
#<--rubocop/md-->This gem is cryptographically signed and has verifiable [SHA-256 and SHA-512][💎SHA_checksums] checksums by
#<--rubocop/md-->[stone_checksums][💎stone_checksums]. Be sure the gem you install hasn’t been tampered with
#<--rubocop/md-->by following the instructions below.
#<--rubocop/md-->
#<--rubocop/md-->Add my public key (if you haven’t already; key expires 2045-04-29) as a trusted certificate:
#<--rubocop/md-->
#<--rubocop/md-->```console
#<--rubocop/md-->gem cert --add <(curl -Ls https://raw.github.com/galtzo-floss/certs/main/pboling.pem)
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->You only need to do that once.  Then proceed to install with:
#<--rubocop/md-->
#<--rubocop/md-->```console
#<--rubocop/md-->gem install ast-merge -P HighSecurity
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->The `HighSecurity` trust profile will verify signed gems, and not allow the installation of unsigned dependencies.
#<--rubocop/md-->
#<--rubocop/md-->If you want to up your security game full-time:
#<--rubocop/md-->
#<--rubocop/md-->```console
#<--rubocop/md-->bundle config set --global trust-policy MediumSecurity
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->`MediumSecurity` instead of `HighSecurity` is necessary if not all the gems you use are signed.
#<--rubocop/md-->
#<--rubocop/md-->NOTE: Be prepared to track down certs for signed gems and add them the same way you added mine.
#<--rubocop/md-->
#<--rubocop/md--></details>
#<--rubocop/md-->
#<--rubocop/md-->## ⚙️ Configuration
#<--rubocop/md-->
#<--rubocop/md-->`ast-merge` provides base classes and shared interfaces for building format-specific merge tools.
#<--rubocop/md-->Each implementation (like `prism-merge`, `psych-merge`, etc.) has its own SmartMerger with format-specific configuration.
#<--rubocop/md-->
#<--rubocop/md-->### Common Configuration Options
#<--rubocop/md-->
#<--rubocop/md-->All SmartMerger implementations share these configuration options:
#<--rubocop/md-->
#<--rubocop/md-->```ruby
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
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->### Signature Match Preference
#<--rubocop/md-->
#<--rubocop/md-->Control which source wins when both files have the same structural element:
#<--rubocop/md-->
#<--rubocop/md-->- **`:template`** - Template values replace destination values
#<--rubocop/md-->- **`:destination`** (default) - Destination values are preserved
#<--rubocop/md-->- **Hash** - Per-node-type preference (see Advanced Configuration)
#<--rubocop/md-->
#<--rubocop/md-->### Template-Only Nodes
#<--rubocop/md-->
#<--rubocop/md-->Control whether to add nodes that only exist in the template:
#<--rubocop/md-->
#<--rubocop/md-->- **`true`** - Add all template-only nodes
#<--rubocop/md-->- **`false`** (default) - Skip template-only nodes
#<--rubocop/md-->- **Callable** - Filter which template-only nodes to add
#<--rubocop/md-->
#<--rubocop/md-->#### Callable Filter
#<--rubocop/md-->
#<--rubocop/md-->When you need fine-grained control over which template-only nodes are added, pass a callable (Proc/Lambda) that receives `(node, entry)` and returns truthy to add or falsey to skip:
#<--rubocop/md-->
#<--rubocop/md-->```ruby
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
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->The `entry` hash contains:
#<--rubocop/md-->
#<--rubocop/md-->- `:template_node` - The node being considered for addition
#<--rubocop/md-->- `:signature` - The node's signature (Array or other value)
#<--rubocop/md-->- `:template_index` - Index in the template statements
#<--rubocop/md-->- `:dest_index` - Always `nil` for template-only nodes
#<--rubocop/md-->
#<--rubocop/md-->## 🔧 Basic Usage
#<--rubocop/md-->
#<--rubocop/md-->### Using Shared Examples in Tests
#<--rubocop/md-->
#<--rubocop/md-->```ruby
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
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md-->### Available Shared Examples
#<--rubocop/md-->
#<--rubocop/md-->- `"Ast::Merge::FreezeNode"` - Tests for FreezeNode implementations
#<--rubocop/md-->- `"Ast::Merge::MergeResult"` - Tests for MergeResult implementations
#<--rubocop/md-->- `"Ast::Merge::DebugLogger"` - Tests for DebugLogger implementations
#<--rubocop/md-->- `"Ast::Merge::FileAnalysisBase"` - Tests for FileAnalysis implementations
#<--rubocop/md-->- `"Ast::Merge::MergerConfig"` - Tests for SmartMerger implementations
#<--rubocop/md-->
#<--rubocop/md-->## 🦷 FLOSS Funding
#<--rubocop/md-->
#<--rubocop/md-->While kettle-rb tools are free software and will always be, the project would benefit immensely from some funding.
#<--rubocop/md-->Raising a monthly budget of... "dollars" would make the project more sustainable.
#<--rubocop/md-->
#<--rubocop/md-->We welcome both individual and corporate sponsors! We also offer a
#<--rubocop/md-->wide array of funding channels to account for your preferences
#<--rubocop/md-->(although currently [Open Collective][🖇osc] is our preferred funding platform).
#<--rubocop/md-->
#<--rubocop/md-->**If you're working in a company that's making significant use of kettle-rb tools we'd
#<--rubocop/md-->appreciate it if you suggest to your company to become a kettle-rb sponsor.**
#<--rubocop/md-->
#<--rubocop/md-->You can support the development of kettle-rb tools via
#<--rubocop/md-->[GitHub Sponsors][🖇sponsor],
#<--rubocop/md-->[Liberapay][⛳liberapay],
#<--rubocop/md-->[PayPal][🖇paypal],
#<--rubocop/md-->[Open Collective][🖇osc]
#<--rubocop/md-->and [Tidelift][🏙️entsup-tidelift].
#<--rubocop/md-->
#<--rubocop/md-->| 📍 NOTE                                                                                                                                                                                                              |
#<--rubocop/md-->|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
#<--rubocop/md-->| If doing a sponsorship in the form of donation is problematic for your company <br/> from an accounting standpoint, we'd recommend the use of Tidelift, <br/> where you can get a support-like subscription instead. |
#<--rubocop/md-->
#<--rubocop/md-->### Open Collective for Individuals
#<--rubocop/md-->
#<--rubocop/md-->Support us with a monthly donation and help us continue our activities. [[Become a backer](https://opencollective.com/kettle-rb#backer)]
#<--rubocop/md-->
#<--rubocop/md-->NOTE: [kettle-readme-backers][kettle-readme-backers] updates this list every day, automatically.
#<--rubocop/md-->
#<--rubocop/md--><!-- OPENCOLLECTIVE-INDIVIDUALS:START -->
#<--rubocop/md-->No backers yet. Be the first!
#<--rubocop/md--><!-- OPENCOLLECTIVE-INDIVIDUALS:END -->
#<--rubocop/md-->
#<--rubocop/md-->### Open Collective for Organizations
#<--rubocop/md-->
#<--rubocop/md-->Become a sponsor and get your logo on our README on GitHub with a link to your site. [[Become a sponsor](https://opencollective.com/kettle-rb#sponsor)]
#<--rubocop/md-->
#<--rubocop/md-->NOTE: [kettle-readme-backers][kettle-readme-backers] updates this list every day, automatically.
#<--rubocop/md-->
#<--rubocop/md--><!-- OPENCOLLECTIVE-ORGANIZATIONS:START -->
#<--rubocop/md-->No sponsors yet. Be the first!
#<--rubocop/md--><!-- OPENCOLLECTIVE-ORGANIZATIONS:END -->
#<--rubocop/md-->
#<--rubocop/md-->[kettle-readme-backers]: https://github.com/kettle-rb/ast-merge/blob/main/exe/kettle-readme-backers
#<--rubocop/md-->
#<--rubocop/md-->### Another way to support open-source
#<--rubocop/md-->
#<--rubocop/md-->I’m driven by a passion to foster a thriving open-source community – a space where people can tackle complex problems, no matter how small.  Revitalizing libraries that have fallen into disrepair, and building new libraries focused on solving real-world challenges, are my passions.  I was recently affected by layoffs, and the tech jobs market is unwelcoming. I’m reaching out here because your support would significantly aid my efforts to provide for my family, and my farm (11 🐔 chickens, 2 🐶 dogs, 3 🐰 rabbits, 8 🐈‍ cats).
#<--rubocop/md-->
#<--rubocop/md-->If you work at a company that uses my work, please encourage them to support me as a corporate sponsor. My work on gems you use might show up in `bundle fund`.
#<--rubocop/md-->
#<--rubocop/md-->I’m developing a new library, [floss_funding][🖇floss-funding-gem], designed to empower open-source developers like myself to get paid for the work we do, in a sustainable way. Please give it a look.
#<--rubocop/md-->
#<--rubocop/md-->**[Floss-Funding.dev][🖇floss-funding.dev]: 👉️ No network calls. 👉️ No tracking. 👉️ No oversight. 👉️ Minimal crypto hashing. 💡 Easily disabled nags**
#<--rubocop/md-->
#<--rubocop/md-->[![OpenCollective Backers][🖇osc-backers-i]][🖇osc-backers] [![OpenCollective Sponsors][🖇osc-sponsors-i]][🖇osc-sponsors] [![Sponsor Me on Github][🖇sponsor-img]][🖇sponsor] [![Liberapay Goal Progress][⛳liberapay-img]][⛳liberapay] [![Donate on PayPal][🖇paypal-img]][🖇paypal] [![Buy me a coffee][🖇buyme-small-img]][🖇buyme] [![Donate on Polar][🖇polar-img]][🖇polar] [![Donate to my FLOSS efforts at ko-fi.com][🖇kofi-img]][🖇kofi] [![Donate to my FLOSS efforts using Patreon][🖇patreon-img]][🖇patreon]
#<--rubocop/md-->
#<--rubocop/md-->## 🔐 Security
#<--rubocop/md-->
#<--rubocop/md-->See [SECURITY.md][🔐security].
#<--rubocop/md-->
#<--rubocop/md-->## 🤝 Contributing
#<--rubocop/md-->
#<--rubocop/md-->If you need some ideas of where to help, you could work on adding more code coverage,
#<--rubocop/md-->or if it is already 💯 (see [below](#code-coverage)) check [reek](REEK), [issues][🤝gh-issues], or [PRs][🤝gh-pulls],
#<--rubocop/md-->or use the gem and think about how it could be better.
#<--rubocop/md-->
#<--rubocop/md-->We [![Keep A Changelog][📗keep-changelog-img]][📗keep-changelog] so if you make changes, remember to update it.
#<--rubocop/md-->
#<--rubocop/md-->See [CONTRIBUTING.md][🤝contributing] for more detailed instructions.
#<--rubocop/md-->
#<--rubocop/md-->### 🚀 Release Instructions
#<--rubocop/md-->
#<--rubocop/md-->See [CONTRIBUTING.md][🤝contributing].
#<--rubocop/md-->
#<--rubocop/md-->### Code Coverage
#<--rubocop/md-->
#<--rubocop/md-->[![Coverage Graph][🏀codecov-g]][🏀codecov]
#<--rubocop/md-->
#<--rubocop/md-->[![Coveralls Test Coverage][🏀coveralls-img]][🏀coveralls]
#<--rubocop/md-->
#<--rubocop/md-->[![QLTY Test Coverage][🏀qlty-covi]][🏀qlty-cov]
#<--rubocop/md-->
#<--rubocop/md-->### 🪇 Code of Conduct
#<--rubocop/md-->
#<--rubocop/md-->Everyone interacting with this project's codebases, issue trackers,
#<--rubocop/md-->chat rooms and mailing lists agrees to follow the [![Contributor Covenant 2.1][🪇conduct-img]][🪇conduct].
#<--rubocop/md-->
#<--rubocop/md-->## 🌈 Contributors
#<--rubocop/md-->
#<--rubocop/md-->[![Contributors][🖐contributors-img]][🖐contributors]
#<--rubocop/md-->
#<--rubocop/md-->Made with [contributors-img][🖐contrib-rocks].
#<--rubocop/md-->
#<--rubocop/md-->Also see GitLab Contributors: [https://gitlab.com/kettle-rb/ast-merge/-/graphs/main][🚎contributors-gl]
#<--rubocop/md-->
#<--rubocop/md--><details>
#<--rubocop/md-->    <summary>⭐️ Star History</summary>
#<--rubocop/md-->
#<--rubocop/md--><a href="https://star-history.com/#kettle-rb/ast-merge&Date">
#<--rubocop/md--> <picture>
#<--rubocop/md-->   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=kettle-rb/ast-merge&type=Date&theme=dark" />
#<--rubocop/md-->   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=kettle-rb/ast-merge&type=Date" />
#<--rubocop/md-->   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=kettle-rb/ast-merge&type=Date" />
#<--rubocop/md--> </picture>
#<--rubocop/md--></a>
#<--rubocop/md-->
#<--rubocop/md--></details>
#<--rubocop/md-->
#<--rubocop/md-->## 📌 Versioning
#<--rubocop/md-->
#<--rubocop/md-->This Library adheres to [![Semantic Versioning 2.0.0][📌semver-img]][📌semver].
#<--rubocop/md-->Violations of this scheme should be reported as bugs.
#<--rubocop/md-->Specifically, if a minor or patch version is released that breaks backward compatibility,
#<--rubocop/md-->a new version should be immediately released that restores compatibility.
#<--rubocop/md-->Breaking changes to the public API will only be introduced with new major versions.
#<--rubocop/md-->
#<--rubocop/md-->> dropping support for a platform is both obviously and objectively a breaking change <br/>
#<--rubocop/md-->>—Jordan Harband ([@ljharb](https://github.com/ljharb), maintainer of SemVer) [in SemVer issue 716][📌semver-breaking]
#<--rubocop/md-->
#<--rubocop/md-->I understand that policy doesn't work universally ("exceptions to every rule!"),
#<--rubocop/md-->but it is the policy here.
#<--rubocop/md-->As such, in many cases it is good to specify a dependency on this library using
#<--rubocop/md-->the [Pessimistic Version Constraint][📌pvc] with two digits of precision.
#<--rubocop/md-->
#<--rubocop/md-->For example:
#<--rubocop/md-->
#<--rubocop/md-->```ruby
spec.add_dependency("ast-merge", "~> 5.0")
#<--rubocop/md-->```
#<--rubocop/md-->
#<--rubocop/md--><details markdown="1">
#<--rubocop/md--><summary>📌 Is "Platform Support" part of the public API? More details inside.</summary>
#<--rubocop/md-->
#<--rubocop/md-->SemVer should, IMO, but doesn't explicitly, say that dropping support for specific Platforms
#<--rubocop/md-->is a *breaking change* to an API, and for that reason the bike shedding is endless.
#<--rubocop/md-->
#<--rubocop/md-->To get a better understanding of how SemVer is intended to work over a project's lifetime,
#<--rubocop/md-->read this article from the creator of SemVer:
#<--rubocop/md-->
#<--rubocop/md-->- ["Major Version Numbers are Not Sacred"][📌major-versions-not-sacred]
#<--rubocop/md-->
#<--rubocop/md--></details>
#<--rubocop/md-->
#<--rubocop/md-->See [CHANGELOG.md][📌changelog] for a list of releases.
#<--rubocop/md-->
#<--rubocop/md-->## 📄 License
#<--rubocop/md-->
#<--rubocop/md-->The gem is available under the following license: [AGPL-3.0-only](AGPL-3.0-only.md).
#<--rubocop/md-->See [LICENSE.md][📄license] for details.
#<--rubocop/md-->
#<--rubocop/md-->If none of the available licenses suit your use case, please [contact us](mailto:floss@glatzo.com) to discuss a custom commercial license.
#<--rubocop/md-->
#<--rubocop/md-->### © Copyright
#<--rubocop/md-->
#<--rubocop/md-->See [LICENSE.md][📄license] for the official copyright notice.
#<--rubocop/md-->
#<--rubocop/md-->## 🤑 A request for help
#<--rubocop/md-->
#<--rubocop/md-->Maintainers have teeth and need to pay their dentists.
#<--rubocop/md-->After getting laid off in an RIF in March, and encountering difficulty finding a new one,
#<--rubocop/md-->I began spending most of my time building open source tools.
#<--rubocop/md-->I'm hoping to be able to pay for my kids' health insurance this month,
#<--rubocop/md-->so if you value the work I am doing, I need your support.
#<--rubocop/md-->Please consider sponsoring me or the project.
#<--rubocop/md-->
#<--rubocop/md-->To join the community or get help 👇️ Join the Discord.
#<--rubocop/md-->
#<--rubocop/md-->[![Live Chat on Discord][✉️discord-invite-img-ftb]][✉️discord-invite]
#<--rubocop/md-->
#<--rubocop/md-->To say "thanks!" ☝️ Join the Discord or 👇️ send money.
#<--rubocop/md-->
#<--rubocop/md-->[![Sponsor kettle-rb/ast-merge on Open Source Collective][🖇osc-all-bottom-img]][🖇osc] 💌 [![Sponsor me on GitHub Sponsors][🖇sponsor-bottom-img]][🖇sponsor] 💌 [![Sponsor me on Liberapay][⛳liberapay-bottom-img]][⛳liberapay] 💌 [![Donate on PayPal][🖇paypal-bottom-img]][🖇paypal]
#<--rubocop/md-->
#<--rubocop/md-->### Please give the project a star ⭐ ♥.
#<--rubocop/md-->
#<--rubocop/md-->Thanks for RTFM. ☺️
#<--rubocop/md-->
#<--rubocop/md-->[⛳liberapay-img]: https://img.shields.io/liberapay/goal/pboling.svg?logo=liberapay&color=a51611&style=flat
#<--rubocop/md-->[⛳liberapay-bottom-img]: https://img.shields.io/liberapay/goal/pboling.svg?style=for-the-badge&logo=liberapay&color=a51611
#<--rubocop/md-->[⛳liberapay]: https://liberapay.com/pboling/donate
#<--rubocop/md-->[🖇osc-all-img]: https://img.shields.io/opencollective/all/kettle-rb
#<--rubocop/md-->[🖇osc-sponsors-img]: https://img.shields.io/opencollective/sponsors/kettle-rb
#<--rubocop/md-->[🖇osc-backers-img]: https://img.shields.io/opencollective/backers/kettle-rb
#<--rubocop/md-->[🖇osc-backers]: https://opencollective.com/kettle-rb#backer
#<--rubocop/md-->[🖇osc-backers-i]: https://opencollective.com/kettle-rb/backers/badge.svg?style=flat
#<--rubocop/md-->[🖇osc-sponsors]: https://opencollective.com/kettle-rb#sponsor
#<--rubocop/md-->[🖇osc-sponsors-i]: https://opencollective.com/kettle-rb/sponsors/badge.svg?style=flat
#<--rubocop/md-->[🖇osc-all-bottom-img]: https://img.shields.io/opencollective/all/kettle-rb?style=for-the-badge
#<--rubocop/md-->[🖇osc-sponsors-bottom-img]: https://img.shields.io/opencollective/sponsors/kettle-rb?style=for-the-badge
#<--rubocop/md-->[🖇osc-backers-bottom-img]: https://img.shields.io/opencollective/backers/kettle-rb?style=for-the-badge
#<--rubocop/md-->[🖇osc]: https://opencollective.com/kettle-rb
#<--rubocop/md-->[🖇sponsor-img]: https://img.shields.io/badge/Sponsor_Me!-pboling.svg?style=social&logo=github
#<--rubocop/md-->[🖇sponsor-bottom-img]: https://img.shields.io/badge/Sponsor_Me!-pboling-blue?style=for-the-badge&logo=github
#<--rubocop/md-->[🖇sponsor]: https://github.com/sponsors/pboling
#<--rubocop/md-->[🖇polar-img]: https://img.shields.io/badge/polar-donate-a51611.svg?style=flat
#<--rubocop/md-->[🖇polar]: https://polar.sh/pboling
#<--rubocop/md-->[🖇kofi-img]: https://img.shields.io/badge/ko--fi-%E2%9C%93-a51611.svg?style=flat
#<--rubocop/md-->[🖇kofi]: https://ko-fi.com/pboling
#<--rubocop/md-->[🖇patreon-img]: https://img.shields.io/badge/patreon-donate-a51611.svg?style=flat
#<--rubocop/md-->[🖇patreon]: https://patreon.com/galtzo
#<--rubocop/md-->[🖇buyme-small-img]: https://img.shields.io/badge/buy_me_a_coffee-%E2%9C%93-a51611.svg?style=flat
#<--rubocop/md-->[🖇buyme-img]: https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20latte&emoji=&slug=pboling&button_colour=FFDD00&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=ffffff
#<--rubocop/md-->[🖇buyme]: https://www.buymeacoffee.com/pboling
#<--rubocop/md-->[🖇paypal-img]: https://img.shields.io/badge/donate-paypal-a51611.svg?style=flat&logo=paypal
#<--rubocop/md-->[🖇paypal-bottom-img]: https://img.shields.io/badge/donate-paypal-a51611.svg?style=for-the-badge&logo=paypal&color=0A0A0A
#<--rubocop/md-->[🖇paypal]: https://www.paypal.com/paypalme/peterboling
#<--rubocop/md-->[🖇floss-funding.dev]: https://floss-funding.dev
#<--rubocop/md-->[🖇floss-funding-gem]: https://github.com/galtzo-floss/floss_funding
#<--rubocop/md-->[✉️discord-invite]: https://discord.gg/3qme4XHNKN
#<--rubocop/md-->[✉️discord-invite-img-ftb]: https://img.shields.io/discord/1373797679469170758?style=for-the-badge&logo=discord
#<--rubocop/md-->[✉️ruby-friends-img]: https://img.shields.io/badge/daily.dev-%F0%9F%92%8E_Ruby_Friends-0A0A0A?style=for-the-badge&logo=dailydotdev&logoColor=white
#<--rubocop/md-->[✉️ruby-friends]: https://app.daily.dev/squads/rubyfriends
#<--rubocop/md-->
#<--rubocop/md-->[✇bundle-group-pattern]: https://gist.github.com/pboling/4564780
#<--rubocop/md-->[⛳️gem-namespace]: https://github.com/kettle-rb/ast-merge
#<--rubocop/md-->[⛳️namespace-img]: https://img.shields.io/badge/namespace-Ast::Merge-3C2D2D.svg?style=square&logo=ruby&logoColor=white
#<--rubocop/md-->[⛳️gem-name]: https://bestgems.org/gems/ast-merge
#<--rubocop/md-->[⛳️name-img]: https://img.shields.io/badge/name-ast--merge-3C2D2D.svg?style=square&logo=rubygems&logoColor=red
#<--rubocop/md-->[⛳️tag-img]: https://img.shields.io/github/tag/kettle-rb/ast-merge.svg
#<--rubocop/md-->[⛳️tag]: http://github.com/kettle-rb/ast-merge/releases
#<--rubocop/md-->[🚂maint-blog]: http://www.railsbling.com/tags/ast-merge
#<--rubocop/md-->[🚂maint-blog-img]: https://img.shields.io/badge/blog-railsbling-0093D0.svg?style=for-the-badge&logo=rubyonrails&logoColor=orange
#<--rubocop/md-->[🚂maint-contact]: http://www.railsbling.com/contact
#<--rubocop/md-->[🚂maint-contact-img]: https://img.shields.io/badge/Contact-Maintainer-0093D0.svg?style=flat&logo=rubyonrails&logoColor=red
#<--rubocop/md-->[💖🖇linkedin]: http://www.linkedin.com/in/peterboling
#<--rubocop/md-->[💖🖇linkedin-img]: https://img.shields.io/badge/LinkedIn-Profile-0B66C2?style=flat&logo=newjapanprowrestling
#<--rubocop/md-->[💖✌️wellfound]: https://wellfound.com/u/peter-boling
#<--rubocop/md-->[💖✌️wellfound-img]: https://img.shields.io/badge/peter--boling-orange?style=flat&logo=wellfound
#<--rubocop/md-->[💖💲crunchbase]: https://www.crunchbase.com/person/peter-boling
#<--rubocop/md-->[💖💲crunchbase-img]: https://img.shields.io/badge/peter--boling-purple?style=flat&logo=crunchbase
#<--rubocop/md-->[💖🐘ruby-mast]: https://ruby.social/@galtzo
#<--rubocop/md-->[💖🐘ruby-mast-img]: https://img.shields.io/mastodon/follow/109447111526622197?domain=https://ruby.social&style=flat&logo=mastodon&label=Ruby%20@galtzo
#<--rubocop/md-->[💖🦋bluesky]: https://bsky.app/profile/galtzo.com
#<--rubocop/md-->[💖🦋bluesky-img]: https://img.shields.io/badge/@galtzo.com-0285FF?style=flat&logo=bluesky&logoColor=white
#<--rubocop/md-->[💖🌳linktree]: https://linktr.ee/galtzo
#<--rubocop/md-->[💖🌳linktree-img]: https://img.shields.io/badge/galtzo-purple?style=flat&logo=linktree
#<--rubocop/md-->[💖💁🏼‍♂️devto]: https://dev.to/galtzo
#<--rubocop/md-->[💖💁🏼‍♂️devto-img]: https://img.shields.io/badge/dev.to-0A0A0A?style=flat&logo=devdotto&logoColor=white
#<--rubocop/md-->[💖💁🏼‍♂️aboutme]: https://about.me/peter.boling
#<--rubocop/md-->[💖💁🏼‍♂️aboutme-img]: https://img.shields.io/badge/about.me-0A0A0A?style=flat&logo=aboutme&logoColor=white
#<--rubocop/md-->[💖🧊berg]: https://codeberg.org/pboling
#<--rubocop/md-->[💖🐙hub]: https://github.org/pboling
#<--rubocop/md-->[💖🛖hut]: https://sr.ht/~galtzo/
#<--rubocop/md-->[💖🧪lab]: https://gitlab.com/pboling
#<--rubocop/md-->[👨🏼‍🏫expsup-upwork]: https://www.upwork.com/freelancers/~014942e9b056abdf86?mp_source=share
#<--rubocop/md-->[👨🏼‍🏫expsup-upwork-img]: https://img.shields.io/badge/UpWork-13544E?style=for-the-badge&logo=Upwork&logoColor=white
#<--rubocop/md-->[👨🏼‍🏫expsup-codementor]: https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github
#<--rubocop/md-->[👨🏼‍🏫expsup-codementor-img]: https://img.shields.io/badge/CodeMentor-Get_Help-1abc9c?style=for-the-badge&logo=CodeMentor&logoColor=white
#<--rubocop/md-->[🏙️entsup-tidelift]: https://tidelift.com/subscription/pkg/rubygems-ast-merge?utm_source=rubygems-ast-merge&utm_medium=referral&utm_campaign=readme
#<--rubocop/md-->[🏙️entsup-tidelift-img]: https://img.shields.io/badge/Tidelift_and_Sonar-Enterprise_Support-FD3456?style=for-the-badge&logo=sonar&logoColor=white
#<--rubocop/md-->[🏙️entsup-tidelift-sonar]: https://blog.tidelift.com/tidelift-joins-sonar
#<--rubocop/md-->[💁🏼‍♂️peterboling]: http://www.peterboling.com
#<--rubocop/md-->[🚂railsbling]: http://www.railsbling.com
#<--rubocop/md-->[📜src-gl-img]: https://img.shields.io/badge/GitLab-FBA326?style=for-the-badge&logo=Gitlab&logoColor=orange
#<--rubocop/md-->[📜src-gl]: https://gitlab.com/kettle-rb/ast-merge/
#<--rubocop/md-->[📜src-cb-img]: https://img.shields.io/badge/CodeBerg-4893CC?style=for-the-badge&logo=CodeBerg&logoColor=blue
#<--rubocop/md-->[📜src-cb]: https://codeberg.org/kettle-rb/ast-merge
#<--rubocop/md-->[📜src-gh-img]: https://img.shields.io/badge/GitHub-238636?style=for-the-badge&logo=Github&logoColor=green
#<--rubocop/md-->[📜src-gh]: https://github.com/kettle-rb/ast-merge
#<--rubocop/md-->[📜docs-cr-rd-img]: https://img.shields.io/badge/RubyDoc-Current_Release-943CD2?style=for-the-badge&logo=readthedocs&logoColor=white
#<--rubocop/md-->[📜docs-head-rd-img]: https://img.shields.io/badge/YARD_on_Galtzo.com-HEAD-943CD2?style=for-the-badge&logo=readthedocs&logoColor=white
#<--rubocop/md-->[📜gl-wiki]: https://gitlab.com/kettle-rb/ast-merge/-/wikis/home
#<--rubocop/md-->[📜gh-wiki]: https://github.com/kettle-rb/ast-merge/wiki
#<--rubocop/md-->[📜gl-wiki-img]: https://img.shields.io/badge/wiki-examples-943CD2.svg?style=for-the-badge&logo=gitlab&logoColor=white
#<--rubocop/md-->[📜gh-wiki-img]: https://img.shields.io/badge/wiki-examples-943CD2.svg?style=for-the-badge&logo=github&logoColor=white
#<--rubocop/md-->[👽dl-rank]: https://bestgems.org/gems/ast-merge
#<--rubocop/md-->[👽dl-ranki]: https://img.shields.io/gem/rd/ast-merge.svg
#<--rubocop/md-->[👽oss-help]: https://www.codetriage.com/kettle-rb/ast-merge
#<--rubocop/md-->[👽oss-helpi]: https://www.codetriage.com/kettle-rb/ast-merge/badges/users.svg
#<--rubocop/md-->[👽version]: https://bestgems.org/gems/ast-merge
#<--rubocop/md-->[👽versioni]: https://img.shields.io/gem/v/ast-merge.svg
#<--rubocop/md-->[🏀qlty-mnt]: https://qlty.sh/gh/kettle-rb/projects/ast-merge
#<--rubocop/md-->[🏀qlty-mnti]: https://qlty.sh/gh/kettle-rb/projects/ast-merge/maintainability.svg
#<--rubocop/md-->[🏀qlty-cov]: https://qlty.sh/gh/kettle-rb/projects/ast-merge/metrics/code?sort=coverageRating
#<--rubocop/md-->[🏀qlty-covi]: https://qlty.sh/gh/kettle-rb/projects/ast-merge/coverage.svg
#<--rubocop/md-->[🏀codecov]: https://codecov.io/gh/kettle-rb/ast-merge
#<--rubocop/md-->[🏀codecovi]: https://codecov.io/gh/kettle-rb/ast-merge/graph/badge.svg
#<--rubocop/md-->[🏀coveralls]: https://coveralls.io/github/kettle-rb/ast-merge?branch=main
#<--rubocop/md-->[🏀coveralls-img]: https://coveralls.io/repos/github/kettle-rb/ast-merge/badge.svg?branch=main
#<--rubocop/md-->[🖐codeQL]: https://github.com/kettle-rb/ast-merge/security/code-scanning
#<--rubocop/md-->[🖐codeQL-img]: https://github.com/kettle-rb/ast-merge/actions/workflows/codeql-analysis.yml/badge.svg
#<--rubocop/md-->[🚎ruby-3.2-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/ruby-3.2.yml
#<--rubocop/md-->[🚎ruby-3.3-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/ruby-3.3.yml
#<--rubocop/md-->[🚎ruby-3.4-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/ruby-3.4.yml
#<--rubocop/md-->[🚎truby-24.2-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/truffleruby-24.2.yml
#<--rubocop/md-->[🚎truby-25.0-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/truffleruby-25.0.yml
#<--rubocop/md-->[🚎2-cov-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/coverage.yml
#<--rubocop/md-->[🚎2-cov-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/coverage.yml/badge.svg
#<--rubocop/md-->[🚎3-hd-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/heads.yml
#<--rubocop/md-->[🚎3-hd-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/heads.yml/badge.svg
#<--rubocop/md-->[🚎5-st-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/style.yml
#<--rubocop/md-->[🚎5-st-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/style.yml/badge.svg
#<--rubocop/md-->[🚎9-t-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/truffle.yml
#<--rubocop/md-->[🚎9-t-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/truffle.yml/badge.svg
#<--rubocop/md-->[🚎10-j-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/jruby.yml
#<--rubocop/md-->[🚎10-j-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/jruby.yml/badge.svg
#<--rubocop/md-->[🚎11-c-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml
#<--rubocop/md-->[🚎11-c-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml/badge.svg
#<--rubocop/md-->[🚎12-crh-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/dep-heads.yml
#<--rubocop/md-->[🚎12-crh-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/dep-heads.yml/badge.svg
#<--rubocop/md-->[🚎13-🔒️-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/locked_deps.yml
#<--rubocop/md-->[🚎13-🔒️-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/locked_deps.yml/badge.svg
#<--rubocop/md-->[🚎14-🔓️-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/unlocked_deps.yml
#<--rubocop/md-->[🚎14-🔓️-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/unlocked_deps.yml/badge.svg
#<--rubocop/md-->[🚎15-🪪-wf]: https://github.com/kettle-rb/ast-merge/actions/workflows/license-eye.yml
#<--rubocop/md-->[🚎15-🪪-wfi]: https://github.com/kettle-rb/ast-merge/actions/workflows/license-eye.yml/badge.svg
#<--rubocop/md-->[💎ruby-3.2i]: https://img.shields.io/badge/Ruby-3.2-CC342D?style=for-the-badge&logo=ruby&logoColor=white
#<--rubocop/md-->[💎ruby-3.3i]: https://img.shields.io/badge/Ruby-3.3-CC342D?style=for-the-badge&logo=ruby&logoColor=white
#<--rubocop/md-->[💎ruby-3.4i]: https://img.shields.io/badge/Ruby-3.4-CC342D?style=for-the-badge&logo=ruby&logoColor=white
#<--rubocop/md-->[💎ruby-4.0i]: https://img.shields.io/badge/Ruby-4.0-CC342D?style=for-the-badge&logo=ruby&logoColor=white
#<--rubocop/md-->[💎ruby-c-i]: https://img.shields.io/badge/Ruby-current-CC342D?style=for-the-badge&logo=ruby&logoColor=green
#<--rubocop/md-->[💎ruby-headi]: https://img.shields.io/badge/Ruby-HEAD-CC342D?style=for-the-badge&logo=ruby&logoColor=blue
#<--rubocop/md-->[💎truby-24.2i]: https://img.shields.io/badge/Truffle_Ruby-24.2-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink
#<--rubocop/md-->[💎truby-25.0i]: https://img.shields.io/badge/Truffle_Ruby-25.0-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink
#<--rubocop/md-->[💎truby-c-i]: https://img.shields.io/badge/Truffle_Ruby-current-34BCB1?style=for-the-badge&logo=ruby&logoColor=green
#<--rubocop/md-->[💎jruby-c-i]: https://img.shields.io/badge/JRuby-current-FBE742?style=for-the-badge&logo=ruby&logoColor=green
#<--rubocop/md-->[💎jruby-headi]: https://img.shields.io/badge/JRuby-HEAD-FBE742?style=for-the-badge&logo=ruby&logoColor=blue
#<--rubocop/md-->[🤝gh-issues]: https://github.com/kettle-rb/ast-merge/issues
#<--rubocop/md-->[🤝gh-pulls]: https://github.com/kettle-rb/ast-merge/pulls
#<--rubocop/md-->[🤝gl-issues]: https://gitlab.com/kettle-rb/ast-merge/-/issues
#<--rubocop/md-->[🤝gl-pulls]: https://gitlab.com/kettle-rb/ast-merge/-/merge_requests
#<--rubocop/md-->[🤝cb-issues]: https://codeberg.org/kettle-rb/ast-merge/issues
#<--rubocop/md-->[🤝cb-pulls]: https://codeberg.org/kettle-rb/ast-merge/pulls
#<--rubocop/md-->[🤝cb-donate]: https://donate.codeberg.org/
#<--rubocop/md-->[🤝contributing]: CONTRIBUTING.md
#<--rubocop/md-->[🏀codecov-g]: https://codecov.io/gh/kettle-rb/ast-merge/graphs/tree.svg
#<--rubocop/md-->[🖐contrib-rocks]: https://contrib.rocks
#<--rubocop/md-->[🖐contributors]: https://github.com/kettle-rb/ast-merge/graphs/contributors
#<--rubocop/md-->[🖐contributors-img]: https://contrib.rocks/image?repo=kettle-rb/ast-merge
#<--rubocop/md-->[🚎contributors-gl]: https://gitlab.com/kettle-rb/ast-merge/-/graphs/main
#<--rubocop/md-->[🪇conduct]: CODE_OF_CONDUCT.md
#<--rubocop/md-->[🪇conduct-img]: https://img.shields.io/badge/Contributor_Covenant-2.1-259D6C.svg
#<--rubocop/md-->[📌pvc]: http://guides.rubygems.org/patterns/#pessimistic-version-constraint
#<--rubocop/md-->[📌semver]: https://semver.org/spec/v2.0.0.html
#<--rubocop/md-->[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-259D6C.svg?style=flat
#<--rubocop/md-->[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
#<--rubocop/md-->[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
#<--rubocop/md-->[📌changelog]: CHANGELOG.md
#<--rubocop/md-->[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
#<--rubocop/md-->[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-34495e.svg?style=flat
#<--rubocop/md-->[📌gitmoji]: https://gitmoji.dev
#<--rubocop/md-->[📌gitmoji-img]: https://img.shields.io/badge/gitmoji_commits-%20%F0%9F%98%9C%20%F0%9F%98%8D-34495e.svg?style=flat-square
#<--rubocop/md-->[🧮kloc]: https://www.youtube.com/watch?v=dQw4w9WgXcQ
#<--rubocop/md-->[🧮kloc-img]: https://img.shields.io/badge/KLOC-5.053-FFDD67.svg?style=for-the-badge&logo=YouTube&logoColor=blue
#<--rubocop/md-->[🔐security]: SECURITY.md
#<--rubocop/md-->[🔐security-img]: https://img.shields.io/badge/security-policy-259D6C.svg?style=flat
#<--rubocop/md-->[📄copyright-notice-explainer]: https://opensource.stackexchange.com/questions/5778/why-do-licenses-such-as-the-mit-license-specify-a-single-year
#<--rubocop/md-->[📄license]: LICENSE.md
#<--rubocop/md-->[📄license-compat]: https://dev.to/galtzo/how-to-check-license-compatibility-41h0
#<--rubocop/md-->[📄license-compat-img]: https://img.shields.io/badge/Apache_Compatible:_Category_A-%E2%9C%93-259D6C.svg?style=flat&logo=Apache
#<--rubocop/md-->[📄ilo-declaration]: https://www.ilo.org/declaration/lang--en/index.htm
#<--rubocop/md-->[📄ilo-declaration-img]: https://img.shields.io/badge/ILO_Fundamental_Principles-✓-259D6C.svg?style=flat
#<--rubocop/md-->[🚎yard-current]: http://rubydoc.info/gems/ast-merge
#<--rubocop/md-->[🚎yard-head]: https://ast-merge.galtzo.com
#<--rubocop/md-->[💎stone_checksums]: https://github.com/galtzo-floss/stone_checksums
#<--rubocop/md-->[💎SHA_checksums]: https://gitlab.com/kettle-rb/ast-merge/-/tree/main/checksums
#<--rubocop/md-->[💎rlts]: https://github.com/rubocop-lts/rubocop-lts
#<--rubocop/md-->[💎rlts-img]: https://img.shields.io/badge/code_style_&_linting-rubocop--lts-34495e.svg?plastic&logo=ruby&logoColor=white
#<--rubocop/md-->[💎appraisal2]: https://github.com/appraisal-rb/appraisal2
#<--rubocop/md-->[💎appraisal2-img]: https://img.shields.io/badge/appraised_by-appraisal2-34495e.svg?plastic&logo=ruby&logoColor=white
#<--rubocop/md-->[💎d-in-dvcs]: https://railsbling.com/posts/dvcs/put_the_d_in_dvcs/
