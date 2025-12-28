# Ast::Merge::Text

Plain text-based AST parsing and merging for any text file format.

## Overview

The `Text` namespace provides a simple line/word-based AST that can be used with any text file. This serves as:

1. **Reference Implementation** - A complete example of how to build a `*-merge` gem
2. **Testing Tool** - For validating merge behavior with simple text
3. **Fallback Parser** - When no specialized parser is available

## Components

### LineNode

Represents a single line of text.

```ruby
line = Ast::Merge::Text::LineNode.new(
  content: "Hello, world!",
  line_number: 1,
)

line.type       # => :line
line.text       # => "Hello, world!"
line.start_line # => 1
line.children   # => [WordNode, WordNode]
```

### WordNode

Represents a single word within a line.

```ruby
word = Ast::Merge::Text::WordNode.new(
  content: "Hello",
  line_number: 1,
  column: 0,
)

word.type  # => :word
word.text  # => "Hello"
```

### FileAnalysis

Parses text content into an AST of lines and words.

```ruby
content = "Line one\nLine two\nLine three"
analysis = Ast::Merge::Text::FileAnalysis.new(content)

analysis.statements      # => [LineNode, LineNode, LineNode]
analysis.line_count      # => 3
analysis.valid?          # => true
analysis.content         # => original content
```

### SmartMerger

Merges two text documents intelligently.

```ruby
template = "Line one\nLine two\nLine three"
dest = "Line one modified\nLine two\nCustom line"

merger = Ast::Merge::Text::SmartMerger.new(
  template,
  dest,
  preference: :destination,
  add_template_only_nodes: true,
)

result = merger.merge
# => "Line one modified\nLine two\nLine three\nCustom line"
```

### ConflictResolver

Resolves conflicts between matching lines.

```ruby
resolver = Ast::Merge::Text::ConflictResolver.new(
  preference: :template,
)

resolution = resolver.resolve(
  template_node,
  dest_node,
  template_index: 0,
  dest_index: 0,
)
# => { decision: :template, source: :template, reason: "..." }
```

### MergeResult

Contains the result of a text merge operation.

```ruby
result = merger.merge_result

result.content       # => merged text
result.stats         # => { nodes_added: 1, nodes_removed: 0, ... }
result.changed?      # => true
result.frozen_blocks # => [] or freeze block info
```

### Section & SectionSplitter

Split text into logical sections for section-aware merging.

```ruby
splitter = Ast::Merge::Text::SectionSplitter.new(
  section_pattern: /^##\s+/,  # Split on markdown H2 headings
)

sections = splitter.split(content)
# => [Section, Section, ...]
```

## Usage Example

```ruby
require "ast/merge/text"

template = <<~TEXT
  # Configuration File

  setting1 = value1
  setting2 = value2
  setting3 = value3
TEXT

destination = <<~TEXT
  # Configuration File

  setting1 = custom_value
  setting2 = value2
  # Custom comment
  custom_setting = my_value
TEXT

merger = Ast::Merge::Text::SmartMerger.new(
  template,
  destination,
  preference: :destination,
  add_template_only_nodes: true,
)

result = merger.merge_result
puts result.content
# Merges intelligently, keeping custom values and adding missing settings
```

## Freeze Markers

Text files support freeze markers to prevent sections from being merged:

```
# text-merge:freeze Don't touch this section
Frozen content here
Will not be changed by merge
# text-merge:unfreeze
```

## See Also

- [ast-merge README](../../../README.md) - Main documentation
- [Comment namespace](../comment/README.md) - Comment parsing
- [SmartMergerBase](../smart_merger_base.rb) - Base merger class

