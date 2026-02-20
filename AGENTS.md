# AGENTS.md - ast-merge Development Guide

## 🎯 Project Overview

`ast-merge` is a **shared infrastructure library for the `*-merge` gem family**. It provides base classes, modules, and RSpec shared examples for building intelligent file mergers using AST analysis. It powers `prism-merge`, `psych-merge`, `json-merge`, `markly-merge`, and other format-specific merge gems.

**Core Philosophy**: Write once, run anywhere. Define the merge protocol once in `ast-merge`; implement it in each `*-merge` gem for a specific file format.

**Repository**: https://github.com/kettle-rb/ast-merge
**Current Version**: 4.0.5
**Required Ruby**: >= 3.2.0 (currently developed against Ruby 4.0.1)

## 🏗️ Architecture: The Base Library Pattern

### What ast-merge Provides

- **`Ast::Merge::SmartMergerBase`** – Abstract base class for all format-specific `SmartMerger` implementations
- **`Ast::Merge::FileAnalyzable`** – Mixin for file analysis classes; provides freeze block detection, signature generation, and line access
- **`Ast::Merge::AstNode`** – Base class for synthetic AST nodes (backed by `TreeHaver::Base::Node`)
- **`Ast::Merge::MergeResultBase`** – Base class for merge result objects
- **`Ast::Merge::MergerConfig`** – Configuration object encapsulating merge options
- **`Ast::Merge::FreezeNodeBase`** / **`Ast::Merge::Freezable`** – Freeze block support
- **`Ast::Merge::PartialTemplateMergerBase`** – Base for section-level partial merges
- **`Ast::Merge::SectionTyping`** – AST-aware section classification
- **`Ast::Merge::NodeTyping`** – Per-node-type preference overrides
- **`Ast::Merge::Navigable`** – Injection point finding for partial merges
- **`Ast::Merge::Recipe`** – YAML-driven merge recipe runner (`ast-merge-recipe` executable)
- **`Ast::Merge::Text::SmartMerger`** – Concrete line-based text merger (included in this gem)
- **`Ast::Merge::Comment::*`** – Generic, language-agnostic comment classes
- **`Ast::Merge::Detector::*`** – Content detectors (fenced code blocks, YAML/TOML frontmatter, etc.)
- **`Ast::Merge::RSpec`** – Full RSpec support infrastructure for all `*-merge` gems

### Key Dependencies

| Gem | Role |
|-----|------|
| `tree_haver` (~> 5.0) | Unified AST parsing adapter; provides `TreeHaver::Base::Node` and backend tags |
| `version_gem` (~> 1.1) | Version management |

### Vendor Directory

**IMPORTANT**: Nothing in `vendor/` is part of this project. The `vendor/` directory is used for local development only and is **not committed to the repository** and **does not exist in CI**. All vendor gems must be loaded via their published gem versions or git sources in `Gemfile.lock`.

## 📁 Project Structure

```
lib/ast/merge/
├── ast_node.rb                    # Base class for synthetic nodes (TreeHaver::Base::Node subclass)
├── comment/                       # Generic comment classes (line, block, empty, style, parser)
├── conflict_resolver_base.rb      # Abstract conflict resolver
├── content_match_refiner.rb       # Fuzzy match refiner
├── debug_logger.rb                # Logging mixin
├── detector/                      # Content detectors (fenced_code_block, frontmatter, etc.)
├── diff_mapper_base.rb            # Diff/alignment base
├── emitter_base.rb                # Source emitter base
├── file_analyzable.rb             # Mixin for FileAnalysis classes
├── freezable.rb                   # Freeze node mixin
├── freeze_node_base.rb            # Base for freeze block nodes
├── match_refiner_base.rb          # Abstract match refiner
├── match_score_base.rb            # Match scoring base
├── merge_result_base.rb           # Base for merge result objects
├── merger_config.rb               # Merge options configuration
├── navigable/                     # Injection point, statement, finder
├── node_typing/                   # Per-node-type preferences (wrapper, frozen_wrapper, normalizer)
├── partial_template_merger_base.rb # Base for partial/section merges
├── recipe/                        # YAML recipe runner (config, preset, runner, script_loader)
├── rspec/                         # Full RSpec support infrastructure (see below)
├── section_typing.rb              # AST-aware section classification
├── smart_merger_base.rb           # Abstract SmartMerger base class
├── text/                          # Concrete line-based text merger
│   ├── smart_merger.rb
│   ├── file_analysis.rb
│   ├── conflict_resolver.rb
│   ├── merge_result.rb
│   ├── section.rb
│   ├── section_splitter.rb
│   ├── line_node.rb
│   └── word_node.rb
└── version.rb

exe/
├── ast-merge-recipe               # Executable for running YAML merge recipes
└── ast-merge-diff                 # Executable for merge diffs
```

## ⚠️ AI Agent Terminal Limitations

### Terminal Output Is Not Visible

**CRITICAL**: AI agents using `run_in_terminal` almost never see the command output. The terminal tool sends commands to a persistent Copilot terminal, but output is frequently lost or invisible to the agent.

**Workaround**: Always redirect output to a file in the project's local `tmp/` directory, then read it back:

```bash
bundle exec rspec spec/some_spec.rb > tmp/test_output.txt 2>&1
```
Then use `read_file` to see `tmp/test_output.txt`.

**NEVER** use `/tmp` or other system directories — always use the project's own `tmp/` directory.

### direnv Requires Separate `cd` Command

**CRITICAL**: The project uses `direnv` to load environment variables from `.envrc`. When you `cd` into the project directory, `direnv` initializes **after** the shell prompt returns. If you chain `cd` with other commands via `&&`, the subsequent commands run **before** `direnv` has loaded the environment.

✅ **CORRECT** — Run `cd` alone, then run commands separately:
```bash
cd /home/pboling/src/kettle-rb/ast-merge
```
```bash
bundle exec rspec
```

❌ **WRONG** — Never chain `cd` with `&&`:
```bash
cd /home/pboling/src/kettle-rb/ast-merge && bundle exec rspec
```

## 🔧 Development Workflows

### Running Tests

```bash
# Full suite (required for coverage thresholds)
bundle exec rspec

# Single file (disable coverage threshold check)
K_SOUP_COV_MIN_HARD=false bundle exec rspec spec/ast/merge/text/smart_merger_spec.rb
```

**Note**: Always run commands in the project root (`/home/pboling/src/kettle-rb/ast-merge`). Allow `direnv` to load environment variables first by doing a plain `cd` before running commands.

For AI agents, redirect output to a file:
```bash
cd /home/pboling/src/kettle-rb/ast-merge
```
```bash
bundle exec rspec spec/ast/merge/smart_merger_base_spec.rb > tmp/test_output.txt 2>&1
```

### Coverage Reports

```bash
cd /home/pboling/src/kettle-rb/ast-merge
bin/rake coverage && bin/kettle-soup-cover -d
```

This runs tests with coverage instrumentation and generates reports in the `coverage/` directory.

**Key ENV variables** (set in `.envrc`, loaded via `direnv allow`):
- `K_SOUP_COV_DO=true` – Enable coverage (default in `.envrc`)
- `K_SOUP_COV_MIN_LINE=91` – Line coverage threshold
- `K_SOUP_COV_MIN_BRANCH=81` – Branch coverage threshold
- `K_SOUP_COV_MIN_HARD=true` – Fail if thresholds not met
- `K_SOUP_COV_FORMATTERS="html,xml,rcov,lcov,json,tty"` – Output formats

**Never** review HTML reports – use JSON (preferred), XML, LCOV, or the `kettle-soup-cover -d` TTY output.

### Code Quality

```bash
bundle exec rake reek
bundle exec rake rubocop_gradual
```

### Prepare and Release

```bash
kettle-changelog && kettle-release
```

## 📝 Project Conventions

### API Conventions

#### SmartMergerBase API
- `merge` – Returns a **String** (the merged content)
- `merge_result` – Returns a **MergeResult** object
- `to_s` on MergeResult returns the merged content as a string
- `content_string` is **legacy** – use `to_s` instead

#### Forward Compatibility with `**options`

**CRITICAL DESIGN PRINCIPLE**: All constructors and public API methods that accept keyword arguments MUST include `**options` as the final parameter.

✅ **CORRECT**:
```ruby
def initialize(source, freeze_token: DEFAULT, signature_generator: nil, **options)
  @source = source
  @freeze_token = freeze_token
  @signature_generator = signature_generator
  # **options captures future parameters for forward compatibility
end
```

❌ **WRONG**:
```ruby
def initialize(source, freeze_token: DEFAULT, signature_generator: nil)
  # Breaks when new parameters are added to SmartMergerBase
end
```

**Applies to**: `FileAnalysis#initialize`, `SmartMerger#initialize`, and any method accepting a variable set of options.

#### Comment Classes

- `Ast::Merge::Comment::*` – Generic, language-agnostic comment classes
- Format-specific comment classes belong in their respective `*-merge` gem (e.g., `Prism::Merge::Comment::*` for Ruby magic comments)

#### Naming Conventions

- File paths must match class namespace paths (Ruby convention)
- Example: `Ast::Merge::Comment::Line` → `lib/ast/merge/comment/line.rb`

### kettle-dev Tooling

This project uses `kettle-dev` for gem maintenance automation:

- **Rakefile**: Sourced from kettle-dev template (`# kettle-dev Rakefile v1.1.60`)
- **CI Workflows**: GitHub Actions and GitLab CI are managed via kettle-dev templates
- **Templating**: Lines between `kettle-dev:freeze` / `kettle-dev:unfreeze` comments are preserved during template updates
- **Releases**: Use `kettle-release` for the automated release process

### Version Requirements
- Ruby >= 3.2.0 (gemspec), developed against Ruby 4.0.1 (`.tool-versions`)
- `tree_haver` >= 5.0.3 required

## 🧪 Testing Patterns

### kettle-test RSpec Helpers

All spec files load `require "kettle/test/rspec"` which provides RSpec helpers from the kettle-test gem. Do NOT recreate these helpers.

**Environment Variable Helpers** (from `rspec-stubbed_env`):
```ruby
before do
  stub_env("MY_ENV_VAR" => "value")
end

before do
  hide_env("HOME", "USER")
end
```

**Other Helpers**:
- `block_is_expected` – Enhanced block expectations (`rspec-block_is_expected`)
- `capture` – Capture output (`silent_stream`)
- Timecop integration for time manipulation

### MergeGemRegistry and Dependency Tags

`ast-merge` maintains a `MergeGemRegistry` for all known `*-merge` gems. Tags are available for conditional spec execution.

**Available dependency tags** (from `lib/ast/merge/rspec/dependency_tags.rb`):

| Tag | Gem Required |
|-----|-------------|
| `:markly_merge` | markly-merge |
| `:commonmarker_merge` | commonmarker-merge |
| `:markdown_merge` | markdown-merge |
| `:prism_merge` | prism-merge |
| `:bash_merge` | bash-merge |
| `:rbs_merge` | rbs-merge |
| `:json_merge` | json-merge |
| `:jsonc_merge` | jsonc-merge |
| `:toml_merge` | toml-merge |
| `:psych_merge` | psych-merge |
| `:dotenv_merge` | dotenv-merge |
| `:any_markdown_merge` | any markdown merge gem |

**TreeHaver also provides** backend tags (`:markly`, `:commonmarker`, `:prism_backend`, etc.) – see `tree_haver/rspec/dependency_tags`.

✅ **CORRECT** – Use dependency tag on describe/context/it:
```ruby
RSpec.describe SomeClass, :markly_merge do
  # Entire describe block is skipped if markly-merge unavailable
end

it "does something", :json_merge do
  # Skipped if json-merge unavailable
end
```

❌ **WRONG** – Never use require inside spec files:
```ruby
before do
  require "markly/merge"  # DO NOT DO THIS
end
```

### Loading Order in spec_helper.rb (ast-merge's own suite)

`ast-merge` uses the **split loading pattern** to preserve SimpleCov coverage instrumentation:

1. Load `tree_haver` and `tree_haver/rspec` early (before SimpleCov)
2. Start SimpleCov (`kettle-soup-cover`)
3. `require "ast/merge"` (instrumented by SimpleCov)
4. `require "ast/merge/rspec/setup"` (registry + helpers only)
5. `Ast::Merge::RSpec::MergeGemRegistry.register_known_gems(...)` (register all known gems)
6. `require "ast/merge/rspec/dependency_tags_config"` (configure RSpec exclusion filters)
7. `require "ast/merge/rspec/shared_examples"` (load shared examples)
8. Load merge gems via `require` in a rescue block (silently skip unavailable ones)

For **other `*-merge` gems** (not ast-merge itself), use the simple pattern:
```ruby
require "ast/merge/rspec"  # Loads everything: TreeHaver tags + Ast::Merge tags + shared examples
```

### Shared Examples

`ast-merge` provides shared examples for testing `*-merge` implementations:

```
lib/ast/merge/rspec/shared_examples/
├── conflict_resolver_base.rb  # "Ast::Merge::ConflictResolverBase"
├── debug_logger.rb            # "Ast::Merge::DebugLogger"
├── file_analyzable.rb         # "Ast::Merge::FileAnalyzable"
├── freeze_node_base.rb        # "Ast::Merge::FreezeNodeBase"
├── merge_result_base.rb       # "Ast::Merge::MergeResultBase"
├── merger_config.rb           # "Ast::Merge::MergerConfig"
└── reproducible_merge.rb      # "a reproducible merge" (idempotency tests)
```

The `"a reproducible merge"` shared example requires:
- `let(:fixtures_path)` – Path to fixtures directory
- `let(:merger_class)` – The SmartMerger class under test
- Optional: `let(:file_extension)` – File extension for fixtures (default: `""`)

Fixture structure:
```
fixtures_path/
  scenario_name/
    template.{ext}
    destination.{ext}
    result.{ext}
```

### MergeGemRegistry: Registering a New Merge Gem

When a new `*-merge` gem is created, add it to `KNOWN_GEMS` in `lib/ast/merge/rspec/merge_gem_registry.rb` and to `register_known_gems(...)` in `spec/spec_helper.rb`.

External gems can also self-register when loaded:
```ruby
# In your-gem/lib/your/merge.rb
if defined?(Ast::Merge::RSpec::MergeGemRegistry)
  Ast::Merge::RSpec::MergeGemRegistry.register(
    :your_merge,
    require_path: "your/merge",
    merger_class: "Your::Merge::SmartMerger",
    test_source: "example source",
    category: :data  # :markdown, :data, :code, :config, :other
  )
end
```

## 🔍 Critical Files

| File | Purpose |
|------|---------|
| `lib/ast/merge/smart_merger_base.rb` | Abstract base for all SmartMerger implementations (501 lines) |
| `lib/ast/merge/file_analyzable.rb` | Mixin for FileAnalysis classes; freeze detection, signatures (312 lines) |
| `lib/ast/merge/ast_node.rb` | Base for synthetic AST nodes; implements TreeHaver::Node protocol (284 lines) |
| `lib/ast/merge/merger_config.rb` | Merge options configuration object (261 lines) |
| `lib/ast/merge/rspec/merge_gem_registry.rb` | Registry for merge gem dependency tag availability (455 lines) |
| `lib/ast/merge/partial_template_merger_base.rb` | Base for partial/section merges (349 lines) |
| `lib/ast/merge/section_typing.rb` | AST-aware section classification (306 lines) |
| `lib/ast/merge/rspec/dependency_tags_config.rb` | RSpec exclusion filter configuration |
| `lib/ast/merge/rspec/dependency_tags_helpers.rb` | `DependencyTags` helper module |
| `lib/ast/merge/rspec/setup.rb` | Registry-only loader (no RSpec config); used by ast-merge's own spec suite |
| `lib/ast/merge/rspec.rb` | Full RSpec entry point (TreeHaver tags + Ast::Merge tags + shared examples) |
| `exe/ast-merge-recipe` | YAML-driven merge recipe CLI executable |
| `spec/spec_helper.rb` | Test suite entry point; demonstrates split loading pattern |
| `.envrc` | Coverage thresholds, tree-sitter paths, and dev environment variables |

## 🚀 Common Tasks

```bash
# Run all specs with coverage
bundle exec rake spec

# Generate coverage report
bundle exec rake coverage

# Check code quality
bundle exec rake reek
bundle exec rake rubocop_gradual

# Run benchmarks (skipped on CI)
bundle exec rake bench

# Prepare changelog for release, build and release
kettle-changelog && kettle-release
```

## 🌊 Integration Points

- **`tree_haver`**: All backends (MRI, Rust, FFI, Java, Prism, Psych, Citrus, Parslet, Commonmarker, Markly) via the unified TreeHaver adapter. `AstNode` inherits from `TreeHaver::Base::Node`.
- **`*-merge` gems**: Use `ast-merge` base classes to implement format-specific merging. Each gem registers itself with `MergeGemRegistry`.
- **RSpec**: Deep integration via `lib/ast/merge/rspec.rb` for dependency tagging and shared examples.
- **SimpleCov**: Coverage tracked for `lib/**/*.rb` and `lib/**/*.rake`; spec, vendor, examples, and `lib/ast/merge/rspec/` directories are excluded from coverage.
- **Recipe system**: `ast-merge-recipe` CLI + `Ast::Merge::Recipe::*` classes for YAML-driven merge automation.

## 💡 Key Insights

1. **No backward compatibility**: The maintainer explicitly prohibits backward compatibility shims, aliases, or deprecation layers. Make clean breaks.
2. **`vendor/` is not part of the project**: It is used for local development only and does not exist in CI.
3. **Split loading for SimpleCov**: `ast-merge`'s own spec suite MUST use the split loading pattern to ensure SimpleCov instruments the library code before it's required.
4. **`merge` returns a String**: `SmartMergerBase#merge` returns a String directly. `merge_result` returns the result object.
5. **`content_string` is legacy**: Use `to_s` on the result object instead.
6. **`merged_source` doesn't exist**: Use `merge` or `merge_result.to_s`.
7. **Magic comments are Ruby-specific**: They belong in `prism-merge`, not in `ast-merge`.
8. **`FrozenWrapper` vs `FreezeNodeBase`**: `FreezeNodeBase` uses `freeze_signature` (content-based matching). `FrozenWrapper` is unwrapped by `FileAnalyzable#generate_signature` to use the underlying node's structural signature — this prevents duplication when frozen node content differs between template and destination.
9. **`text_node.text` strips markdown formatting**: When matching Markdown nodes by `.text`, backticks, bold, italic, and link text are stripped. Match plain text only.

## 🧩 Markdown Text Matching Behavior

**CRITICAL**: When matching Markdown nodes by text content (e.g., anchor patterns in merge recipes or `PartialTemplateMerger`), the `.text` method returns **plain text without markdown formatting**.

**Example**:
- Markdown source: `` ### The `*-merge` Gem Family ``
- `.text` returns: `"The *-merge Gem Family\n"`

**Stripped formatting includes**: bold, italic, code spans, links, images.

**Pattern examples**:
```ruby
# ❌ WRONG - backticks won't be found
anchor: { type: :heading, text: /`\*-merge` Gem Family/ }

# ✅ CORRECT - match plain text
anchor: { type: :heading, text: /\*-merge.*Gem Family/ }
```

**In YAML recipes** (double escaping needed):
```yaml
anchor:
  type: heading
  text: "/^The \\*-merge Gem Family/"
```

## 🚫 Common Pitfalls

1. **NEVER add backward compatibility** – No shims, aliases, or deprecation layers.
2. **NEVER use `require` inside spec files** – Use dependency tags instead.
3. **NEVER pipe test commands through `head`/`tail`** – Run tests without output truncation.
4. **Do NOT load vendor gems** – They are not part of this project; they do not exist in CI.
5. **Use `tmp/` for temporary files** – Never use `/tmp` or other system directories.
6. **Do NOT chain `cd` with `&&`** – Run `cd` as a separate command so `direnv` loads ENV.
