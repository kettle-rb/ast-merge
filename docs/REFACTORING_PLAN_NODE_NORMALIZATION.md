# Refactoring Plan: Node Normalization Architecture

## Core Insight

**The problem is not NavigableStatement itself, but that it doesn't trust its inner nodes to conform to a standard API.**

NavigableStatement has two responsibilities:
1. **Flat list navigation** (prev/next/index) - LEGITIMATE
2. **Node API normalization** (conditional text extraction) - SHOULD NOT BE HERE

## Current Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        TreeHaver                                 │
│  - TreeHaver::Node (unified API for tree-sitter backends)        │
│  - TreeHaver::Backends::Markly::Node (has #text)                 │
│  - TreeHaver::Backends::Commonmarker::Node (has #text)           │
│  - TreeHaver::Backends::Prism::Node (has #text via #slice)       │
│  - TreeHaver::Backends::Psych::Node (has #text)                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ nodes passed to
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        ast-merge                                 │
│  - NavigableStatement (wraps nodes for flat list navigation)     │
│    - #text has conditional logic (PROBLEM!)                      │
│    - Should just delegate to node.text                           │
└─────────────────────────────────────────────────────────────────┘
```

## The Fix

### TreeHaver's Responsibility
All TreeHaver backends MUST provide a unified Node API:
- `#text` - Returns text content as String
- `#type` - Returns node type as String
- `#source_position` - Returns position info as Hash
- `#children` - Returns child nodes

**This is already implemented in TreeHaver backends!**

### ast-merge's Responsibility (NavigableStatement)
NavigableStatement should:
1. Provide flat list navigation (prev/next/index)
2. **Simply delegate `#text` to `node.text`** - no conditionals!

```ruby
# CURRENT (bad)
def text
  if node.respond_to?(:to_plaintext)
    node.to_plaintext.to_s
  elsif node.respond_to?(:to_commonmark)
    node.to_commonmark.to_s
  elsif node.respond_to?(:slice)
    node.slice.to_s
  elsif node.respond_to?(:text)
    node.text.to_s
  else
    node.to_s
  end
end

# FIXED (good)
def text
  node.text.to_s
end
```

### Each *-merge Gem's Responsibility
Ensure their FileAnalysis returns nodes that conform to the TreeHaver Node API.

For TreeHaver-based parsers (markdown, json, toml, bash, etc.):
- Already done! TreeHaver backends provide the API.

For non-TreeHaver parsers (if any remain):
- Must wrap nodes in adapters that provide `#text`, `#type`, etc.
- OR migrate to use TreeHaver backends

## Concept of "Statement-Level" Nodes

**Statement-level is a merge concept, not a parser concept.**

- TreeHaver knows about tree structure (parent/child)
- ast-merge knows about statements (top-level mergeable units)
- NavigableStatement wraps TreeHaver nodes to add flat list navigation

This separation is correct. The issue was only that NavigableStatement was duplicating API normalization that TreeHaver already provides.

## Action Items

### Completed
- [x] Updated signature_generator.rb to use `node.text` directly
- [x] Updated typing scripts to use `node.text` directly
- [x] Removed NavigableStatement wrapping from file_analyzable.rb
- [x] Removed NavigableStatement wrapping from node_typing.rb
- [x] Simplified `NavigableStatement#text` to just `node.text.to_s`
- [x] Simplified `ContentMatchRefiner#extract_content` to just `node.text.to_s`
- [x] Fixed TreeHaver Markly backend `Node#text` to handle container nodes (headings, paragraphs)
- [x] Fixed TreeHaver Commonmarker backend `Node#text` to handle container nodes
- [x] Created `TestableNode` spec helper for testing with real TreeHaver::Node behavior
- [x] Updated specs to use `TestableNode` instead of fragile mocks
- [x] Updated specs to expect string types (TreeHaver returns strings, not symbols)

### Remaining
- [ ] Run full test suite to verify all fixes work together
- [ ] Consider adding TreeHaver backend validator check for `#text` method returning non-empty for container nodes

## Key Principles

1. **TreeHaver provides the unified Node API** - all backends must conform
2. **ast-merge trusts the TreeHaver API** - no conditional fallbacks
3. **NavigableStatement is for navigation only** - not for API normalization
4. **Statement-level is a merge concept** - stays in ast-merge, not TreeHaver
