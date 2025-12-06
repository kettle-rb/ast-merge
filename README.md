# 🔧 Ast::Merge

Ast::Merge provides the shared infrastructure for intelligent AST-based file merging. It serves as the foundation library for format-specific merge implementations like [prism-merge](https://github.com/kettle-rb/prism-merge), [psych-merge](https://github.com/kettle-rb/psych-merge), [rbs-merge](https://github.com/kettle-rb/rbs-merge), and others.

## 🌻 Synopsis

Ast::Merge is **not typically used directly** - instead, use one of the format-specific gems built on top of it:

| Gem | File Type | Parser |
|-----|-----------|--------|
| [prism-merge](https://github.com/kettle-rb/prism-merge) | Ruby (`.rb`) | Prism |
| [psych-merge](https://github.com/kettle-rb/psych-merge) | YAML (`.yml`, `.yaml`) | Psych |
| [rbs-merge](https://github.com/kettle-rb/rbs-merge) | RBS (`.rbs`) | RBS |
| [dotenv-merge](https://github.com/kettle-rb/dotenv-merge) | Dotenv (`.env`) | Custom |
| [json-merge](https://github.com/kettle-rb/json-merge) | JSON/JSONC (`.json`) | tree-sitter |
| [bash-merge](https://github.com/kettle-rb/bash-merge) | Bash (`.sh`) | tree-sitter |
| [commonmarker-merge](https://github.com/kettle-rb/commonmarker-merge) | Markdown (`.md`) | CommonMarker |

### What Ast::Merge Provides

- **Base Classes**: `FreezeNode`, `MergeResult` base classes with unified constructors
- **Shared Modules**: `FileAnalysisBase`, `MergerConfig`, `DebugLogger`
- **Freeze Block Support**: Configurable marker patterns for multiple comment syntaxes
- **Error Classes**: `ParseError`, `TemplateParseError`, `DestinationParseError`
- **RSpec Shared Examples**: Test helpers for implementing new merge gems

### Supported Comment Patterns

| Pattern Type | Start Marker | End Marker | Languages |
|--------------|--------------|------------|-----------|
| `:hash_comment` | `# token:freeze` | `# token:unfreeze` | Ruby, Python, YAML, Bash |
| `:html_comment` | `<!-- token:freeze -->` | `<!-- token:unfreeze -->` | HTML, Markdown |
| `:c_style_line` | `// token:freeze` | `// token:unfreeze` | JavaScript, TypeScript, JSON |
| `:c_style_block` | `/* token:freeze */` | `/* token:unfreeze */` | CSS, C, Java |

### Creating a New Merge Gem

```ruby
require "ast/merge"

module MyFormat
  module Merge
    class FreezeNode < Ast::Merge::FreezeNode
      # Override methods as needed for your format
    end

    class MergeResult < Ast::Merge::MergeResult
      # Add format-specific output methods
      def to_my_format
        content_string
      end
    end

    class FileAnalysis
      include Ast::Merge::FileAnalysisBase

      # Implement required methods:
      # - compute_node_signature(node)
      # - extract_freeze_blocks
    end

    class SmartMerger
      include Ast::Merge::MergerConfig

      # Implement merge logic
    end
  end
end
```

## ✨ Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add ast-merge
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install ast-merge
```

## ⚙️ Configuration



## 🔧 Basic Usage

### Using Shared Examples in Tests

```ruby
# spec/spec_helper.rb
require "ast/merge/rspec/shared_examples"

# spec/my_format/merge/freeze_node_spec.rb
RSpec.describe MyFormat::Merge::FreezeNode do
  it_behaves_like "Ast::Merge::FreezeNode" do
    let(:freeze_node_class) { described_class }
    let(:default_pattern_type) { :hash_comment }
    let(:build_freeze_node) do
      lambda { |start_line:, end_line:, **opts|
        # Build a freeze node for your format
      }
    end
  end
end
```

### Available Shared Examples

- `"Ast::Merge::FreezeNode"` - Tests for FreezeNode implementations
- `"Ast::Merge::MergeResult"` - Tests for MergeResult implementations
- `"Ast::Merge::DebugLogger"` - Tests for DebugLogger implementations
- `"Ast::Merge::FileAnalysisBase"` - Tests for FileAnalysis implementations
- `"Ast::Merge::MergerConfig"` - Tests for SmartMerger implementations

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kettle-rb/ast-merge. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/kettle-rb/ast-merge/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ast::Merge project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/kettle-rb/ast-merge/blob/main/CODE_OF_CONDUCT.md).
