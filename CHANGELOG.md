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

- `Ast::Merge::AstNode` now implements the TreeHaver::Node protocol for compatibility with tree_haver-based merge operations
  - Adds: `type`, `kind`, `text`, `start_byte`, `end_byte`, `start_point`, `end_point`, `children`, `child_count`, `child(index)`, `each`, `named?`, `structural?`, `has_error?`, `missing?`, `inner_node`
  - Adds `Point` struct compatible with `TreeHaver::Point`
  - Adds `SyntheticNode` alias for clarity (synthetic = not backed by a real parser)
- `Comment::Line`, `Comment::Block`, `Comment::Empty` now have explicit `type` methods
- `Text::LineNode` and `Text::WordNode` now inherit from `AstNode`, gaining TreeHaver::Node protocol compliance

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [1.0.0] - 2025-12-12

- TAG: [v1.0.0][1.0.0t]
- COVERAGE: 96.60% -- 2301/2382 lines in 44 files
- BRANCH COVERAGE: 86.00% -- 522/607 branches in 44 files
- 99.29% documented

### Added

- Initial release

[Unreleased]: https://github.com/kettle-rb/ast-merge/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/kettle-rb/ast-merge/compare/a63a4858cb229530c1706925bb209546695e8b3a...v1.0.0
[1.0.0t]: https://github.com/kettle-rb/ast-merge/tags/v1.0.0
