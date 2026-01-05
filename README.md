| 📍 NOTE |
| --- |
| RubyGems (the [GitHub org](https://github.com/rubygems/), not the website) [suffered](https://joel.drapper.me/p/ruby-central-security-measures/) a [hostile takeover](https://pup-e.com/blog/goodbye-rubygems/) in September 2025. |
| Ultimately [4 maintainers](https://www.reddit.com/r/ruby/s/gOk42POCaV) were [hard removed](https://bsky.app/profile/martinemde.com/post/3m3occezxxs2q) and a reason has been given for only 1 of those, while 2 others resigned in protest. |
| It is a [complicated story](https://joel.drapper.me/p/ruby-central-takeover/) which is difficult to [parse quickly](https://joel.drapper.me/p/ruby-central-fact-check/). |
| Simply put - there was active policy for adding or removing maintainers/owners of [rubygems](https://github.com/ruby/rubygems/blob/b1ab33a3d52310a84d16b193991af07f5a6a07c0/doc/rubygems/POLICIES.md?plain=1#L187-L196) and [bundler](https://github.com/ruby/rubygems/blob/b1ab33a3d52310a84d16b193991af07f5a6a07c0/doc/bundler/playbooks/TEAM_CHANGES.md), and those [policies were not followed](https://www.reddit.com/r/ruby/comments/1ove9vp/rubycentral_hates_this_one_fact/). |
| I'm adding notes like this to gems because I [don't condone theft](https://joel.drapper.me/p/ruby-central/) of repositories or gems from their rightful owners. |
| If a similar theft happened with my repos/gems, I'd hope some would stand up for me. |
| Disenfranchised former-maintainers have started [gem.coop](https://gem.coop). |
| Once available I will publish there exclusively; unless RubyCentral makes amends with the community. |
| The ["Technology for Humans: Joel Draper"](https://youtu.be/_H4qbtC5qzU?si=BvuBU90R2wAqD2E6) podcast episode by [reinteractive](https://reinteractive.com/ruby-on-rails) is the most cogent summary I'm aware of. |
| See [here](https://github.com/gem-coop/gem.coop/issues/12), [here](https://gem.coop) and [here](https://martinemde.com/2025/10/05/announcing-gem-coop.html) for more info on what comes next. |
| What I'm doing: A (WIP) proposal for [bundler/gem scopes](https://github.com/galtzo-floss/bundle-namespace), and a (WIP) proposal for a federated [gem server](https://github.com/galtzo-floss/gem-server). |

[rubygems-org]: https://github.com/rubygems/
[draper-security]: https://joel.drapper.me/p/ruby-central-security-measures/
[draper-takeover]: https://joel.drapper.me/p/ruby-central-takeover/
[ellen-takeover]: https://pup-e.com/blog/goodbye-rubygems/
[simi-removed]: https://www.reddit.com/r/ruby/s/gOk42POCaV
[martin-removed]: https://bsky.app/profile/martinemde.com/post/3m3occezxxs2q
[draper-lies]: https://joel.drapper.me/p/ruby-central-fact-check/
[draper-theft]: https://joel.drapper.me/p/ruby-central/
[reinteractive]: https://reinteractive.com/ruby-on-rails
[gem-coop]: https://gem.coop
[gem-naming]: https://github.com/gem-coop/gem.coop/issues/12
[martin-ann]: https://martinemde.com/2025/10/05/announcing-gem-coop.html
[gem-scopes]: https://github.com/galtzo-floss/bundle-namespace
[gem-server]: https://github.com/galtzo-floss/gem-server
[reinteractive-podcast]: https://youtu.be/_H4qbtC5qzU?si=BvuBU90R2wAqD2E6
[bundler-maint-policy]: https://github.com/ruby/rubygems/blob/b1ab33a3d52310a84d16b193991af07f5a6a07c0/doc/bundler/playbooks/TEAM_CHANGES.md
[rubygems-maint-policy]: https://github.com/ruby/rubygems/blob/b1ab33a3d52310a84d16b193991af07f5a6a07c0/doc/rubygems/POLICIES.md?plain=1#L187-L196
[policy-fail]: https://www.reddit.com/r/ruby/comments/1ove9vp/rubycentral_hates_this_one_fact/

[![Galtzo FLOSS Logo by Aboling0, CC BY-SA 4.0](https://logos.galtzo.com/assets/images/galtzo-floss/avatar-192px.svg)](https://discord.gg/3qme4XHNKN) [![ruby-lang Logo, Yukihiro Matsumoto, Ruby Visual Identity Team, CC BY-SA 2.5](https://logos.galtzo.com/assets/images/ruby-lang/avatar-192px.svg)](https://www.ruby-lang.org/) [![kettle-rb Logo by Aboling0, CC BY-SA 4.0](https://logos.galtzo.com/assets/images/kettle-rb/avatar-192px.svg)](https://github.com/kettle-rb)

[🖼️galtzo-i]: https://logos.galtzo.com/assets/images/galtzo-floss/avatar-192px.svg
[🖼️galtzo-discord]: https://discord.gg/3qme4XHNKN
[🖼️ruby-lang-i]: https://logos.galtzo.com/assets/images/ruby-lang/avatar-192px.svg
[🖼️ruby-lang]: https://www.ruby-lang.org/
[🖼️kettle-rb-i]: https://logos.galtzo.com/assets/images/kettle-rb/avatar-192px.svg
[🖼️kettle-rb]: https://github.com/kettle-rb

# ☯️ Ast::Merge

[![Version](https://img.shields.io/gem/v/ast-merge.svg)](https://bestgems.org/gems/ast-merge) [![GitHub tag (latest SemVer)](https://img.shields.io/github/tag/kettle-rb/ast-merge.svg)](http://github.com/kettle-rb/ast-merge/releases) [![License: MIT](https://img.shields.io/badge/License-MIT-259D6C.svg)](https://opensource.org/licenses/MIT) [![Downloads Rank](https://img.shields.io/gem/rd/ast-merge.svg)](https://bestgems.org/gems/ast-merge) [![Open Source Helpers](https://www.codetriage.com/kettle-rb/ast-merge/badges/users.svg)](https://www.codetriage.com/kettle-rb/ast-merge) [![CodeCov Test Coverage](https://codecov.io/gh/kettle-rb/ast-merge/graph/badge.svg)](https://codecov.io/gh/kettle-rb/ast-merge) [![Coveralls Test Coverage](https://coveralls.io/repos/github/kettle-rb/ast-merge/badge.svg?branch=main)](https://coveralls.io/github/kettle-rb/ast-merge?branch=main) [![QLTY Test Coverage](https://qlty.sh/gh/kettle-rb/projects/ast-merge/coverage.svg)](https://qlty.sh/gh/kettle-rb/projects/ast-merge/metrics/code?sort=coverageRating) [![QLTY Maintainability](https://qlty.sh/gh/kettle-rb/projects/ast-merge/maintainability.svg)](https://qlty.sh/gh/kettle-rb/projects/ast-merge) [![CI Heads](https://github.com/kettle-rb/ast-merge/actions/workflows/heads.yml/badge.svg)](https://github.com/kettle-rb/ast-merge/actions/workflows/heads.yml) [![CI Runtime Dependencies @ HEAD](https://github.com/kettle-rb/ast-merge/actions/workflows/dep-heads.yml/badge.svg)](https://github.com/kettle-rb/ast-merge/actions/workflows/dep-heads.yml) [![CI Current](https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml/badge.svg)](https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml) [![CI Truffle Ruby](https://github.com/kettle-rb/ast-merge/actions/workflows/truffle.yml/badge.svg)](https://github.com/kettle-rb/ast-merge/actions/workflows/truffle.yml) [![Deps Locked](https://github.com/kettle-rb/ast-merge/actions/workflows/locked_deps.yml/badge.svg)](https://github.com/kettle-rb/ast-merge/actions/workflows/locked_deps.yml) [![Deps Unlocked](https://github.com/kettle-rb/ast-merge/actions/workflows/unlocked_deps.yml/badge.svg)](https://github.com/kettle-rb/ast-merge/actions/workflows/unlocked_deps.yml) [![CI Supported](https://github.com/kettle-rb/ast-merge/actions/workflows/supported.yml/badge.svg)](https://github.com/kettle-rb/ast-merge/actions/workflows/supported.yml) [![CI Test Coverage](https://github.com/kettle-rb/ast-merge/actions/workflows/coverage.yml/badge.svg)](https://github.com/kettle-rb/ast-merge/actions/workflows/coverage.yml) [![CI Style](https://github.com/kettle-rb/ast-merge/actions/workflows/style.yml/badge.svg)](https://github.com/kettle-rb/ast-merge/actions/workflows/style.yml) [![CodeQL](https://github.com/kettle-rb/ast-merge/actions/workflows/codeql-analysis.yml/badge.svg)](https://github.com/kettle-rb/ast-merge/security/code-scanning) [![Apache SkyWalking Eyes License Compatibility Check](https://github.com/kettle-rb/prism-merge/actions/workflows/license-eye.yml/badge.svg)](https://github.com/kettle-rb/ast-merge/actions/workflows/license-eye.yml)

`if ci_badges.map(&:color).detect { it != "green"}` ☝️ [let me know](https://discord.gg/3qme4XHNKN), as I may have missed the [discord notification](https://discord.gg/3qme4XHNKN).

-----
`if ci_badges.map(&:color).all? { it == "green"}` 👇️ send money so I can do more of this. FLOSS maintenance is now my full-time job.

[![OpenCollective Backers](https://opencollective.com/kettle-rb/backers/badge.svg?style=flat)](https://opencollective.com/kettle-rb#backer) [![OpenCollective Sponsors](https://opencollective.com/kettle-rb/sponsors/badge.svg?style=flat)](https://opencollective.com/kettle-rb#sponsor) [![Sponsor Me on Github](https://img.shields.io/badge/Sponsor_Me!-pboling.svg?style=social&logo=github)](https://github.com/sponsors/pboling) [![Liberapay Goal Progress](https://img.shields.io/liberapay/goal/pboling.svg?logo=liberapay&color=a51611&style=flat)](https://liberapay.com/pboling/donate) [![Donate on PayPal](https://img.shields.io/badge/donate-paypal-a51611.svg?style=flat&logo=paypal)](https://www.paypal.com/paypalme/peterboling) [![Buy me a coffee](https://img.shields.io/badge/buy_me_a_coffee-%E2%9C%93-a51611.svg?style=flat)](https://www.buymeacoffee.com/pboling) [![Donate on Polar](https://img.shields.io/badge/polar-donate-a51611.svg?style=flat)](https://polar.sh/pboling) [![Donate at ko-fi.com](https://img.shields.io/badge/ko--fi-%E2%9C%93-a51611.svg?style=flat)](https://ko-fi.com/O5O86SNP4)

## 🌻 Synopsis

Ast::Merge is **not typically used directly** - instead, use one of the format-specific gems built on top of it.

### The `*-merge` Gem Family

The `*-merge` gem family provides intelligent, AST-based merging for various file formats. At the foundation is [tree_haver][tree_haver], which provides a unified cross-Ruby parsing API that works seamlessly across MRI, JRuby, and TruffleRuby.

| Gem                                      | Language<br>/ Format | Parser Backend(s)                                                                                   | Description                                                                      |
|------------------------------------------|----------------------|-----------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| [tree_haver][tree_haver]                 | Multi                | MRI C, Rust, FFI, Java, Prism, Psych, Commonmarker, Markly, Citrus                                  | **Foundation**: Cross-Ruby adapter for parsing libraries (like Faraday for HTTP) |
| [ast-merge][ast-merge]                   | Text                 | internal                                                                                            | **Infrastructure**: Shared base classes and merge logic for all `*-merge` gems   |
| [bash-merge][bash-merge]                 | Bash                 | [tree-sitter-bash][ts-bash] (via tree_haver)                                                        | Smart merge for Bash scripts                                                     |
| [commonmarker-merge][commonmarker-merge] | Markdown             | [Commonmarker][commonmarker] (via tree_haver)                                                       | Smart merge for Markdown (CommonMark via comrak Rust)                            |
| [dotenv-merge][dotenv-merge]             | Dotenv               | internal                                                                                            | Smart merge for `.env` files                                                     |
| [json-merge][json-merge]                 | JSON                 | [tree-sitter-json][ts-json] (via tree_haver)                                                        | Smart merge for JSON files                                                       |
| [jsonc-merge][jsonc-merge]               | JSONC                | [tree-sitter-jsonc][ts-jsonc] (via tree_haver)                                                      | ⚠️ Proof of concept; Smart merge for JSON with Comments                          |
| [markdown-merge][markdown-merge]         | Markdown             | [Commonmarker][commonmarker] / [Markly][markly] (via tree_haver)                                    | **Foundation**: Shared base for Markdown mergers with inner code block merging   |
| [markly-merge][markly-merge]             | Markdown             | [Markly][markly] (via tree_haver)                                                                   | Smart merge for Markdown (CommonMark via cmark-gfm C)                            |
| [prism-merge][prism-merge]               | Ruby                 | [Prism][prism] (`prism` std lib gem)                                                                | Smart merge for Ruby source files                                                |
| [psych-merge][psych-merge]               | YAML                 | [Psych][psych] (`psych` std lib gem)                                                                | Smart merge for YAML files                                                       |
| [rbs-merge][rbs-merge]                   | RBS                  | [tree-sitter-bash][ts-rbs] (via tree_haver), [RBS][rbs] (`rbs` std lib gem)                         | Smart merge for Ruby type signatures                                             |
| [toml-merge][toml-merge]                 | TOML                 | [Citrus + toml-rb][toml-rb] (default, via tree_haver), [tree-sitter-toml][ts-toml] (via tree_haver) | Smart merge for TOML files                                                       |

**Example implementations** for the gem templating use case:

| Gem | Purpose | Description |
| --- | --- | --- |
| [kettle-dev](https://github.com/kettle-rb/kettle-dev) | Gem Development | Gem templating tool using `*-merge` gems |
| [kettle-jem](https://github.com/kettle-rb/kettle-jem) | Gem Templating | Gem template library with smart merge support |

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
[prism]: https://github.com/ruby/prism
[psych]: https://github.com/ruby/psych
[ts-json]: https://github.com/tree-sitter/tree-sitter-json
[ts-bash]: https://github.com/tree-sitter/tree-sitter-bash
[ts-toml]: https://github.com/tree-sitter-grammars/tree-sitter-toml
[rbs]: https://github.com/ruby/rbs
[toml-rb]: https://github.com/emancu/toml-rb
[markly]: https://github.com/ioquatix/markly
[commonmarker]: https://github.com/gjtorikian/commonmarker
[ruby_tree_sitter]: https://github.com/Faveod/ruby-tree-sitter
[tree_stump]: https://github.com/joker1007/tree_stump
[jtreesitter]: https://central.sonatype.com/artifact/io.github.tree-sitter/jtreesitter


[ts-jsonc]: https://gitlab.com/WhyNotHugo/tree-sitter-jsonc
[dotenv]: https://github.com/bkeepers/dotenv

#### Backend Platform Compatibility

tree\_haver supports multiple parsing backends, but not all backends work on all Ruby platforms:

| Backend | MRI | JRuby | TruffleRuby | Notes |
| --- | :-: | :-: | :-: | --- |
| **MRI** ([ruby\_tree\_sitter](https://github.com/Faveod/ruby-tree-sitter)) | ✅ | ❌ | ❌ | C extension, MRI only |
| **Rust** ([tree\_stump](https://github.com/joker1007/tree_stump)) | ✅ | ❌ | ❌ | Rust extension via magnus/rb-sys, MRI only |
| **FFI** | ✅ | ✅ | ❌ | TruffleRuby's FFI doesn't support `STRUCT_BY_VALUE` |
| **Java** ([jtreesitter](https://central.sonatype.com/artifact/io.github.tree-sitter/jtreesitter)) | ❌ | ✅ | ❌ | JRuby only, requires grammar JARs |
| **Prism** | ✅ | ✅ | ✅ | Ruby parsing, stdlib in Ruby 3.4+ |
| **Psych** | ✅ | ✅ | ✅ | YAML parsing, stdlib |
| **Citrus** | ✅ | ✅ | ✅ | Pure Ruby, no native dependencies |
| **Commonmarker** | ✅ | ❌ | ❓ | Rust extension for Markdown |
| **Markly** | ✅ | ❌ | ❓ | C extension for Markdown |

**Legend**: ✅ = Works, ❌ = Does not work, ❓ = Untested

**Why some backends don't work on certain platforms**:

  - **JRuby**: Runs on the JVM; cannot load native C/Rust extensions (`.so` files)
  - **TruffleRuby**: Has C API emulation via Sulong/LLVM, but it doesn't expose all MRI internals that native extensions require (e.g., `RBasic.flags`, `rb_gc_writebarrier`)
  - **FFI on TruffleRuby**: TruffleRuby's FFI implementation doesn't support returning structs by value, which tree-sitter's C API requires
### Architecture: tree\_haver + ast-merge

The `*-merge` gem family is built on a two-layer architecture:

#### Layer 1: tree\_haver (Parsing Foundation)

[tree\_haver](https://github.com/kettle-rb/tree_haver) provides cross-Ruby parsing capabilities:

  - **Universal Backend Support**: Automatically selects the best parsing backend for your Ruby implementation (MRI, JRuby, TruffleRuby)
  - **10 Backend Options**: MRI C extensions, Rust bindings, FFI, Java (JRuby), language-specific parsers (Prism, Psych, Commonmarker, Markly), and pure Ruby fallback (Citrus)
  - **Unified API**: Write parsing code once, run on any Ruby implementation
  - **Grammar Discovery**: Built-in `GrammarFinder` for platform-aware grammar library discovery
  - **Thread-Safe**: Language registry with thread-safe caching
#### Layer 2: ast-merge (Merge Infrastructure)

Ast::Merge builds on tree\_haver to provide:

  - **Base Classes**: `FreezeNode`, `MergeResult` base classes with unified constructors
  - **Shared Modules**: `FileAnalysisBase`, `FileAnalyzable`, `MergerConfig`, `DebugLogger`
  - **Freeze Block Support**: Configurable marker patterns for multiple comment syntaxes (preserve sections during merge)
  - **Node Typing System**: `NodeTyping` for canonical node type identification across different parsers
  - **Conflict Resolution**: `ConflictResolverBase` with pluggable strategies
  - **Error Classes**: `ParseError`, `TemplateParseError`, `DestinationParseError`
  - **Region Detection**: `RegionDetectorBase`, `FencedCodeBlockDetector` for text-based analysis
  - **RSpec Shared Examples**: Test helpers for implementing new merge gems
### Creating a New Merge Gem

``` ruby
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
        @statistics = { merged_count: 0 }
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
```

### Base Classes Reference

| Base Class | Purpose | Key Methods to Implement |
| --- | --- | --- |
| `SmartMergerBase` | Main merge orchestration | `analysis_class`, `perform_merge` |
| `ConflictResolverBase` | Resolve node conflicts | `resolve_batch` or `resolve_node_pair` |
| `MergeResultBase` | Track merge results | `to_s`, format-specific output |
| `MatchRefinerBase` | Fuzzy node matching | `similarity` |
| `ContentMatchRefiner` | Text content fuzzy matching | Ready to use |
| `FileAnalyzable` | File parsing/analysis | `compute_node_signature` |

### ContentMatchRefiner

`Ast::Merge::ContentMatchRefiner` is a built-in match refiner for fuzzy text content matching using Levenshtein distance. Unlike signature-based matching which requires exact content hashes, this refiner allows matching nodes with similar (but not identical) content.

``` ruby
# Basic usage - match nodes with 70% similarity
refiner = Ast::Merge::ContentMatchRefiner.new(threshold: 0.7)

# Only match specific node types
refiner = Ast::Merge::ContentMatchRefiner.new(
  threshold: 0.6,
  node_types: [:paragraph, :heading]
)

# Custom weights for scoring
refiner = Ast::Merge::ContentMatchRefiner.new(
  threshold: 0.7,
  weights: {
    content: 0.8,   # Levenshtein similarity (default: 0.7)
    length: 0.1,    # Length similarity (default: 0.15)
    position: 0.1   # Position in document (default: 0.15)
  }
)

# Custom content extraction
refiner = Ast::Merge::ContentMatchRefiner.new(
  threshold: 0.7,
  content_extractor: ->(node) { node.text_content.downcase.strip }
)

# Use with a merger
merger = MyFormat::SmartMerger.new(
  template,
  destination,
  preference: :template,
  match_refiner: refiner
)
```

This is particularly useful for:
  - Paragraphs with minor edits (typos, rewording)
  - Headings with slight changes
  - Comments with updated text
  - Any text-based node that may have been slightly modified
### Namespace Reference

The `Ast::Merge` module is organized into several namespaces, each with detailed documentation:

| Namespace | Purpose | Documentation |
| --- | --- | --- |
| `Ast::Merge::Detector` | Region detection and merging | [lib/ast/merge/detector/README.md](lib/ast/merge/detector/README.md) |
| `Ast::Merge::Recipe` | YAML-based merge recipes | [lib/ast/merge/recipe/README.md](lib/ast/merge/recipe/README.md) |
| `Ast::Merge::Comment` | Comment parsing and representation | [lib/ast/merge/comment/README.md](lib/ast/merge/comment/README.md) |
| `Ast::Merge::Text` | Plain text AST parsing | [lib/ast/merge/text/README.md](lib/ast/merge/text/README.md) |
| `Ast::Merge::RSpec` | Shared RSpec examples | [lib/ast/merge/rspec/README.md](lib/ast/merge/rspec/README.md) |

**Key Classes by Namespace:**

  - **Detector**: `Region`, `Base`, `Mergeable`, `FencedCodeBlock`, `YamlFrontmatter`, `TomlFrontmatter`
  - **Recipe**: `Config`, `Runner`, `ScriptLoader`
  - **Comment**: `Line`, `Block`, `Empty`, `Parser`, `Style`
  - **Text**: `SmartMerger`, `FileAnalysis`, `LineNode`, `WordNode`, `Section`
  - **RSpec**: Shared examples and dependency tags for testing `*-merge` implementations
## 💡 Info you can shake a stick at

| Tokens to Remember | [![Gem name](https://img.shields.io/badge/name-ast--merge-3C2D2D.svg?style=square&logo=rubygems&logoColor=red)](https://bestgems.org/gems/ast-merge) [![Gem namespace](https://img.shields.io/badge/namespace-Ast::Merge-3C2D2D.svg?style=square&logo=ruby&logoColor=white)](https://github.com/kettle-rb/ast-merge) |
| --- | --- |
| Works with JRuby | [![JRuby 10.0 Compat](https://img.shields.io/badge/JRuby-current-FBE742?style=for-the-badge&logo=ruby&logoColor=green)](https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml) [![JRuby HEAD Compat](https://img.shields.io/badge/JRuby-HEAD-FBE742?style=for-the-badge&logo=ruby&logoColor=blue)](https://github.com/kettle-rb/ast-merge/actions/workflows/heads.yml) |
| Works with Truffle Ruby | [![Truffle Ruby 23.1 Compat](https://img.shields.io/badge/Truffle_Ruby-23.1-34BCB1?style=for-the-badge&logo=ruby&logoColor=pink)](https://github.com/kettle-rb/ast-merge/actions/workflows/truffle.yml) [![Truffle Ruby 24.1 Compat](https://img.shields.io/badge/Truffle_Ruby-current-34BCB1?style=for-the-badge&logo=ruby&logoColor=green)](https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml) |
| Works with MRI Ruby 3 | [![Ruby 3.2 Compat](https://img.shields.io/badge/Ruby-3.2-CC342D?style=for-the-badge&logo=ruby&logoColor=white)](https://github.com/kettle-rb/ast-merge/actions/workflows/supported.yml) [![Ruby 3.3 Compat](https://img.shields.io/badge/Ruby-3.3-CC342D?style=for-the-badge&logo=ruby&logoColor=white)](https://github.com/kettle-rb/ast-merge/actions/workflows/supported.yml) [![Ruby 3.4 Compat](https://img.shields.io/badge/Ruby-current-CC342D?style=for-the-badge&logo=ruby&logoColor=green)](https://github.com/kettle-rb/ast-merge/actions/workflows/current.yml) [![Ruby HEAD Compat](https://img.shields.io/badge/Ruby-HEAD-CC342D?style=for-the-badge&logo=ruby&logoColor=blue)](https://github.com/kettle-rb/ast-merge/actions/workflows/heads.yml) |
| Support & Community | [![Join Me on Daily.dev's RubyFriends](https://img.shields.io/badge/daily.dev-%F0%9F%92%8E_Ruby_Friends-0A0A0A?style=for-the-badge&logo=dailydotdev&logoColor=white)](https://app.daily.dev/squads/rubyfriends) [![Live Chat on Discord](https://img.shields.io/discord/1373797679469170758?style=for-the-badge&logo=discord)](https://discord.gg/3qme4XHNKN) [![Get help from me on Upwork](https://img.shields.io/badge/UpWork-13544E?style=for-the-badge&logo=Upwork&logoColor=white)](https://www.upwork.com/freelancers/~014942e9b056abdf86?mp_source=share) [![Get help from me on Codementor](https://img.shields.io/badge/CodeMentor-Get_Help-1abc9c?style=for-the-badge&logo=CodeMentor&logoColor=white)](https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github) |
| Source | [![Source on GitLab.com](https://img.shields.io/badge/GitLab-FBA326?style=for-the-badge&logo=Gitlab&logoColor=orange)](https://gitlab.com/kettle-rb/ast-merge/) [![Source on CodeBerg.org](https://img.shields.io/badge/CodeBerg-4893CC?style=for-the-badge&logo=CodeBerg&logoColor=blue)](https://codeberg.org/kettle-rb/ast-merge) [![Source on Github.com](https://img.shields.io/badge/GitHub-238636?style=for-the-badge&logo=Github&logoColor=green)](https://github.com/kettle-rb/ast-merge) [![The best SHA: dQw4w9WgXcQ\!](https://img.shields.io/badge/KLOC-3.271-FFDD67.svg?style=for-the-badge&logo=YouTube&logoColor=blue)](https://www.youtube.com/watch?v=dQw4w9WgXcQ) |
| Documentation | [![Current release on RubyDoc.info](https://img.shields.io/badge/RubyDoc-Current_Release-943CD2?style=for-the-badge&logo=readthedocs&logoColor=white)](http://rubydoc.info/gems/ast-merge) [![YARD on Galtzo.com](https://img.shields.io/badge/YARD_on_Galtzo.com-HEAD-943CD2?style=for-the-badge&logo=readthedocs&logoColor=white)](https://ast-merge.galtzo.com) [![Maintainer Blog](https://img.shields.io/badge/blog-railsbling-0093D0.svg?style=for-the-badge&logo=rubyonrails&logoColor=orange)](http://www.railsbling.com/tags/ast-merge) [![GitLab Wiki](https://img.shields.io/badge/wiki-examples-943CD2.svg?style=for-the-badge&logo=gitlab&logoColor=white)](https://gitlab.com/kettle-rb/ast-merge/-/wikis/home) [![GitHub Wiki](https://img.shields.io/badge/wiki-examples-943CD2.svg?style=for-the-badge&logo=github&logoColor=white)](https://github.com/kettle-rb/ast-merge/wiki) |
| Compliance | [![License: MIT](https://img.shields.io/badge/License-MIT-259D6C.svg)](https://opensource.org/licenses/MIT) [![Compatible with Apache Software Projects: Verified by SkyWalking Eyes](https://img.shields.io/badge/Apache_Compatible:_Category_A-%E2%9C%93-259D6C.svg?style=flat&logo=Apache)](https://dev.to/galtzo/how-to-check-license-compatibility-41h0) [![📄ilo-declaration-img](https://img.shields.io/badge/ILO_Fundamental_Principles-✓-259D6C.svg?style=flat)](https://www.ilo.org/declaration/lang--en/index.htm) [![Security Policy](https://img.shields.io/badge/security-policy-259D6C.svg?style=flat)](SECURITY.md) [![Contributor Covenant 2.1](https://img.shields.io/badge/Contributor_Covenant-2.1-259D6C.svg)](CODE_OF_CONDUCT.md) [![SemVer 2.0.0](https://img.shields.io/badge/semver-2.0.0-259D6C.svg?style=flat)](https://semver.org/spec/v2.0.0.html) |
| Style | [![Enforced Code Style Linter](https://img.shields.io/badge/code_style_&_linting-rubocop--lts-34495e.svg?plastic&logo=ruby&logoColor=white)](https://github.com/rubocop-lts/rubocop-lts) [![Keep-A-Changelog 1.0.0](https://img.shields.io/badge/keep--a--changelog-1.0.0-34495e.svg?style=flat)](https://keepachangelog.com/en/1.0.0/) [![Gitmoji Commits](https://img.shields.io/badge/gitmoji_commits-%20%F0%9F%98%9C%20%F0%9F%98%8D-34495e.svg?style=flat-square)](https://gitmoji.dev) [![Compatibility appraised by: appraisal2](https://img.shields.io/badge/appraised_by-appraisal2-34495e.svg?plastic&logo=ruby&logoColor=white)](https://github.com/appraisal-rb/appraisal2) |
| Maintainer 🎖️ | [![Follow Me on LinkedIn](https://img.shields.io/badge/PeterBoling-LinkedIn-0B66C2?style=flat&logo=newjapanprowrestling)](http://www.linkedin.com/in/peterboling) [![Follow Me on Ruby.Social](https://img.shields.io/mastodon/follow/109447111526622197?domain=https://ruby.social&style=flat&logo=mastodon&label=Ruby%20@galtzo)](https://ruby.social/@galtzo) [![Follow Me on Bluesky](https://img.shields.io/badge/@galtzo.com-0285FF?style=flat&logo=bluesky&logoColor=white)](https://bsky.app/profile/galtzo.com) [![Contact Maintainer](https://img.shields.io/badge/Contact-Maintainer-0093D0.svg?style=flat&logo=rubyonrails&logoColor=red)](http://www.railsbling.com/contact) [![My technical writing](https://img.shields.io/badge/dev.to-0A0A0A?style=flat&logo=devdotto&logoColor=white)](https://dev.to/galtzo) |
| `...` 💖 | [![Find Me on WellFound:](https://img.shields.io/badge/peter--boling-orange?style=flat&logo=wellfound)](https://wellfound.com/u/peter-boling) [![Find Me on CrunchBase](https://img.shields.io/badge/peter--boling-purple?style=flat&logo=crunchbase)](https://www.crunchbase.com/person/peter-boling) [![My LinkTree](https://img.shields.io/badge/galtzo-purple?style=flat&logo=linktree)](https://linktr.ee/galtzo) [![More About Me](https://img.shields.io/badge/about.me-0A0A0A?style=flat&logo=aboutme&logoColor=white)](https://about.me/peter.boling) [🧊](https://codeberg.org/pboling) [🐙](https://github.org/pboling)  [🛖](https://sr.ht/~galtzo/) [🧪](https://gitlab.com/pboling) |

### Compatibility

Compatible with MRI Ruby 3.2.0+, and concordant releases of JRuby, and TruffleRuby.

| 🚚 *Amazing* test matrix was brought to you by | 🔎 appraisal2 🔎 and the color 💚 green 💚 |
| --- | --- |
| 👟 Check it out\! | ✨ [github.com/appraisal-rb/appraisal2](https://github.com/appraisal-rb/appraisal2) ✨ |

### Federated DVCS

<details markdown="1">
  <summary>Find this repo on federated forges (Coming soon!)</summary>

| Federated [DVCS](https://railsbling.com/posts/dvcs/put_the_d_in_dvcs/) Repository | Status | Issues | PRs | Wiki | CI | Discussions |
| --- | --- | --- | --- | --- | --- | --- |
| 🧪 [kettle-rb/ast-merge on GitLab](https://gitlab.com/kettle-rb/ast-merge/) | The Truth | [💚](https://gitlab.com/kettle-rb/ast-merge/-/issues) | [💚](https://gitlab.com/kettle-rb/ast-merge/-/merge_requests) | [💚](https://gitlab.com/kettle-rb/ast-merge/-/wikis/home) | 🐭 Tiny Matrix | ➖ |
| 🧊 [kettle-rb/ast-merge on CodeBerg](https://codeberg.org/kettle-rb/ast-merge) | An Ethical Mirror ([Donate](https://donate.codeberg.org/)) | [💚](https://codeberg.org/kettle-rb/ast-merge/issues) | [💚](https://codeberg.org/kettle-rb/ast-merge/pulls) | ➖ | ⭕️ No Matrix | ➖ |
| 🐙 [kettle-rb/ast-merge on GitHub](https://github.com/kettle-rb/ast-merge) | Another Mirror | [💚](https://github.com/kettle-rb/ast-merge/issues) | [💚](https://github.com/kettle-rb/ast-merge/pulls) | [💚](https://github.com/kettle-rb/ast-merge/wiki) | 💯 Full Matrix | [💚](https://github.com/kettle-rb/ast-merge/discussions) |
| 🎮️ [Discord Server](https://discord.gg/3qme4XHNKN) | [![Live Chat on Discord](https://img.shields.io/discord/1373797679469170758?style=for-the-badge&logo=discord)](https://discord.gg/3qme4XHNKN) | [Let's](https://discord.gg/3qme4XHNKN) | [talk](https://discord.gg/3qme4XHNKN) | [about](https://discord.gg/3qme4XHNKN) | [this](https://discord.gg/3qme4XHNKN) | [library\!](https://discord.gg/3qme4XHNKN) |

</details>

[gh-discussions]: https://github.com/kettle-rb/ast-merge/discussions

### Enterprise Support [![Tidelift](https://tidelift.com/badges/package/rubygems/ast-merge)](https://tidelift.com/subscription/pkg/rubygems-ast-merge?utm_source=rubygems-ast-merge&utm_medium=referral&utm_campaign=readme)

Available as part of the Tidelift Subscription.

<details markdown="1">
  <summary>Need enterprise-level guarantees?</summary>

The maintainers of this and thousands of other packages are working with Tidelift to deliver commercial support and maintenance for the open source packages you use to build your applications. Save time, reduce risk, and improve code health, while paying the maintainers of the exact packages you use.

[![Get help from me on Tidelift](https://img.shields.io/badge/Tidelift_and_Sonar-Enterprise_Support-FD3456?style=for-the-badge&logo=sonar&logoColor=white)](https://tidelift.com/subscription/pkg/rubygems-ast-merge?utm_source=rubygems-ast-merge&utm_medium=referral&utm_campaign=readme)

  - 💡Subscribe for support guarantees covering *all* your FLOSS dependencies

  - 💡Tidelift is part of [Sonar](https://blog.tidelift.com/tidelift-joins-sonar)

  - 💡Tidelift pays maintainers to maintain the software you depend on\!<br/>📊`@`Pointy Haired Boss: An [enterprise support](https://tidelift.com/subscription/pkg/rubygems-ast-merge?utm_source=rubygems-ast-merge&utm_medium=referral&utm_campaign=readme) subscription is "[never gonna let you down](https://www.youtube.com/watch?v=dQw4w9WgXcQ)", and *supports* open source maintainers
    Alternatively:

  - [![Live Chat on Discord](https://img.shields.io/discord/1373797679469170758?style=for-the-badge&logo=discord)](https://discord.gg/3qme4XHNKN)

  - [![Get help from me on Upwork](https://img.shields.io/badge/UpWork-13544E?style=for-the-badge&logo=Upwork&logoColor=white)](https://www.upwork.com/freelancers/~014942e9b056abdf86?mp_source=share)

  - [![Get help from me on Codementor](https://img.shields.io/badge/CodeMentor-Get_Help-1abc9c?style=for-the-badge&logo=CodeMentor&logoColor=white)](https://www.codementor.io/peterboling?utm_source=github&utm_medium=button&utm_term=peterboling&utm_campaign=github)
</details>

## ✨ Installation

Install the gem and add to the application's Gemfile by executing:

``` console
bundle add ast-merge
```

If bundler is not being used to manage dependencies, install the gem by executing:

``` console
gem install ast-merge
```

### 🔒 Secure Installation

<details markdown="1">
  <summary>For Medium or High Security Installations</summary>

This gem is cryptographically signed, and has verifiable [SHA-256 and SHA-512](https://gitlab.com/kettle-rb/ast-merge/-/tree/main/checksums) checksums by
[stone\_checksums](https://github.com/galtzo-floss/stone_checksums). Be sure the gem you install hasn’t been tampered with
by following the instructions below.

Add my public key (if you haven’t already, expires 2045-04-29) as a trusted certificate:

``` console
gem cert --add <(curl -Ls https://raw.github.com/galtzo-floss/certs/main/pboling.pem)
```

You only need to do that once.  Then proceed to install with:

``` console
gem install ast-merge -P HighSecurity
```

The `HighSecurity` trust profile will verify signed gems, and not allow the installation of unsigned dependencies.

If you want to up your security game full-time:

``` console
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

``` ruby
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

``` ruby
# Only add nodes with gem_family signatures
merger = SomeFormat::Merge::SmartMerger.new(
  template,
  destination,
  add_template_only_nodes: ->(node, entry) {
    sig = entry[:signature]
    sig.is_a?(Array) && sig.first == :gem_family
  }
)

# Only add link definitions that match a pattern
merger = Markly::Merge::SmartMerger.new(
  template,
  destination,
  add_template_only_nodes: ->(node, entry) {
    entry[:template_node].type == :link_definition &&
      entry[:signature]&.last&.include?("gem")
  }
)
```

The `entry` hash contains:
  - `:template_node` - The node being considered for addition
  - `:signature` - The node's signature (Array or other value)
  - `:template_index` - Index in the template statements
  - `:dest_index` - Always `nil` for template-only nodes
## 🔧 Basic Usage

### Using Shared Examples in Tests

``` ruby
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
<!-- end list -->
``` ruby
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

| Pattern Type | Start Marker | End Marker | Languages |
| --- | --- | --- | --- |
| `:hash_comment` | `# token:freeze` | `# token:unfreeze` | Ruby, Python, YAML, Bash, Shell |
| `:html_comment` | `<!-- token:freeze -->` | `<!-- token:unfreeze -->` | HTML, XML, Markdown |
| `:c_style_line` | `// token:freeze` | `// token:unfreeze` | C (C99+), C++, JavaScript, TypeScript, Java, C\#, Go, Rust, Swift, Kotlin, PHP, JSONC |
| `:c_style_block` | `/* token:freeze */` | `/* token:unfreeze */` | C, C++, JavaScript, TypeScript, Java, C\#, Go, Rust, Swift, Kotlin, PHP, CSS |

| 📍 NOTE |
| --- |
| CSS only supports block comments (`/* */`), not line comments. |
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
<!-- end list -->
``` ruby
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

``` ruby
# Wrap a node with a custom merge_type
wrapped = Ast::Merge::NodeTyping::Wrapper.new(original_node, :special_config)
wrapped.merge_type  # => :special_config
wrapped.class       # => Ast::Merge::NodeTyping::Wrapper
wrapped.location    # => delegates to original_node.location
```

#### NodeTyping Utility Methods

``` ruby
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

``` ruby
# Simple Hash preference (functionally equivalent to preference: :destination)
merger = MyMerger.new(
  template_content,
  dest_content,
  preference: {default: :destination},
)
```

### MergerConfig Factory Methods

The `MergerConfig` class provides factory methods that support all options:

``` ruby
# Create config preferring destination
config = Ast::Merge::MergerConfig.destination_wins(
  freeze_token: "my-freeze",
  : my_generator,
  node_typing: my_typing,
)

# Create config preferring template
config = Ast::Merge::MergerConfig.template_wins(
  freeze_token: "my-freeze",
  signature_generator: my_generator,
  node_typing: my_typing,
)
```

## 🦷 FLOSS Funding

While kettle-rb tools are free software and will always be, the project would benefit immensely from some funding.
Raising a monthly budget of... "dollars" would make the project more sustainable.

We welcome both individual and corporate sponsors\! We also offer a
wide array of funding channels to account for your preferences
(although currently [Open Collective](https://opencollective.com/kettle-rb) is our preferred funding platform).

**If you're working in a company that's making significant use of kettle-rb tools we'd
appreciate it if you suggest to your company to become a kettle-rb sponsor.**

You can support the development of kettle-rb tools via
[GitHub Sponsors](https://github.com/sponsors/pboling),
[Liberapay](https://liberapay.com/pboling/donate),
[PayPal](https://www.paypal.com/paypalme/peterboling),
[Open Collective](https://opencollective.com/kettle-rb)
and [Tidelift](https://tidelift.com/subscription/pkg/rubygems-ast-merge?utm_source=rubygems-ast-merge&utm_medium=referral&utm_campaign=readme).

| 📍 NOTE |
| --- |
| If doing a sponsorship in the form of donation is problematic for your company <br/> from an accounting standpoint, we'd recommend the use of Tidelift, <br/> where you can get a support-like subscription instead. |

### Open Collective for Individuals

Support us with a monthly donation and help us continue our activities. \[[Become a backer](https://opencollective.com/kettle-rb#backer)\]

NOTE: [kettle-readme-backers](https://github.com/kettle-rb/ast-merge/blob/main/exe/kettle-readme-backers) updates this list every day, automatically.

<!-- OPENCOLLECTIVE-INDIVIDUALS:START -->
No backers yet. Be the first\!
<!-- OPENCOLLECTIVE-INDIVIDUALS:END -->

### Open Collective for Organizations

Become a sponsor and get your logo on our README on GitHub with a link to your site. \[[Become a sponsor](https://opencollective.com/kettle-rb#sponsor)\]

NOTE: [kettle-readme-backers](https://github.com/kettle-rb/ast-merge/blob/main/exe/kettle-readme-backers) updates this list every day, automatically.

<!-- OPENCOLLECTIVE-ORGANIZATIONS:START -->
No sponsors yet. Be the first\!
<!-- OPENCOLLECTIVE-ORGANIZATIONS:END -->

[kettle-readme-backers]: https://github.com/kettle-rb/ast-merge/blob/main/exe/kettle-readme-backers

### Another way to support open-source

I’m driven by a passion to foster a thriving open-source community – a space where people can tackle complex problems, no matter how small.  Revitalizing libraries that have fallen into disrepair, and building new libraries focused on solving real-world challenges, are my passions.  I was recently affected by layoffs, and the tech jobs market is unwelcoming. I’m reaching out here because your support would significantly aid my efforts to provide for my family, and my farm (11 🐔 chickens, 2 🐶 dogs, 3 🐰 rabbits, 8 🐈‍ cats).

If you work at a company that uses my work, please encourage them to support me as a corporate sponsor. My work on gems you use might show up in `bundle fund`.

I’m developing a new library, [floss\_funding](https://github.com/galtzo-floss/floss_funding), designed to empower open-source developers like myself to get paid for the work we do, in a sustainable way. Please give it a look.

**[Floss-Funding.dev](https://floss-funding.dev): 👉️ No network calls. 👉️ No tracking. 👉️ No oversight. 👉️ Minimal crypto hashing. 💡 Easily disabled nags**

[![OpenCollective Backers](https://opencollective.com/kettle-rb/backers/badge.svg?style=flat)](https://opencollective.com/kettle-rb#backer) [![OpenCollective Sponsors](https://opencollective.com/kettle-rb/sponsors/badge.svg?style=flat)](https://opencollective.com/kettle-rb#sponsor) [![Sponsor Me on Github](https://img.shields.io/badge/Sponsor_Me!-pboling.svg?style=social&logo=github)](https://github.com/sponsors/pboling) [![Liberapay Goal Progress](https://img.shields.io/liberapay/goal/pboling.svg?logo=liberapay&color=a51611&style=flat)](https://liberapay.com/pboling/donate) [![Donate on PayPal](https://img.shields.io/badge/donate-paypal-a51611.svg?style=flat&logo=paypal)](https://www.paypal.com/paypalme/peterboling) [![Buy me a coffee](https://img.shields.io/badge/buy_me_a_coffee-%E2%9C%93-a51611.svg?style=flat)](https://www.buymeacoffee.com/pboling) [![Donate on Polar](https://img.shields.io/badge/polar-donate-a51611.svg?style=flat)](https://polar.sh/pboling) [![Donate to my FLOSS efforts at ko-fi.com](https://img.shields.io/badge/ko--fi-%E2%9C%93-a51611.svg?style=flat)](https://ko-fi.com/O5O86SNP4) [![Donate to my FLOSS efforts using Patreon](https://img.shields.io/badge/patreon-donate-a51611.svg?style=flat)](https://patreon.com/galtzo)

## 🔐 Security

See [SECURITY.md](SECURITY.md).

## 🤝 Contributing

If you need some ideas of where to help, you could work on adding more code coverage,
or if it is already 💯 (see [below](#code-coverage)) check [reek](REEK), [issues](https://github.com/kettle-rb/ast-merge/issues), or [PRs](https://github.com/kettle-rb/ast-merge/pulls),
or use the gem and think about how it could be better.

We [![Keep A Changelog](https://img.shields.io/badge/keep--a--changelog-1.0.0-34495e.svg?style=flat)](https://keepachangelog.com/en/1.0.0/) so if you make changes, remember to update it.

See [CONTRIBUTING.md](CONTRIBUTING.md) for more detailed instructions.

### 🚀 Release Instructions

See [CONTRIBUTING.md](CONTRIBUTING.md).

### Code Coverage

[![Coverage Graph](https://codecov.io/gh/kettle-rb/ast-merge/graphs/tree.svg)](https://codecov.io/gh/kettle-rb/ast-merge)

[![Coveralls Test Coverage](https://coveralls.io/repos/github/kettle-rb/ast-merge/badge.svg?branch=main)](https://coveralls.io/github/kettle-rb/ast-merge?branch=main)

[![QLTY Test Coverage](https://qlty.sh/gh/kettle-rb/projects/ast-merge/coverage.svg)](https://qlty.sh/gh/kettle-rb/projects/ast-merge/metrics/code?sort=coverageRating)

### 🪇 Code of Conduct

Everyone interacting with this project's codebases, issue trackers,
chat rooms and mailing lists agrees to follow the [![Contributor Covenant 2.1](https://img.shields.io/badge/Contributor_Covenant-2.1-259D6C.svg)](CODE_OF_CONDUCT.md).

## 🌈 Contributors

[![Contributors](https://contrib.rocks/image?repo=kettle-rb/ast-merge)](https://github.com/kettle-rb/ast-merge/graphs/contributors)

Made with [contributors-img](https://contrib.rocks).

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

This Library adheres to [![Semantic Versioning 2.0.0](https://img.shields.io/badge/semver-2.0.0-259D6C.svg?style=flat)](https://semver.org/spec/v2.0.0.html).
Violations of this scheme should be reported as bugs.
Specifically, if a minor or patch version is released that breaks backward compatibility,
a new version should be immediately released that restores compatibility.
Breaking changes to the public API will only be introduced with new major versions.

> dropping support for a platform is both obviously and objectively a breaking change <br/>
> —Jordan Harband ([@ljharb](https://github.com/ljharb), maintainer of SemVer) [in SemVer issue 716](https://github.com/semver/semver/issues/716#issuecomment-869336139)

I understand that policy doesn't work universally ("exceptions to every rule\!"),
but it is the policy here.
As such, in many cases it is good to specify a dependency on this library using
the [Pessimistic Version Constraint](http://guides.rubygems.org/patterns/#pessimistic-version-constraint) with two digits of precision.

For example:

``` ruby
spec.add_dependency("ast-merge", "~> 2.0", ">= 2.0.1")                # ruby >= 3.2.0
```

<details markdown="1">
<summary>📌 Is "Platform Support" part of the public API? More details inside.</summary>

SemVer should, IMO, but doesn't explicitly, say that dropping support for specific Platforms
is a *breaking change* to an API, and for that reason the bike shedding is endless.

To get a better understanding of how SemVer is intended to work over a project's lifetime,
read this article from the creator of SemVer:

  - ["Major Version Numbers are Not Sacred"](https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html)
</details>

See [CHANGELOG.md](CHANGELOG.md) for a list of releases.

## 📄 License

The gem is available as open source under the terms of
the [MIT License](LICENSE.txt) [![License: MIT](https://img.shields.io/badge/License-MIT-259D6C.svg)](https://opensource.org/licenses/MIT).
See [LICENSE.txt](LICENSE.txt) for the official [Copyright Notice](https://opensource.stackexchange.com/questions/5778/why-do-licenses-such-as-the-mit-license-specify-a-single-year).

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

[![Live Chat on Discord](https://img.shields.io/discord/1373797679469170758?style=for-the-badge&logo=discord)](https://discord.gg/3qme4XHNKN)

To say "thanks\!" ☝️ Join the Discord or 👇️ send money.

[![Sponsor kettle-rb/ast-merge on Open Source Collective](https://img.shields.io/opencollective/all/kettle-rb?style=for-the-badge)](https://opencollective.com/kettle-rb) 💌 [![Sponsor me on GitHub Sponsors](https://img.shields.io/badge/Sponsor_Me!-pboling-blue?style=for-the-badge&logo=github)](https://github.com/sponsors/pboling) 💌 [![Sponsor me on Liberapay](https://img.shields.io/liberapay/goal/pboling.svg?style=for-the-badge&logo=liberapay&color=a51611)](https://liberapay.com/pboling/donate) 💌 [![Donate on PayPal](https://img.shields.io/badge/donate-paypal-a51611.svg?style=for-the-badge&logo=paypal&color=0A0A0A)](https://www.paypal.com/paypalme/peterboling)

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
[🧮kloc-img]: https://img.shields.io/badge/KLOC-2.716-FFDD67.svg?style=for-the-badge&logo=YouTube&logoColor=blue
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

[ts-jsonc]: https://gitlab.com/WhyNotHugo/tree-sitter-jsonc
[dotenv]: https://github.com/bkeepers/dotenv
