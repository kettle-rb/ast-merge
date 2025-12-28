### The `*-merge` Gem Family

The `*-merge` gem family provides intelligent, AST-based merging for various file formats. At the foundation is [tree_haver][tree_haver], which provides a unified cross-Ruby parsing API that works seamlessly across MRI, JRuby, and TruffleRuby.

| Gem                                      | Format   | Parser Backend(s)                                                                                   | Description                                                                      |
|------------------------------------------|----------|-----------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| [tree_haver][tree_haver]                 | Multi    | MRI C, Rust, FFI, Java, Prism, Psych, Commonmarker, Markly, Citrus                                  | **Foundation**: Cross-Ruby adapter for parsing libraries (like Faraday for HTTP) |
| [ast-merge][ast-merge]                   | Text     | internal                                                                                            | **Infrastructure**: Shared base classes and merge logic for all `*-merge` gems   |
| [prism-merge][prism-merge]               | Ruby     | [Prism][prism]                                                                                      | Smart merge for Ruby source files                                                |
| [psych-merge][psych-merge]               | YAML     | [Psych][psych]                                                                                      | Smart merge for YAML files                                                       |
| [json-merge][json-merge]                 | JSON     | [tree-sitter-json][ts-json] (via tree_haver)                                                        | Smart merge for JSON files                                                       |
| [jsonc-merge][jsonc-merge]               | JSONC    | [tree-sitter-jsonc][ts-jsonc] (via tree_haver)                                                      | ⚠️ Proof of concept; Smart merge for JSON with Comments                          |
| [bash-merge][bash-merge]                 | Bash     | [tree-sitter-bash][ts-bash] (via tree_haver)                                                        | Smart merge for Bash scripts                                                     |
| [rbs-merge][rbs-merge]                   | RBS      | [RBS][rbs]                                                                                          | Smart merge for Ruby type signatures                                             |
| [dotenv-merge][dotenv-merge]             | Dotenv   | internal                                                                                            | Smart merge for `.env` files                                                     |
| [toml-merge][toml-merge]                 | TOML     | [Citrus + toml-rb][toml-rb] (default, via tree_haver), [tree-sitter-toml][ts-toml] (via tree_haver) | Smart merge for TOML files                                                       |
| [markdown-merge][markdown-merge]         | Markdown | [Commonmarker][commonmarker] / [Markly][markly] (via tree_haver)                                    | **Foundation**: Shared base for Markdown mergers with inner code block merging   |
| [markly-merge][markly-merge]             | Markdown | [Markly][markly] (via tree_haver)                                                                   | Smart merge for Markdown (CommonMark via cmark-gfm C)                            |
| [commonmarker-merge][commonmarker-merge] | Markdown | [Commonmarker][commonmarker] (via tree_haver)                                                       | Smart merge for Markdown (CommonMark via comrak Rust)                            |

**Example implementations** for the gem templating use case:

| Gem | Purpose | Description |
|-----|---------|-------------|
| [kettle-dev][kettle-dev] | Gem Development | Gem templating tool using `*-merge` gems |
| [kettle-jem][kettle-jem] | Gem Templating | Gem template library with smart merge support |

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
[ts-jsonc]: https://gitlab.com/WhyNotHugo/tree-sitter-jsonc
[ts-bash]: https://github.com/tree-sitter/tree-sitter-bash
[ts-toml]: https://github.com/tree-sitter-grammars/tree-sitter-toml
[dotenv]: https://github.com/bkeepers/dotenv
[rbs]: https://github.com/ruby/rbs
[toml-rb]: https://github.com/emancu/toml-rb
[markly]: https://github.com/ioquatix/markly
[commonmarker]: https://github.com/gjtorikian/commonmarker

