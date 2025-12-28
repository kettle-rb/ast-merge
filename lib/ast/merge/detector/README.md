# Ast::Merge::Detector

Region detection and merging functionality for identifying and handling specialized content regions within documents.

## Overview

The `Detector` namespace provides tools for identifying portions of a document that should be handled by a specialized merger. For example:
- YAML frontmatter in a Markdown file
- TOML frontmatter in Hugo content
- Ruby code blocks that should be merged with Prism
- Fenced code blocks in any language

## Components

### Region (Struct)

A data structure representing a detected region within a document.

```ruby
region = Ast::Merge::Detector::Region.new(
  type: :yaml_frontmatter,
  content: "title: My Doc\nversion: 1.0\n",
  start_line: 1,
  end_line: 4,
  delimiters: ["---", "---"],
  metadata: { format: :yaml }
)

region.line_range    # => 1..4
region.line_count    # => 4
region.full_text     # => "---\ntitle: My Doc\n..."
region.contains_line?(2)  # => true
region.overlaps?(other)   # => false
```

### Base (Abstract Class)

Base class for implementing custom region detectors.

```ruby
class MyBlockDetector < Ast::Merge::Detector::Base
  def region_type
    :my_block
  end

  def detect_all(source)
    regions = []
    # Detection logic here...
    # Use build_region helper:
    regions << build_region(
      type: region_type,
      content: inner_content,
      start_line: start,
      end_line: end_line,
      delimiters: ["<<<", ">>>"],
      metadata: { custom: "data" }
    )
    regions
  end
end
```

### Built-in Detectors

#### FencedCodeBlock

Detects fenced code blocks with a specific language identifier.

```ruby
# Detect Ruby code blocks
detector = Ast::Merge::Detector::FencedCodeBlock.ruby
regions = detector.detect_all(markdown_source)

# Factory methods for common languages
Ast::Merge::Detector::FencedCodeBlock.ruby
Ast::Merge::Detector::FencedCodeBlock.yaml
Ast::Merge::Detector::FencedCodeBlock.json
Ast::Merge::Detector::FencedCodeBlock.bash

# Custom language with aliases
detector = Ast::Merge::Detector::FencedCodeBlock.new("typescript", aliases: ["ts"])
```

#### YamlFrontmatter

Detects YAML frontmatter at the beginning of a document.

```ruby
detector = Ast::Merge::Detector::YamlFrontmatter.new
regions = detector.detect_all(markdown_source)
# Detects content between --- delimiters at document start
```

#### TomlFrontmatter

Detects TOML frontmatter (Hugo-style) at the beginning of a document.

```ruby
detector = Ast::Merge::Detector::TomlFrontmatter.new
regions = detector.detect_all(markdown_source)
# Detects content between +++ delimiters at document start
```

### Mergeable (Module)

Mixin for adding region support to SmartMerger classes. Enables nested content merging where regions are extracted, merged with specialized mergers, then reintegrated.

```ruby
class MySmartMerger < Ast::Merge::SmartMergerBase
  include Ast::Merge::Detector::Mergeable
  
  def initialize(template, dest, regions: [], **options)
    super
    setup_regions(regions: regions)
  end
end

# Usage with region configuration
merger = MySmartMerger.new(
  template,
  destination,
  regions: [
    {
      detector: Ast::Merge::Detector::YamlFrontmatter.new,
      merger_class: Psych::Merge::SmartMerger,
      merger_options: { preserve_order: true }
    },
    {
      detector: Ast::Merge::Detector::FencedCodeBlock.ruby,
      merger_class: Prism::Merge::SmartMerger
    }
  ]
)
```

## When to Use Detectors

**Use text-based detectors when:**
- Working with raw text without parsing to AST
- Quick extraction from strings without parser dependencies
- Custom text processing requiring line-level precision
- Operating on source text directly (e.g., linters, formatters)

**Use native AST nodes when:**
- Working with parsed Markdown AST (markly, commonmarker)
- Integrating with `*-merge` gems that use native code block nodes
- Using tree_haver's unified backend API

## See Also

- [ast-merge README](../../../README.md) - Main documentation
- [Recipe namespace](../recipe/README.md) - YAML-based merge recipes
- [SmartMergerBase](../smart_merger_base.rb) - Base class that includes Mergeable

