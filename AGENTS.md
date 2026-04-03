# AGENTS.md - ast-merge Development Guide

# AGENTS.md - Development Guide

## 🎯 Project Overview

`ast-merge` is a **shared infrastructure library for the `*-merge` gem family**. It provides base classes, modules, and RSpec shared examples for building intelligent file mergers using AST analysis. It powers `prism-merge`, `psych-merge`, `json-merge`, `markly-merge`, and other format-specific merge gems.

**Core Philosophy**: Write once, run anywhere. Define the merge protocol once in `ast-merge`; implement it in each `*-merge` gem for a specific file format.

## 🏗️ Architecture

### Toolchain Dependencies

This gem is part of the **kettle-rb** ecosystem. Key development tools:

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

**Minimum Supported Ruby**: See the gemspec `required_ruby_version` constraint.
**Local Development Ruby**: See `.tool-versions` for the version used in local development (typically the latest stable Ruby).

| Tool | Purpose |
|------|---------|
| `kettle-dev` | Development dependency: Rake tasks, release tooling, CI helpers |
| `kettle-test` | Test infrastructure: RSpec helpers, stubbed_env, timecop |
| `kettle-jem` | Template management and gem scaffolding |

### Executables (from kettle-dev)

| Executable | Purpose |
|-----------|---------|
| `kettle-release` | Full gem release workflow |
| `kettle-pre-release` | Pre-release validation |
| `kettle-changelog` | Changelog generation |
| `kettle-dvcs` | DVCS (git) workflow automation |
| `kettle-commit-msg` | Commit message validation |
| `kettle-check-eof` | EOF newline validation |

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

## ⚠️ AI Agent Terminal Behavior

### Terminal Output Is Available, but Each Command Is Isolated

**CRITICAL**: AI agents can read normal terminal output directly. However, each terminal command should still be treated as a fresh shell with no shared state.

**Use this pattern**:

### Test Infrastructure

- Uses `kettle-test` for RSpec helpers (stubbed_env, block_is_expected, silent_stream, timecop)
- Uses `Dir.mktmpdir` for isolated filesystem tests
- Spec helper is loaded by `.rspec` — never add `require "spec_helper"` to spec files

## ⚠️ AI Agent Terminal Limitations

### Use `mise` for Project Environment

**CRITICAL**: The canonical project environment lives in `mise.toml`, with local overrides in `.env.local` loaded via `dotenvy`.

⚠️ **Watch for trust prompts**: After editing `mise.toml` or `.env.local`, `mise` may require trust to be refreshed before commands can load the project environment. Until that trust step is handled, commands can appear hung or produce no output, which can look like terminal access is broken.

**Recovery rule**: If a `mise exec` command goes silent or appears hung, assume `mise trust` is the first thing to check. Recover by running:

```bash
mise trust -C /home/pboling/src/kettle-rb/ast-merge
mise exec -C /home/pboling/src/kettle-rb/ast-merge -- bundle exec rspec
```

```bash
mise trust -C /path/to/project
mise exec -C /path/to/project -- bundle exec rspec
```

Do this before spending time on unrelated debugging; in this workspace pattern, silent `mise` commands are usually a trust problem first.

```bash
mise trust -C /home/pboling/src/kettle-rb/ast-merge
```

✅ **CORRECT** — Run self-contained commands with `mise exec`:
```bash
mise exec -C /home/pboling/src/kettle-rb/ast-merge -- bundle exec rspec
```

```bash
mise exec -C /path/to/project -- bundle exec rspec
```

✅ **CORRECT** — If you need shell syntax first, load the environment in the same command:
```bash
eval "$(mise env -C /home/pboling/src/kettle-rb/ast-merge -s bash)" && bundle exec rspec
```

```bash
eval "$(mise env -C /path/to/project -s bash)" && bundle exec rspec
```

❌ **WRONG** — Do not rely on a previous command changing directories:
```bash
cd /home/pboling/src/kettle-rb/ast-merge
bundle exec rspec
```

```bash
cd /path/to/project
bundle exec rspec
```

❌ **WRONG** — A chained `cd` does not give directory-change hooks time to update the environment:
```bash
cd /home/pboling/src/kettle-rb/ast-merge && bundle exec rspec
```

```
lib/
├── <gem_namespace>/           # Main library code
│   └── version.rb             # Version constant (managed by kettle-release)
spec/
├── fixtures/                  # Test fixture files (NOT auto-loaded)
├── support/
│   ├── classes/               # Helper classes for specs
│   └── shared_contexts/       # Shared RSpec contexts
├── spec_helper.rb             # RSpec configuration (loaded by .rspec)
gemfiles/
├── modular/                   # Modular Gemfile components
│   ├── coverage.gemfile       # SimpleCov dependencies
│   ├── debug.gemfile          # Debugging tools
│   ├── documentation.gemfile  # YARD/documentation
│   ├── optional.gemfile       # Optional dependencies
│   ├── rspec.gemfile          # RSpec testing
│   ├── style.gemfile          # RuboCop/linting
│   └── x_std_libs.gemfile     # Extracted stdlib gems
├── ruby_*.gemfile             # Per-Ruby-version Appraisal Gemfiles
└── Appraisal.root.gemfile     # Root Gemfile for Appraisal builds
.git-hooks/
├── commit-msg                 # Commit message validation hook
├── prepare-commit-msg         # Commit message preparation
├── commit-subjects-goalie.txt # Commit subject prefix filters
└── footer-template.erb.txt    # Commit footer ERB template
```

## 🔧 Development Workflows

### Running Tests

```bash
# Full suite (required for coverage thresholds)
mise exec -C /home/pboling/src/kettle-rb/ast-merge -- bundle exec rspec

# Single file (disable coverage threshold check)
mise exec -C /home/pboling/src/kettle-rb/ast-merge -- env K_SOUP_COV_MIN_HARD=false bundle exec rspec spec/ast/merge/text/smart_merger_spec.rb
```

### Running Commands

Always make commands self-contained. Use `mise exec -C /home/pboling/src/kettle-rb/prism-merge -- ...` so the command gets the project environment in the same invocation.

```bash
mise exec -C /path/to/project -- bundle exec rspec
```

For single file, targeted, or partial spec runs the coverage threshold **must** be disabled.
Use the `K_SOUP_COV_MIN_HARD=false` environment variable to disable hard failure:

```bash
mise exec -C /home/pboling/src/kettle-rb/ast-merge -- bundle exec rspec spec/ast/merge/smart_merger_base_spec.rb
```

```bash
mise exec -C /path/to/project -- env K_SOUP_COV_MIN_HARD=false bundle exec rspec spec/path/to/spec.rb
```

### Coverage Reports

```bash
mise exec -C /home/pboling/src/kettle-rb/ast-merge -- bin/rake coverage
mise exec -C /home/pboling/src/kettle-rb/ast-merge -- bin/kettle-soup-cover -d
```

This runs tests with coverage instrumentation and generates reports in the `coverage/` directory.

**Preferred inspection workflow**: use `bin/kettle-soup-cover -d` to parse and summarize coverage output instead of ad hoc JSON/Python parsing or HTML report review.

For sibling repos, run coverage from that repo's own root, for example:

```bash
mise exec -C /home/pboling/src/kettle-rb/prism-merge -- bash -lc 'bin/rake coverage && bin/kettle-soup-cover -d'
```

```bash
mise exec -C /path/to/project -- bin/rake coverage
mise exec -C /path/to/project -- bin/kettle-soup-cover -d
```

**Key ENV variables** (set in `mise.toml`, with local overrides in `.env.local`):

- `grep_search` instead of `grep` command
- `file_search` instead of `find` command
- `read_file` instead of `cat` command
- `list_dir` instead of `ls` command
- `replace_string_in_file` or `create_file` instead of `sed` / manual editing

```bash
cd /path/to/project && bundle exec rspec
```

### Prefer Internal Tools Over Terminal

✅ **PREFERRED** — Use internal tools:

### Code Quality

```bash
bundle exec rake reek
bundle exec rake rubocop_gradual
```

### Prepare and Release

```bash
kettle-changelog && kettle-release
```

```bash
mise exec -C /path/to/project -- bundle exec rake reek
mise exec -C /path/to/project -- bundle exec rubocop-gradual
```

### Releasing

```bash
bin/kettle-pre-release    # Validate everything before release
bin/kettle-release        # Full release workflow
```

## 📝 Project Conventions

### API Conventions

#### SmartMergerBase API

❌ **AVOID** when possible:
- `run_in_terminal` for information gathering

Only use terminal for:
- Running tests (`bundle exec rspec`)
- Installing dependencies (`bundle install`)
- Git operations that require interaction
- Commands that actually need to execute (not just gather info)

#### Forward Compatibility with `**options`

### Forward Compatibility with `**options`

**CRITICAL**: All constructors and public API methods that accept keyword arguments MUST include `**options` as the final parameter for forward compatibility.

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

When you do run tests, keep the full output visible so you can inspect failures completely.

#### Comment Classes

- `Ast::Merge::Comment::*` – Generic, language-agnostic comment classes
- Format-specific comment classes belong in their respective `*-merge` gem (e.g., `Prism::Merge::Comment::*` for Ruby magic comments)

#### Naming Conventions

- File paths must match class namespace paths (Ruby convention)
- Example: `Ast::Merge::Comment::Line` → `lib/ast/merge/comment/line.rb`

### kettle-dev Tooling

This project is a **RubyGem** managed with the [kettle-rb](https://github.com/kettle-rb) toolchain.

- `K_SOUP_COV_DO=true` – Enable coverage
- `K_SOUP_COV_MIN_LINE` – Line coverage threshold
- `K_SOUP_COV_MIN_BRANCH` – Branch coverage threshold
- `K_SOUP_COV_MIN_HARD=true` – Fail if thresholds not met

### Version Requirements

- Ruby >= 3.2.0 (gemspec), developed against Ruby 4.0.1 (`.tool-versions`)
- `tree_haver` >= 5.0.3 required

## 🧪 Testing Patterns

### kettle-test RSpec Helpers

All spec files load `require "kettle/test/rspec"` which provides RSpec helpers from the kettle-test gem. Do NOT recreate these helpers.

**Environment Variable Helpers** (from `rspec-stubbed_env`):

### Environment Variable Helpers

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

### Dependency Tags

Use dependency tags to conditionally skip tests when optional dependencies are not available:

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

Full suite spec runs:

```ruby
before do
  require "markly/merge"  # DO NOT DO THIS
end
```

### Loading Order in spec_helper.rb (ast-merge's own suite)

### Freeze Block Preservation

Template updates preserve custom code wrapped in freeze blocks:

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
| `mise.toml` | Shared development environment variables and local `.env.local` loading |

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

```ruby
# kettle-jem:freeze
# ... custom code preserved across template runs ...
# kettle-jem:unfreeze
```

### Modular Gemfile Architecture

Gemfiles are split into modular components under `gemfiles/modular/`. Each component handles a specific concern (coverage, style, debug, etc.). The main `Gemfile` loads these modular components via `eval_gemfile`.

**Example**:
- Markdown source: `` ### The `*-merge` Gem Family ``
- `.text` returns: `"The *-merge Gem Family\n"`

**Stripped formatting includes**: bold, italic, code spans, links, images.

**Pattern examples**:
```text
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

```ruby
RSpec.describe SomeClass, :prism_merge do
  # Skipped if prism-merge is not available
end
```

## 🚫 Common Pitfalls

1. **NEVER add backward compatibility** – No shims, aliases, or deprecation layers.
2. **NEVER use `require` inside spec files** – Use dependency tags instead.
3. **NEVER pipe test commands through `head`/`tail`** – Run tests without output truncation.
4. **Do NOT load vendor gems** – They are not part of this project; they do not exist in CI.
5. **Use `tmp/` for temporary files** – Never use `/tmp` or other system directories.
6. **Do NOT expect `cd` to persist** – Every terminal command is isolated; use a self-contained `mise exec -C ... -- ...` invocation.
7. **Do NOT rely on prior shell state** – Previous `cd`, `export`, aliases, and functions are not available to the next command.

1. **NEVER add backward compatibility** — No shims, aliases, or deprecation layers. Bump major version instead.
2. **NEVER expect `cd` to persist** — Every terminal command is isolated; use a self-contained `mise exec -C ... -- ...` invocation.
3. **NEVER pipe test output through `head`/`tail`** — Run tests without truncation so you can inspect the full output.
4. **Terminal commands do not share shell state** — Previous `cd`, `export`, aliases, and functions are not available to the next command.

1. **NEVER add backward compatibility** — No shims, aliases, or deprecation layers. Bump major version instead.
2. **NEVER expect `cd` to persist** — Every terminal command is isolated; use a self-contained `mise exec -C ... -- ...` invocation.
3. **NEVER pipe test output through `head`/`tail`** — Run tests without truncation so you can inspect the full output.
4. **Terminal commands do not share shell state** — Previous `cd`, `export`, aliases, and functions are not available to the next command.
