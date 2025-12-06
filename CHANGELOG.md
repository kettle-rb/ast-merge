## [Unreleased]

### Added

- `Ast::Merge::FileAnalysisBase` module - shared base functionality for all FileAnalysis classes:
  - `freeze_blocks` - get all freeze block nodes
  - `in_freeze_block?(line_num)` - check if line is in freeze block
  - `freeze_block_at(line_num)` - get freeze block containing line
  - `signature_at(index)` - get signature for statement at index
  - `line_at(line_num)` - get raw line content
  - `normalized_line(line_num)` - get whitespace-trimmed line
  - `generate_signature(node)` - generate signature with custom generator support
  - `fallthrough_node?(value)` - check if value is a fallthrough node
  - `compute_node_signature(node)` - abstract method for default signatures
- `Ast::Merge::MergerConfig` class - standardized configuration for SmartMerger:
  - `signature_match_preference` - :destination or :template
  - `add_template_only_nodes` - boolean
  - `freeze_token` - custom freeze token string
  - `signature_generator` - custom signature generator proc
  - `prefer_destination?` / `prefer_template?` - convenience predicates
  - `to_h(default_freeze_token:)` - convert to SmartMerger kwargs
  - `with(**options)` - create modified copy
  - `MergerConfig.destination_wins` / `MergerConfig.template_wins` - factory presets
- Base error classes: `ParseError`, `TemplateParseError`, `DestinationParseError`
  - Flexible initialization with optional `errors:` and `content:` kwargs

### BREAKING

- All *-merge gems now require their FileAnalysis classes to include `Ast::Merge::FileAnalysisBase`
- All *-merge gems now inherit error classes from `Ast::Merge` base classes

## [0.1.0] - 2025-12-05

- Initial release
