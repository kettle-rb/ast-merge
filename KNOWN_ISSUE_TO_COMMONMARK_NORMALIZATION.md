# Known Issue: to_commonmark Normalization

## Problem

Both Markly (cmark-gfm) and Commonmarker (comrak) normalize markdown when rendering via `to_commonmark`:

1. **Link reference definitions are converted to inline links**
   - Input: `[text][ref]` with `[ref]: https://example.com`
   - Output: `[text](https://example.com)`
   - The link reference definitions are lost

2. **Table formatting is normalized**
   - Column padding/alignment is stripped
   - Separator rows become minimal (`| --- |` instead of `|----------|`)

## Impact

When merging markdown files that use link reference definitions:
- The merged output has all links converted to inline format
- Link reference definitions at the end of the document are lost
- Table formatting becomes inconsistent with source

## Root Cause

This is a fundamental behavior of CommonMark parsers:
- The AST represents the **semantic** structure, not the **textual** format
- `to_commonmark` renders from the AST, not from source text
- Link references are resolved during parsing; the AST only contains the resolved URLs

## Solution Implemented

### Source-Based Rendering (in ast-merge)

`PartialTemplateMerger#node_to_text` now prefers source-based extraction:

```ruby
def node_to_text(node, analysis = nil)
  inner = unwrap_node(node)

  # Prefer source extraction over to_commonmark
  if analysis&.respond_to?(:source_range)
    pos = inner.source_position if inner.respond_to?(:source_position)
    if pos && pos[:start_line] && pos[:end_line]
      source_text = analysis.source_range(pos[:start_line], pos[:end_line])
      return source_text + "\n" unless source_text.empty?
    end
  end

  # Fallback to to_commonmark (for nodes without source position)
  inner.respond_to?(:to_commonmark) ? inner.to_commonmark.to_s : inner.to_s
end
```

**Benefits:**
- Preserves exact original formatting
- Link references remain as references
- Table padding is preserved
- Works with any parser that provides source positions

**Requirements:**
- The analysis object must implement `source_range(start_line, end_line)`
- Nodes must provide `source_position` with `:start_line` and `:end_line`

### Link Reference Definition Preservation (in markdown-merge)

`markdown-merge` already handles link reference definitions through `LinkDefinitionNode`:
- Detects "gap lines" not covered by parser nodes
- Parses link reference definitions into `LinkDefinitionNode` instances
- These are preserved as separate statements in the merge

## Related Files

- `lib/ast/merge/partial_template_merger.rb` - Source-based rendering implementation
- `vendor/markdown-merge/lib/markdown/merge/file_analysis_base.rb` - `source_range` method
- `vendor/markdown-merge/lib/markdown/merge/link_definition_node.rb` - Link definition preservation
- `spec/integration/link_reference_preservation_spec.rb` - Regression test
- `spec/integration/table_formatting_preservation_spec.rb` - Regression test

