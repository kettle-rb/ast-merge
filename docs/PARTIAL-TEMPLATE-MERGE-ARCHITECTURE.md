# Partial Template Merge Architecture Recommendations

## Current State Analysis

The `bin/update_gem_family_section` script demonstrates a partial template merge use case where:
1. A template section (GEM_FAMILY_SECTION.md) is merged into multiple README files
2. Only files that already contain the section should be updated
3. New link reference definitions should be added to existing sections
4. The rest of each README should remain untouched

**Current Implementation: ~511 lines of code**

### Pain Points Identified

1. **Verbose signature generator** (~60 lines): Must manually check node types and text patterns
2. **Redundant node typing** (~50 lines): Almost duplicates the signature generator logic
3. **Complex text extraction** (~30 lines): `extract_node_text` handles multiple node types
4. **Scattered section identification**: Logic spread across multiple lambdas
5. **No reusable patterns**: Each partial merge requires writing similar boilerplate
6. **TableTennis not used**: Script could benefit from tabular output for results
7. **Redundant link_refs list**: The template already contains the link refs!

---

## Revised Architecture: Section Query Language

### Key Insight: Template IS the Section Definition

The partial template file already defines:
- What nodes are in the section (by their presence)
- The order of nodes
- The link reference definitions (no need to list them separately!)

What we need is a way to:
1. **Identify where the section starts** in the destination
2. **Identify where the section ends** (boundary)
3. **Merge the template section into that region**

### Understanding the AST Structure

**Important: Link Reference Definitions are "Invisible" to CommonMark Parsers**

CommonMark parsers (Markly, Commonmarker) **consume** link reference definitions during parsing.
They don't appear in the AST - instead, they're used to resolve `[label]` references into links.

```ruby
# Markly's raw AST types (note: NO link_definition!)
[:code, :document, :header, :link, :paragraph, :softbreak, :strong, :text]
```

The `Markdown::Merge::LinkDefinitionNode` class exists to solve this:
1. After parsing, markdown-merge finds "gap lines" (lines not covered by any AST node)
2. Gap lines are checked against a regex to detect link reference definitions
3. Matching lines become `LinkDefinitionNode` objects in the statement list

This is why the flattened statement list shows `link_definition` nodes even though Markly doesn't produce them.

---

Markdown-merge flattens the AST to a list of "statements" (top-level block nodes + synthetic nodes):

```
Flattened GEM_FAMILY_SECTION.md:
 0: heading              "### The `*-merge` Gem Family"
 1: gap_line
 2: paragraph            "The `*-merge` gem family provides..."
 3: gap_line
 4: table                "| Gem | Format | Parser Backend(s) |..."
 5: gap_line
 6: paragraph            "**Example implementations**..."
 7: gap_line
 8: table                "| Gem | Purpose | Description |..."
 9: gap_line
10-35: link_definition   "[tree_haver]:", "[ast-merge]:", etc.
36-37: gap_line
```

The section is implicitly bounded by:
- **Start**: The H3 heading (index 0)
- **End**: Before the next heading of same-or-higher level, OR end of document

### Proposed: Section Query Grammar

A mini query language for defining sections on the ast-merge node tree:

### Current State: Tree Navigation in Flattened Statements

Investigation reveals a split in how nodes track their tree position:

```
=== Checking synthetic vs parser nodes ===
0: heading    (Wrapper → Markly::Node)    has_parent=true,  has_next=true
1: gap_line   (GapLineNode)               has_parent=false, has_next=false
2: paragraph  (Wrapper → Markly::Node)    has_parent=true,  has_next=true
3: gap_line   (GapLineNode)               has_parent=false, has_next=false
4: heading    (Wrapper → Markly::Node)    has_parent=true,  has_next=true
...
```

**Parser-backed nodes** (Markly::Node, etc.):
- Retain tree navigation via `inner_node.parent`, `inner_node.next`, `inner_node.previous`
- Know their position in the original AST

**Synthetic nodes** (GapLineNode, LinkDefinitionNode, FreezeNode):
- Have NO tree navigation
- Created independently from gap line detection or freeze marker parsing
- Only know their line numbers, not their relationship to other nodes

**The Problem**: When we flatten to a statement list, we lose the implicit sibling
relationships. We can't easily ask "what's the next statement?" without array indexing.

### IMPLEMENTED: NavigableStatement, InjectionPoint, InjectionPointFinder

These classes are now implemented in `lib/ast/merge/navigable_statement.rb`.

#### NavigableStatement

Wraps any node with uniform navigation (language-agnostic):

```ruby
# Build linked list from raw statements
statements = Ast::Merge::NavigableStatement.build_list(analysis.statements)

# Flat navigation (always works)
stmt.next           # => next in list
stmt.previous       # => previous in list
stmt.index          # => array position

# Tree navigation (when available)
stmt.tree_parent    # => parent in original AST
stmt.tree_next      # => next sibling in original AST
stmt.synthetic?     # => true if no tree navigation

# Node matching (language-agnostic)
stmt.type?(:class)              # => check type
stmt.text_matches?(/def \w+/)   # => check text pattern
stmt.node_attribute(:name)      # => get parser-specific attribute

# Find statements
NavigableStatement.find_first(statements, type: :class)
NavigableStatement.find_matching(statements, text: /FOO/)
```

#### InjectionPoint

Defines where content can be injected (language-agnostic):

```ruby
# Positions for injection
:before       # Insert as previous sibling
:after        # Insert as next sibling
:first_child  # Insert as first child of anchor
:last_child   # Insert as last child of anchor
:replace      # Replace anchor (with optional boundary)

# Examples
point = InjectionPoint.new(anchor: class_stmt, position: :first_child)
point = InjectionPoint.new(anchor: const_stmt, position: :replace)
point = InjectionPoint.new(
  anchor: start_stmt,
  position: :replace,
  boundary: end_stmt,
)

# Query the point
point.replacement?       # => is this a replacement?
point.child_injection?   # => injecting as child?
point.replaced_statements  # => all statements being replaced
```

#### InjectionPointFinder

Finds injection points by matching criteria:

```ruby
finder = InjectionPointFinder.new(statements)

# Find where to inject constants in a Ruby class
point = finder.find(type: :class, text: /class Foo/, position: :first_child)

# Find and replace a specific constant
point = finder.find(type: :constant, text: /DAR\s*=/, position: :replace)

# Find all constants (for batch operations)
points = finder.find_all(type: :constant, position: :replace)
```

---

### Language-Agnostic Partial Template Merging

The injection point system works with ANY `*-merge` gem:

#### Ruby Example (prism-merge)

Template:
```ruby
DAR = 1
FAR = 42
GOO = 67
```

Destination:
```ruby
class Choo
  DAR = 2
  attr_accessor :stars
end
```

Recipe:
```yaml
name: inject_constants
template: constants.rb.template

injection:
  # Find the class
  anchor:
    type: class
    text: /class Choo/

  # Inject as first child (top of class body)
  position: first_child

  # For existing constants, update them
  merge:
    match_by: [type, name]  # Match constants by type and name
    preference: template     # Template wins for conflicts
    add_missing: true        # Add constants not in destination
```

#### Markdown Example (markly-merge)

Template:
```markdown
### The `*-merge` Gem Family

This is the gem family section content...
```

Recipe:
```yaml
name: gem_family_section
template: GEM_FAMILY_SECTION.md

injection:
  anchor:
    type: heading
    text: /Gem Family/

  # Replace from heading until next heading of same level
  position: replace
  boundary:
    type: heading
    level_lte: 3  # heading level <= 3

when_missing: skip
```

#### YAML Example (psych-merge)

Template:
```yaml
database:
  host: localhost
  port: 5432
```

Recipe:
```yaml
name: database_config
template: database.yml.template

injection:
  anchor:
    type: mapping_key
    text: database

  position: replace

  merge:
    deep: true  # Deep merge nested structures
```

---

## Recipe File Format

The recipe format uses the implemented `InjectionPoint` system:

```yaml
# .merge-recipes/gem_family_section.yml
name: gem_family_section
description: Update gem family section in README files

template: GEM_FAMILY_SECTION.md

targets:
  - "README.md"
  - "vendor/*/README.md"

# Define the injection point using InjectionPointFinder criteria
injection:
  anchor:
    type: heading
    text: /Gem Family/
  position: replace
  boundary:
    type: heading
    same_or_shallower: true

merge:
  preference: template

  # Script references - loaded from gem_family_section/ folder
  add_missing: add_missing_filter.rb
  signature_generator: signature_generator.rb
  node_typing:
    heading: typing/heading.rb
    table: typing/table.rb
    paragraph: typing/paragraph.rb
    link_definition: typing/link_definition.rb

when_missing: skip
```

### Script Reference Convention

Recipes can reference Ruby scripts that return callable objects (lambda, proc, or object with `#call`):

1. **Folder Convention**: Scripts live in a folder matching the recipe basename
   - Recipe: `.merge-recipes/my_recipe.yml`
   - Scripts: `.merge-recipes/my_recipe/*.rb`

2. **Script Format**: Each script file must return a callable:
   ```ruby
   # .merge-recipes/my_recipe/signature_generator.rb
lambda do |node|
  # Return signature array or nil
  text = node.to_s
  if text.include?("special")
    [:special, :node]
  end
end
   ```

3. **Inline Lambdas**: Simple expressions can be inline in YAML:
   ```yaml
   merge:
     add_missing: "->(node, entry) { entry[:signature]&.first == :gem_family }"
   ```

### The Script (Using Implemented Classes)

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "ast-merge"
require "markly/merge"
require "table_tennis"

template = File.read("GEM_FAMILY_SECTION.md")
t_analysis = Markly::Merge::FileAnalysis.new(template)
t_statements = Ast::Merge::NavigableStatement.build_list(t_analysis.statements)

results = []

Dir["README.md", "vendor/*/README.md"].each do |path|
  destination = File.read(path)
  d_analysis = Markly::Merge::FileAnalysis.new(destination)
  d_statements = Ast::Merge::NavigableStatement.build_list(d_analysis.statements)

  # Find injection point in destination
  finder = Ast::Merge::InjectionPointFinder.new(d_statements)
  point = finder.find(type: :heading, text: /Gem Family/, position: :replace)

  results << if point
    # Perform merge at injection point
    { path: path, status: :updated }
  else
    { path: path, status: :skipped }
  end
end

puts TableTennis.new(results)
```

---

## Implementation Status

### ✅ Phase 0: Foundation (COMPLETE)

- [x] `Ast::Merge::NavigableStatement` - uniform node navigation wrapper
- [x] `Ast::Merge::InjectionPoint` - defines where to inject content
- [x] `Ast::Merge::InjectionPointFinder` - finds injection points
- [x] Unit tests: 48 specs in `spec/ast/merge/navigable_statement_spec.rb`

### ✅ Phase 1: Recipe System (COMPLETE)

- [x] `Ast::Merge::Recipe` for YAML loading
- [x] `Ast::Merge::RecipeRunner` for execution
- [x] CLI: `bin/ast-merge-recipe`
- [x] Unit tests: 30 specs in `spec/ast/merge/recipe_spec.rb` and `recipe_runner_spec.rb`

### ✅ Phase 2: PartialTemplateMerger (COMPLETE)

- [x] `Ast::Merge::PartialTemplateMerger` class
  - Section-based merging using anchor/boundary matchers
  - `replace_mode` for full replacement vs intelligent merge
  - Custom `signature_generator` and `node_typing` support
  - `when_missing` behavior: `:skip`, `:append`, `:prepend`
- [x] Integration with Recipe and RecipeRunner
- [x] Unit tests: 25 specs in `spec/ast/merge/partial_template_merger_spec.rb`

### 🔲 Phase 3: Parser Integration (TODO)

- [ ] Verify NavigableStatement works with all `*-merge` gems

---

## Design Decisions

### 1. Language-Agnostic Design

The `InjectionPoint` system works with ANY `*-merge` gem because it operates on the
unified `NavigableStatement` interface.

### 2. Tree-Depth Based Boundaries

Instead of language-specific concepts (like "heading level 3"), we use tree hierarchy:

```yaml
# Language-agnostic boundary detection
boundary:
  type: heading
  same_or_shallower: true  # Next sibling at same or higher tree level
```

This works because:
- In Markdown: H3 has depth 2, H2 has depth 1 → H2 ends H3 section
- In Ruby: method inside class has depth 1, next method has same depth
- In YAML: nested key has depth N, sibling key has same depth

The `NavigableStatement#tree_depth` method calculates depth by counting parent hops,
and `same_or_shallower_than?` checks if a node ends a section.

### 3. Injection vs Sections

Instead of markdown-specific "sections", we use language-agnostic "injection points":

| Old Concept | New Concept |
|-------------|-------------|
| Section start | Injection anchor |
| Section boundary | Replacement boundary |
| group_by_heading | InjectionPointFinder.find_all |
| heading level | tree_depth |

### 4. Positions

| Position | Use Case |
|----------|----------|
| `:before` | Insert sibling before anchor |
| `:after` | Insert sibling after anchor |
| `:first_child` | Insert as first child of anchor |
| `:last_child` | Insert as last child of anchor |
| `:replace` | Replace anchor (with optional boundary) |

---

## Summary

| Concept | Old Approach | New Approach |
|---------|--------------|--------------|
| Section definition | Manual lambdas | InjectionPoint with anchor/boundary |
| Node matching | Hardcoded patterns | NavigableStatement.find_matching |
| Finding injection location | Custom code | InjectionPointFinder |
| Position types | Implicit | Explicit: before/after/first_child/last_child/replace |
| Node navigation | Array indexing | NavigableStatement with prev/next + tree access |
| Language support | Markdown-only | Any `*-merge` gem |

**Foundation implemented: NavigableStatement, InjectionPoint, InjectionPointFinder**

**Next: Recipe system and PartialTemplateMerger**
