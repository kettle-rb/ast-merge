# Ast::Merge RSpec Support

This directory contains RSpec helpers for the ast-merge gem family:

1. **Shared Examples** - Reusable test specifications for `*-merge` implementations
2. **Dependency Tags** - Conditional test execution based on available merge gems
3. **MergeGemRegistry** - Dynamic registration system for merge gem availability

## Quick Start

Add to your `spec_helper.rb`:

```ruby
# Load tree_haver RSpec support first (sets up backend availability methods)
require "tree_haver/rspec"

# Load merge gems to trigger their registrations
# (silently skip gems that aren't available)
%w[
  markly/merge
  commonmarker/merge
  markdown/merge
  prism/merge
  json/merge
].each do |gem_path|
  require gem_path
rescue LoadError
  # Gem not available - will be excluded via dependency tags
end

# Load ast-merge RSpec support (configures exclusion filters)
require "ast/merge/rspec"
```

This loads:
- **TreeHaver dependency tags** - Parser backend availability (`:markly_backend`, `:prism_backend`, `:ffi_backend`, etc.)
- **Ast::Merge dependency tags** - Merge gem availability (`:markly_merge`, `:prism_merge`, etc.)
- **Ast::Merge shared examples** - For validating `*-merge` implementations

**Important Load Order**: The merge gems must be loaded **after** `tree_haver/rspec` (which sets up backend availability methods) but **before** `ast/merge/rspec` (which configures RSpec exclusion filters based on registered gems).

---

## MergeGemRegistry

The `MergeGemRegistry` is a dynamic registration system that allows merge gems to register themselves for RSpec dependency tag support.

### How It Works

1. **Pre-configured gems**: `KNOWN_GEMS` contains configuration for all known merge gems
2. **Dynamic registration**: When a merge gem is loaded, it registers itself with the registry
3. **Availability checking**: The registry attempts to require and instantiate the merger to verify it works
4. **RSpec integration**: Exclusion filters are configured based on registered gem availability

### Registering a New Merge Gem

Merge gems register themselves when loaded. Add this to your gem's main file:

```ruby
# In my-merge/lib/my/merge.rb
module My
  module Merge
    # ... your code ...
  end
end

# Register with ast-merge's MergeGemRegistry for RSpec dependency tags
# Only register if MergeGemRegistry is loaded (i.e., in test environment)
if defined?(Ast::Merge::RSpec::MergeGemRegistry)
  Ast::Merge::RSpec::MergeGemRegistry.register(
    :my_merge,
    require_path: "my/merge",
    merger_class: "My::Merge::SmartMerger",
    test_source: "sample content for testing",
    category: :data,  # One of: :markdown, :data, :code, :config, :other
  )
end
```

The `if defined?` guard ensures the registration only happens when the RSpec support is loaded, avoiding errors in production environments.

### Registration Options

| Option | Type | Description |
|--------|------|-------------|
| `require_path` | String | Path to require the gem (e.g., `"markly/merge"`) |
| `merger_class` | String | Full class name of the SmartMerger |
| `test_source` | String | Sample source code to test that merging works |
| `category` | Symbol | Category for grouping: `:markdown`, `:data`, `:code`, `:config`, `:other` |
| `skip_instantiation` | Boolean | If `true`, only check class exists (for gems requiring backends like markdown-merge) |

### Pre-configured Known Gems

The following gems are pre-configured in `KNOWN_GEMS` and can be checked before they're loaded:

| Category | Gems |
|----------|------|
| `:markdown` | `markly_merge`, `commonmarker_merge`, `markdown_merge` |
| `:code` | `prism_merge`, `bash_merge`, `rbs_merge` |
| `:data` | `json_merge`, `jsonc_merge` |
| `:config` | `toml_merge`, `psych_merge`, `dotenv_merge` |

---

## Shared Examples

Shared RSpec examples validate correct implementation of ast-merge base classes. These examples ensure consistency across all gems in the merge family.

### Selective Loading

If you only need shared examples (without dependency tags):

```ruby
require "ast/merge/rspec/shared_examples"
```

Or load specific shared examples:

```ruby
require "ast/merge/rspec/shared_examples/conflict_resolver_base"
```

### Available Shared Examples

#### ConflictResolverBase

Validates conflict resolver implementation.

```ruby
RSpec.describe(MyMerge::ConflictResolver) do
  it_behaves_like "Ast::Merge::ConflictResolverBase" do
    let(:resolver_class) { described_class }
    let(:template_analysis) { MyMerge::FileAnalysis.new(template_source) }
    let(:dest_analysis) { MyMerge::FileAnalysis.new(dest_source) }
  end
end
```

**Tests:**
- Responds to `#resolve` method
- Returns proper resolution hash with `:decision`, `:source`, `:reason`
- Handles preference settings correctly
- Processes frozen nodes appropriately

#### DebugLogger

Validates debug logging integration.

```ruby
it_behaves_like "Ast::Merge::DebugLogger" do
  let(:described_logger) { MyMerge::DebugLogger }
  let(:env_var_name) { "MY_MERGE_DEBUG" }
  let(:log_prefix) { "[MyMerge]" }
end
```

**Tests:**
- Responds to logging methods (`debug`, `info`, `warning`)
- Honors environment variable for enabling/disabling
- Uses correct log prefix

#### FileAnalyzable

Validates file analysis mixin implementation.

```ruby
RSpec.describe(MyMerge::FileAnalysis) do
  it_behaves_like "Ast::Merge::FileAnalyzable" do
    let(:analysis_class) { described_class }
    let(:sample_source) { "sample content" }
  end
end
```

**Tests:**
- Has `statements` method returning enumerable
- Has `source` accessor
- Supports freeze token configuration

#### FreezeNodeBase

Validates freeze node implementation.

```ruby
RSpec.describe(MyMerge::FreezeNode) do
  it_behaves_like "Ast::Merge::FreezeNodeBase" do
    let(:freeze_node_class) { described_class }
    let(:create_freeze_node) do
      lambda { |start_line:, end_line:, **opts|
        described_class.new(start_line: start_line, end_line: end_line, **opts)
      }
    end
  end
end
```

**Tests:**
- Has required attributes (start_line, end_line, reason)
- Responds to `freeze_node?` returning true
- Has `to_s` method

#### MergeResultBase

Validates merge result implementation.

```ruby
RSpec.describe(MyMerge::MergeResult) do
  it_behaves_like "Ast::Merge::MergeResultBase" do
    let(:result_class) { described_class }
    let(:content) { "merged content" }
  end
end
```

**Tests:**
- Has `to_s` returning content
- Has `changed?` method
- Has statistics/metadata accessors

#### MergerConfig

Validates merger configuration options.

```ruby
RSpec.describe(MyMerge::SmartMerger) do
  it_behaves_like "Ast::Merge::MergerConfig"
end
```

**Tests:**
- Accepts `preference` option
- Accepts `freeze_token` option
- Accepts `signature_generator` option
- Accepts `node_typing` option

#### Reproducible Merge

Validates merge reproducibility with fixtures.

```ruby
RSpec.describe(MyMerge::SmartMerger) do
  it_behaves_like "a reproducible merge" do
    let(:merger_class) { MyMerge::SmartMerger }
    let(:template_content) { "template" }
    let(:destination_content) { "destination" }
    let(:expected_content) { "expected result" }
  end
end
```

**Tests:**
- Merge produces expected output
- Merge is idempotent (merging result with itself produces same result)
- Handles edge cases consistently

---

## Dependency Tags

Dependency tags provide conditional test execution based on available dependencies.

### Selective Loading

If you only need dependency tags (without shared examples):

```ruby
require "ast/merge/rspec/dependency_tags"
```

### Usage

Tag your specs with the appropriate dependency tag:

```ruby
# Entire describe block requires markly-merge
RSpec.describe(MyMarkdownProcessor, :markly_merge) do
  # All tests here require markly-merge
end

# Only specific context requires a dependency
describe "#process" do
  context "with JSON content", :json_merge do
    # These tests require json-merge
  end

  context "with plain text" do
    # These tests have no special requirements
  end
end

# Individual examples can be tagged
it "merges TOML files", :toml_merge do
  # This test requires toml-merge
end
```

### Available Dependency Tags

#### Merge Gem Tags (from ast-merge)

These tags check that the specified merge gem is available AND functional.
Tags are configured dynamically from `MergeGemRegistry`.

| Tag | Category | Description |
|-----|----------|-------------|
| `:markly_merge` | markdown | Requires [markly-merge](https://github.com/kettle-rb/markly-merge) gem |
| `:commonmarker_merge` | markdown | Requires commonmarker-merge gem |
| `:markdown_merge` | markdown | Requires [markdown-merge](https://github.com/kettle-rb/markdown-merge) gem |
| `:prism_merge` | code | Requires [prism-merge](https://github.com/kettle-rb/prism-merge) gem |
| `:bash_merge` | code | Requires [bash-merge](https://github.com/kettle-rb/bash-merge) gem |
| `:rbs_merge` | code | Requires rbs-merge gem |
| `:json_merge` | data | Requires [json-merge](https://github.com/kettle-rb/json-merge) gem |
| `:jsonc_merge` | data | Requires jsonc-merge gem |
| `:toml_merge` | config | Requires [toml-merge](https://github.com/kettle-rb/toml-merge) gem |
| `:psych_merge` | config | Requires psych-merge gem |
| `:dotenv_merge` | config | Requires dotenv-merge gem |
| `:any_markdown_merge` | - | Requires at least one markdown merge gem |

#### Parser Backend Tags (from tree_haver)

These tags are provided by [tree_haver](https://github.com/kettle-rb/tree_haver) and check parser/backend availability.
All tags follow consistent naming conventions with descriptive suffixes.

##### Backend Tags (`*_backend`)

| Tag | Description |
|-----|-------------|
| `:mri_backend` | Requires ruby_tree_sitter gem (MRI only) |
| `:rust_backend` | Requires tree_stump gem (MRI only) |
| `:ffi_backend` | Requires FFI backend with libtree-sitter (MRI, JRuby) |
| `:java_backend` | Requires jtreesitter (JRuby only) |
| `:prism_backend` | Requires Prism parser (all platforms) |
| `:psych_backend` | Requires Psych parser (all platforms) |
| `:commonmarker_backend` | Requires commonmarker gem (all platforms) |
| `:markly_backend` | Requires markly gem (all platforms) |
| `:citrus_backend` | Requires citrus gem (all platforms) |
| `:parslet_backend` | Requires parslet gem (all platforms) |
| `:rbs_backend` | Requires RBS gem (MRI only) |

##### Engine Tags (`*_engine`)

| Tag | Description |
|-----|-------------|
| `:mri_engine` | Runs only on MRI Ruby |
| `:jruby_engine` | Runs only on JRuby |
| `:truffleruby_engine` | Runs only on TruffleRuby |

##### Grammar Tags (`*_grammar`)

| Tag | Description |
|-----|-------------|
| `:libtree_sitter` | Requires libtree-sitter runtime library |
| `:bash_grammar` | Requires tree-sitter-bash grammar |
| `:toml_grammar` | Requires tree-sitter-toml grammar |
| `:json_grammar` | Requires tree-sitter-json grammar |
| `:jsonc_grammar` | Requires tree-sitter-jsonc grammar |
| `:rbs_grammar` | Requires tree-sitter-rbs grammar |

##### Parsing Capability Tags (`*_parsing`)

| Tag | Description |
|-----|-------------|
| `:toml_parsing` | Requires any TOML parsing capability (tree-sitter or toml-rb) |
| `:markdown_parsing` | Requires any Markdown parsing capability (markly or commonmarker) |
| `:rbs_parsing` | Requires any RBS parsing capability |

##### Specific Library Tags (`*_gem`)

| Tag | Description |
|-----|-------------|
| `:toml_rb_gem` | Requires toml-rb gem (Citrus-based TOML parser) |
| `:toml_gem` | Requires toml gem |
| `:rbs_gem` | Requires rbs gem |

See the [TreeHaver RSpec documentation](https://github.com/kettle-rb/tree_haver/blob/main/lib/tree_haver/rspec/README.md) for the complete list and detailed documentation.

#### Negated Tags

All positive tags have negated versions prefixed with `not_`:

| Tag | Description |
|-----|-------------|
| `:not_markly_merge` | Runs only when markly-merge is NOT available |
| `:not_prism_merge` | Runs only when prism-merge is NOT available |
| `:not_markly_backend` | Runs only when markly backend is NOT available |
| `:not_mri_engine` | Runs only when NOT on MRI Ruby |
| `:not_toml_grammar` | Runs only when tree-sitter-toml is NOT available |
| ... | (and so on for all other tags) |

### Debugging

Set environment variables to see which dependencies are available:

```bash
# Show ast-merge dependency summary
AST_MERGE_DEBUG=1 bundle exec rspec

# Show tree_haver dependency summary
TREE_HAVER_DEBUG=1 bundle exec rspec

# Show both
AST_MERGE_DEBUG=1 TREE_HAVER_DEBUG=1 bundle exec rspec
```

Example output:

```
=== Ast::Merge Test Dependencies ===
  markly_merge: ✓ available
  commonmarker_merge: ✓ available
  markdown_merge: ✓ available
  prism_merge: ✓ available
  json_merge: ✓ available
  toml_merge: ✓ available
  any_markdown_merge: ✓ available
=====================================
```

### Best Practices

1. **Tag at the highest appropriate level** - If all tests in a describe block need the same dependency, tag the describe block.

2. **Don't use `require` in spec files** - Let the dependency tags handle it:

   ```ruby
   # ❌ WRONG
before { require "markly/merge" }

   # ✅ CORRECT
RSpec.describe(MyClass, :markly_merge) do
  # ...
end
   ```

3. **Use composite tags when appropriate** - If your test works with any markdown merger, use `:any_markdown_merge`.

4. **Negated tags for fallback testing** - Use negated tags to test behavior when a dependency is missing.

5. **Load gems before configuring RSpec** - Ensure merge gems are loaded before `ast/merge/rspec` so registrations complete before exclusion filters are set.

---

## API Reference

### `Ast::Merge::RSpec::MergeGemRegistry`

```ruby
# Register a merge gem (typically done in the gem's lib file)
Ast::Merge::RSpec::MergeGemRegistry.register(
  :my_merge,
  require_path: "my/merge",
  merger_class: "My::Merge::SmartMerger",
  test_source: "sample content",
  category: :data,
)

# Check if a merge gem is available
Ast::Merge::RSpec::MergeGemRegistry.available?(:markly_merge)  # => true/false

# Get all registered gems (including pre-configured KNOWN_GEMS)
Ast::Merge::RSpec::MergeGemRegistry.registered_gems
# => [:markly_merge, :commonmarker_merge, :prism_merge, ...]

# Get gems by category
Ast::Merge::RSpec::MergeGemRegistry.gems_by_category(:markdown)
# => [:markly_merge, :commonmarker_merge, :markdown_merge]

# Get registration info for a gem
Ast::Merge::RSpec::MergeGemRegistry.info(:markly_merge)
# => { require_path: "markly/merge", merger_class: "...", ... }

# Get availability summary
Ast::Merge::RSpec::MergeGemRegistry.summary
# => { markly_merge: true, prism_merge: true, ... }

# Clear availability cache (useful for testing)
Ast::Merge::RSpec::MergeGemRegistry.clear_cache!
```

### `Ast::Merge::RSpec::DependencyTags`

```ruby
# Check individual dependencies (methods defined dynamically from registry)
Ast::Merge::RSpec::DependencyTags.markly_merge_available?     # => true/false
Ast::Merge::RSpec::DependencyTags.prism_merge_available?      # => true/false

# Check composite availability
Ast::Merge::RSpec::DependencyTags.any_markdown_merge_available?  # => true/false

# Get summary of all dependencies
Ast::Merge::RSpec::DependencyTags.summary
# => { markly_merge: true, prism_merge: false, any_markdown_merge: true, ... }

# Reset memoized checks
Ast::Merge::RSpec::DependencyTags.reset!
```

### `TreeHaver::RSpec::DependencyTags`

```ruby
# Check parser backend availability
TreeHaver::RSpec::DependencyTags.markly_backend_available?   # => true/false
TreeHaver::RSpec::DependencyTags.commonmarker_backend_available? # => true/false
TreeHaver::RSpec::DependencyTags.prism_backend_available?    # => true/false
TreeHaver::RSpec::DependencyTags.mri_backend_available?      # => true/false
TreeHaver::RSpec::DependencyTags.rust_backend_available?     # => true/false
TreeHaver::RSpec::DependencyTags.ffi_available?              # => true/false

# Check engine
TreeHaver::RSpec::DependencyTags.mri?                        # => true/false
TreeHaver::RSpec::DependencyTags.jruby?                      # => true/false
TreeHaver::RSpec::DependencyTags.truffleruby?                # => true/false

# Check grammar availability
TreeHaver::RSpec::DependencyTags.bash_grammar_available?     # => true/false
TreeHaver::RSpec::DependencyTags.toml_grammar_available?     # => true/false

# Check parsing capability
TreeHaver::RSpec::DependencyTags.toml_parsing_available?         # => true/false
TreeHaver::RSpec::DependencyTags.any_markdown_backend_available? # => true/false

# Get summary of all parser dependencies
TreeHaver::RSpec::DependencyTags.summary
# => { mri_backend: true, prism_backend: true, ffi_backend: false, ... }
```

---

## Architecture

### Registration Flow

```
1. spec_helper.rb loads tree_haver/rspec
   └── Sets up BackendRegistry and backend availability methods

2. spec_helper.rb loads merge gems (markly/merge, prism/merge, etc.)
   └── Each gem calls MergeGemRegistry.register() if defined
   └── Registration defines *_available? method on DependencyTags

3. spec_helper.rb loads ast/merge/rspec
   └── DependencyTags configures RSpec exclusion filters
   └── For each registered gem, adds filter based on available?()
```

### Why This Order Matters

- **tree_haver/rspec first**: Some merge gems (like markly-merge, commonmarker-merge) depend on TreeHaver backends. Loading tree_haver/rspec sets up the backend availability methods that these gems' registrations may trigger.

- **Merge gems second**: Loading the gems triggers their `MergeGemRegistry.register()` calls, which both registers the gem and defines the `*_available?` method on DependencyTags.

- **ast/merge/rspec last**: This configures RSpec's exclusion filters by iterating over `registered_gems` and checking `available?()` for each. If gems aren't registered yet, their tests would be incorrectly excluded.

---

## See Also

- [TreeHaver RSpec Documentation](https://github.com/kettle-rb/tree_haver/blob/main/lib/tree_haver/rspec/README.md) - Parser backend dependency tags
- [ast-merge README](../../../../README.md) - Main documentation

## License

See the main [LICENSE.txt](../../../../LICENSE.txt) file.
