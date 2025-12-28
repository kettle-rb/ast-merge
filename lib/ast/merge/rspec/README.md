# Ast::Merge::RSpec

Shared RSpec examples for testing `*-merge` gem implementations.

## Overview

The `RSpec` namespace provides shared examples that validate correct implementation of ast-merge base classes. These examples ensure consistency across all gems in the merge family.

## Installation

Add to your spec helper:

```ruby
# spec/spec_helper.rb
require "ast/merge/rspec"
```

Or load specific shared examples:

```ruby
require "ast/merge/rspec/shared_examples/conflict_resolver_base"
```

## Available Shared Examples

### ConflictResolverBase

Validates conflict resolver implementation.

```ruby
RSpec.describe MyMerge::ConflictResolver do
  it_behaves_like "Ast::Merge::ConflictResolverBase"
end
```

**Tests:**
- Responds to `#resolve` method
- Returns proper resolution hash with `:decision`, `:source`, `:reason`
- Handles preference settings correctly
- Processes frozen nodes appropriately

### DebugLogger

Validates debug logging integration.

```ruby
RSpec.describe MyMerge::SmartMerger do
  it_behaves_like "Ast::Merge::DebugLogger"
end
```

**Tests:**
- Logger can be enabled/disabled
- Log levels work correctly
- Performance timing is recorded

### FileAnalyzable

Validates file analysis mixin implementation.

```ruby
RSpec.describe MyMerge::FileAnalysis do
  it_behaves_like "Ast::Merge::FileAnalyzable"
end
```

**Tests:**
- Responds to required methods (`#statements`, `#content`, `#valid?`)
- Returns proper statement types
- Handles parse errors gracefully

### FreezeNodeBase

Validates freeze node implementation.

```ruby
RSpec.describe MyMerge::FreezeNode do
  it_behaves_like "Ast::Merge::FreezeNodeBase"
end
```

**Tests:**
- Wraps inner nodes correctly
- Preserves freeze reason
- Implements required TreeHaver::Node protocol

### MergeResultBase

Validates merge result implementation.

```ruby
RSpec.describe MyMerge::MergeResult do
  it_behaves_like "Ast::Merge::MergeResultBase"
end
```

**Tests:**
- Contains `#content` method
- Tracks `#stats` correctly
- Reports `#changed?` accurately
- Records `#frozen_blocks` information

### MergerConfig

Validates merger configuration handling.

```ruby
RSpec.describe MyMerge::SmartMerger do
  it_behaves_like "Ast::Merge::MergerConfig"
end
```

**Tests:**
- Accepts standard options
- Validates preference settings
- Handles node_typing configuration

### Reproducible Merge

Validates merge operations are deterministic and idempotent.

```ruby
RSpec.describe MyMerge::SmartMerger do
  it_behaves_like "a reproducible merge" do
    let(:merger_class) { MyMerge::SmartMerger }
    let(:template) { "..." }
    let(:destination) { "..." }
  end
end
```

**Tests:**
- Same inputs produce same outputs
- Merging result with itself produces no changes (idempotency)
- Stats are consistent across runs

## Creating Fixture-Based Tests

For integration testing with fixtures:

```ruby
RSpec.describe "My merge scenarios" do
  Dir.glob("spec/fixtures/*/").each do |fixture_dir|
    context "fixture: #{File.basename(fixture_dir)}" do
      let(:template) { File.read("#{fixture_dir}/template.md") }
      let(:destination) { File.read("#{fixture_dir}/destination.md") }
      let(:expected) { File.read("#{fixture_dir}/expected.md") }
      
      it "produces expected output" do
        merger = MyMerge::SmartMerger.new(template, destination)
        expect(merger.merge).to eq(expected)
      end
    end
  end
end
```

## See Also

- [ast-merge README](../../../README.md) - Main documentation
- [SmartMergerBase](../smart_merger_base.rb) - Base merger class
- [ConflictResolverBase](../conflict_resolver_base.rb) - Base resolver class

