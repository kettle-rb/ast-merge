# Changelog

[![SemVer 2.0.0][📌semver-img]][📌semver] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog]

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][📗keep-changelog],
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html),
and [yes][📌major-versions-not-sacred], platform and engine support are part of the [public API][📌semver-breaking].
Please file a bug if you notice a violation of semantic versioning.

[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-FFDD67.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-FFDD67.svg?style=flat

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

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [0.1.0] - 2025-12-05

- Initial release
