# README Section Merge Examples

This directory contains examples demonstrating how to use `markdown-merge` and `markly-merge` for intelligent section-based README updates.

## Use Case

These examples show how to update the "Gem Family" section across multiple README files using a canonical template (`GEM_FAMILY_SECTION.md`), while preserving other customizations in each file.

## Examples

### 1. Signature Generator Approach (`01_signature_generator.rb`)

Uses a custom `signature_generator` to identify gem family section content by giving related nodes common signature prefixes.

```ruby
ruby examples/readme_section_merge/01_signature_generator.rb
```

**When to use**: Simple cases where you want all matching content to use the template.

### 2. Link Reference Deduplication (`02_link_ref_deduplication.rb`)

Extends the signature approach to handle link reference deduplication by matching them by label rather than full content.

```ruby
ruby examples/readme_section_merge/02_link_ref_deduplication.rb
```

**When to use**: When you have duplicate link references after merging.

### 3. Per-Node-Type Preference with node_typing (`03_node_typing.rb`) ⭐ RECOMMENDED

Uses `node_typing` with Hash `preference` for precise per-node-type merge control.

```ruby
ruby examples/readme_section_merge/03_node_typing.rb
```

**When to use**: When you need fine-grained control over which content uses template vs destination.

**Configuration example**:
```ruby
node_typing = {
  "table" => ->(node) {
    if node_text_includes?(node, "tree_haver")
      Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_table)
    else
      node
    end
  }
}

preference = {
  default: :destination,           # Keep destination by default
  gem_family_table: :template      # But use template for gem family tables
}
```

### 4. Structure Analysis (`04_structure_analysis.rb`)

Analyzes document structure to understand how markdown-merge sees nodes and signatures.

```ruby
ruby examples/readme_section_merge/04_structure_analysis.rb
```

**When to use**: Debugging signature matching issues or learning the internals.

## Fixtures

The `fixtures/readme_merge_test/` directory contains:

- `template.md` - A copy of `GEM_FAMILY_SECTION.md` for testing
- `destination_toml.md` - Sample toml-merge README
- `destination_kettle_dev.md` - Sample kettle-dev README
- `output/` - Merged output files from each example

## Key Concepts

### Signatures

Markdown-merge matches nodes between template and destination using signatures:
- `[:table, row_count, header_hash]` for tables
- `[:heading, level, text]` for headings
- `[:paragraph, content_hash]` for paragraphs

Nodes with matching signatures are compared for merge resolution.

### Node Typing

The `node_typing` option lets you assign custom `merge_type` symbols to nodes:

```ruby
node_typing = {
  "table" => ->(node) {
    Ast::Merge::NodeTyping.with_merge_type(node, :special_table)
  }
}
```

These types can then be used in a Hash `preference`:

```ruby
preference = {
  default: :destination,
  special_table: :template
}
```

### Preference

Controls which version wins when matched nodes have different content:
- `:destination` - Keep customizations (default)
- `:template` - Apply updates from template
- Hash - Per-type preferences like `{ default: :destination, gem_family_table: :template }`

## Related

- [markdown-merge](../../vendor/markdown-merge/README.md) - Core merge library
- [markly-merge](../../vendor/markly-merge/README.md) - Markly-specific wrapper
- [GEM_FAMILY_SECTION.md](../../GEM_FAMILY_SECTION.md) - Canonical template

