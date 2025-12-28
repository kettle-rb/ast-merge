# Ast::Merge::Comment

Language-agnostic comment parsing and representation for AST merge operations.

## Overview

The `Comment` namespace provides generic, language-agnostic comment representation that supports multiple comment syntax styles. This is used throughout the `*-merge` gem family to handle comment nodes consistently.

## Supported Styles

| Style | Syntax | Languages |
|-------|--------|-----------|
| `:hash_comment` | `# comment` | Ruby, Python, YAML, Shell, Perl |
| `:html_comment` | `<!-- comment -->` | HTML, XML, Markdown |
| `:c_style_line` | `// comment` | C, JavaScript, Go, Rust, Java |
| `:c_style_block` | `/* comment */` | C, JavaScript, CSS, Java |
| `:semicolon_comment` | `; comment` | Lisp, Clojure, Assembly, INI |
| `:double_dash_comment` | `-- comment` | SQL, Haskell, Lua |

## Components

### Style

Defines comment syntax patterns and delimiters.

```ruby
# Get style configuration
style = Ast::Merge::Comment::Style.get(:hash_comment)
style.line_prefix   # => "#"
style.block_start   # => nil (no block comments)

style = Ast::Merge::Comment::Style.get(:c_style_block)
style.block_start   # => "/*"
style.block_end     # => "*/"
```

### Line

Represents a single-line comment.

```ruby
comment = Ast::Merge::Comment::Line.new(
  content: "frozen_string_literal: true",
  line_number: 1,
  style: :hash_comment
)

comment.to_source  # => "# frozen_string_literal: true"
comment.type       # => :comment_line
```

### Block

Represents a multi-line block comment.

```ruby
comment = Ast::Merge::Comment::Block.new(
  content: "This is a\nmulti-line comment",
  start_line: 1,
  end_line: 3,
  style: :c_style_block
)

comment.to_source  # => "/* This is a\nmulti-line comment */"
comment.type       # => :comment_block
```

### Empty

Represents an empty/blank line (preserved during merging).

```ruby
empty = Ast::Merge::Comment::Empty.new(line_number: 5)
empty.to_source  # => ""
empty.type       # => :empty_line
```

### Parser

Parses source lines into comment nodes.

```ruby
# Parse Ruby-style comments
lines = ["# frozen_string_literal: true", "", "# Main comment"]
nodes = Ast::Merge::Comment::Parser.parse(lines, style: :hash_comment)

# Auto-detect style
lines = ["<!-- HTML comment -->"]
nodes = Ast::Merge::Comment::Parser.parse(lines, style: :auto)

# Parse with line numbers
nodes = Ast::Merge::Comment::Parser.parse(lines, start_line: 10)
```

## Usage in Merge Operations

Comment nodes implement the `TreeHaver::Node` protocol, making them compatible with all `*-merge` gems:

```ruby
comment.type        # Node type
comment.text        # Source text
comment.start_line  # Starting line number
comment.end_line    # Ending line number
comment.children    # Child nodes (usually empty)
```

## Freeze Markers

Comments are also used for freeze markers that prevent merging of specific sections:

```ruby
# In Ruby:
# ast-merge:freeze Reason for freezing
# ... frozen content ...
# ast-merge:unfreeze

# In Markdown:
<!-- ast-merge:freeze Reason for freezing -->
... frozen content ...
<!-- ast-merge:unfreeze -->
```

## See Also

- [ast-merge README](../../../README.md) - Main documentation
- [Freezable module](../freezable.rb) - Freeze marker handling
- [Text namespace](../text/README.md) - Plain text parsing

