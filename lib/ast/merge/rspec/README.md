# Ast::Merge RSpec Support

This directory contains RSpec helpers for the ast-merge gem family:

1. **Shared Examples** - Reusable test specifications for `*-merge` implementations
2. **Dependency Tags** - Conditional test execution based on available merge gems

## Quick Start

Add to your `spec_helper.rb`:

```ruby
require "ast/merge/rspec"
```

This single require loads:
- **TreeHaver dependency tags** - Parser backend availability (`:markly`, `:prism_backend`, `:ffi`, etc.)
- **Ast::Merge dependency tags** - Merge gem availability (`:markly_merge`, `:prism_merge`, etc.)
- **Ast::Merge shared examples** - For validating `*-merge` implementations

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

These tags check that the specified merge gem is available AND functional:

| Tag | Description |
|-----|-------------|
| `:markly_merge` | Requires [markly-merge](https://github.com/kettle-rb/markly-merge) gem |
| `:commonmarker_merge` | Requires commonmarker-merge gem |
| `:markdown_merge` | Requires [markdown-merge](https://github.com/kettle-rb/markdown-merge) gem |
| `:prism_merge` | Requires [prism-merge](https://github.com/kettle-rb/prism-merge) gem |
| `:json_merge` | Requires [json-merge](https://github.com/kettle-rb/json-merge) gem |
| `:jsonc_merge` | Requires jsonc-merge gem |
| `:toml_merge` | Requires [toml-merge](https://github.com/kettle-rb/toml-merge) gem |
| `:bash_merge` | Requires [bash-merge](https://github.com/kettle-rb/bash-merge) gem |
| `:psych_merge` | Requires psych-merge gem |
| `:any_markdown_merge` | Requires at least one markdown merge gem |

#### Parser Backend Tags (from tree_haver)

These tags are provided by [tree_haver](https://github.com/kettle-rb/tree_haver) and check parser availability:

| Tag | Description |
|-----|-------------|
| `:markly` | Requires markly gem (parser) |
| `:commonmarker` | Requires commonmarker gem (parser) |
| `:prism_backend` | Requires Prism parser |
| `:psych_backend` | Requires Psych parser |
| `:ffi` | Requires FFI backend |
| `:mri_backend` | Requires ruby_tree_sitter gem |
| `:rust_backend` | Requires tree_stump gem |

See the [TreeHaver RSpec documentation](https://github.com/kettle-rb/tree_haver/blob/main/lib/tree_haver/rspec/README.md) for the complete list of parser backend tags.

#### Negated Tags

All positive tags have negated versions prefixed with `not_`:

| Tag | Description |
|-----|-------------|
| `:not_markly_merge` | Runs only when markly-merge is NOT available |
| `:not_prism_merge` | Runs only when prism-merge is NOT available |
| `:not_markly` | Runs only when markly parser is NOT available |
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

---

## API Reference

### `Ast::Merge::RSpec::DependencyTags`

```ruby
# Check individual dependencies
Ast::Merge::RSpec::DependencyTags.markly_merge_available?     # => true/false
Ast::Merge::RSpec::DependencyTags.prism_merge_available?      # => true/false

# Get summary of all dependencies
Ast::Merge::RSpec::DependencyTags.summary
# => { markly_merge: true, prism_merge: false, ... }

# Reset memoized checks
Ast::Merge::RSpec::DependencyTags.reset!
```

### `TreeHaver::RSpec::DependencyTags`

```ruby
# Check parser backend availability
TreeHaver::RSpec::DependencyTags.markly_available?        # => true/false
TreeHaver::RSpec::DependencyTags.prism_available?         # => true/false

# Get summary of all parser dependencies
TreeHaver::RSpec::DependencyTags.summary
# => { markly: true, prism: true, ffi: false, ... }
```

## See Also

- [TreeHaver RSpec Documentation](https://github.com/kettle-rb/tree_haver/blob/main/lib/tree_haver/rspec/README.md) - Parser backend dependency tags
- [ast-merge README](../../../../README.md) - Main documentation

## License

See the main [LICENSE.txt](../../../../LICENSE.txt) file.
