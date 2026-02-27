# Merge Approach: AST-Merge Gem Family

## Core Design Principle

> Two distinct lines in the input must remain two distinct lines in the output.
> Signatures help *match* nodes — they do not determine *cardinality*.
> The AST tree structure provides the structural context that prevents false merging.

## How Signature Matching Works

Every `*-merge` gem follows this general algorithm:

1. **Parse** both template and destination files into ASTs
2. **Generate signatures** for each top-level node (e.g., `[:def, :greet]`, `[:pair, "name"]`)
3. **Build a signature map**: `signature → [{node:, index:}, ...]`  (stores ALL occurrences)
4. **First pass** (destination order): Walk destination nodes, find matching template nodes
   by signature via cursor-based positional matching
5. **Second pass**: Add any remaining unmatched template nodes (if `add_template_only_nodes: true`)

### Cursor-Based Positional Matching

When multiple nodes share the same signature, they are matched **1:1 in order**:

```
Template:           Destination:
  echo "Foo"  ←→     echo "Foo"    (1st ←→ 1st)
  echo "Foo"  ←→     echo "Foo"    (2nd ←→ 2nd)
  echo "Bar"          echo "Bar"
                      echo "Baz"    (dest-only, preserved)
```

This uses a per-signature cursor (`sig_cursor`) and a set of consumed template
indices (`consumed_template_indices`), NOT a simple "processed signatures" Set.

### Recursive Body Merging

For structured formats, containers are merged recursively:

```ruby
module Foo
  class Bar
    attr_accessor :fizz    # ← scoped to Bar's body
  end
  class Buzz
    attr_accessor :fizz    # ← scoped to Buzz's body (NOT collapsed with Bar's)
  end
end
```

When `class Bar` matches between template and destination, their **bodies** are
extracted and merged in a **separate recursive call**. The recursion itself provides
tree-path scoping — signatures are only compared within the same container.

## Per-Gem Merge Approaches

### prism-merge (Ruby)

- **Strategy**: Inline merge in `SmartMerger#perform_merge`
- **Recursive merge**: Yes — class, module, singleton class, call-with-block bodies
- **Signature scoping**: Recursive body merging scopes signatures to containers
- **Duplicate handling**: Cursor-based (`build_signature_map` stores arrays)
- **Real scenario**: Two `attr_reader :name` in different classes are never confused
  because they're merged in separate recursive calls. Two `gem "foo"` at the same
  level in a Gemfile are matched positionally.

### bash-merge (Bash/Shell)

- **Strategy**: Inline merge in `SmartMerger#perform_merge` (no ConflictResolver)
- **Recursive merge**: No (bash is flat; functions are atomic)
- **Signature scoping**: Command signatures include arguments (`[:command, "echo", ['"Foo"']]`)
- **Duplicate handling**: Cursor-based (`build_indexed_signature_map`)
- **Real scenario**: `PATH_add exe` and `PATH_add bin` get distinct signatures.
  Two `echo "Foo"` lines are matched positionally, not collapsed.

### psych-merge (YAML)

- **Strategy**: ConflictResolver with cursor-based matching
- **Recursive merge**: Yes — mapping entries and sequences
- **Signature scoping**: Fresh cursor per recursive level
- **Duplicate handling**: Cursor-based (consumed indices + sig_cursor)
- **Real scenario**: In a GitHub Actions workflow:
  ```yaml
  jobs:
    build:
      steps:
        - name: Checkout    # scoped to build.steps
    test:
      steps:
        - name: Checkout    # scoped to test.steps (different recursive call)
  ```
  The two `name: Checkout` entries are in different branches of the tree,
  merged in separate recursive calls. Within a single mapping, duplicate keys
  are invalid per YAML spec, but the cursor ensures correctness regardless.

### json-merge / jsonc-merge (JSON / JSONC)

- **Strategy**: ConflictResolver with cursor-based matching
- **Recursive merge**: Yes — object pairs, nested objects
- **Signature scoping**: Recursive `merge_node_lists_to_emitter` calls
- **Duplicate handling**: Cursor-based (consumed indices + sig_cursor)
- **Real scenario**: In a `tsconfig.json`:
  ```json
  {
    "compilerOptions": {
      "target": "ES2020"
    },
    "references": [
      {"path": "./packages/core"},
      {"path": "./packages/web"}
    ]
  }
  ```
  `compilerOptions` and `references` are at the same level and get distinct
  signatures. Nested objects under `compilerOptions` are merged recursively.
  JSON forbids duplicate keys per RFC 7159, but arrays are handled via
  union semantics.

### toml-merge (TOML)

- **Strategy**: ConflictResolver with cursor-based matching
- **Recursive merge**: Yes — table contents
- **Signature scoping**: Recursive `merge_node_lists_to_emitter` calls
- **Duplicate handling**: Cursor-based (consumed indices + sig_cursor)
- **Real scenario**: TOML `[[array_of_tables]]` can legitimately repeat:
  ```toml
  [[fruits]]
  name = "apple"

  [[fruits]]
  name = "banana"
  ```
  The old Set-based approach would have collapsed these into one entry.
  Cursor-based matching preserves both.

### dotenv-merge (dotenv)

- **Strategy**: Alignment-based merge in `SmartMerger#align_statements`
- **Recursive merge**: No (dotenv is flat key-value)
- **Signature scoping**: N/A (single level)
- **Duplicate handling**: Cursor-based (`build_signature_map` stores arrays)
- **Real scenario**: While unusual, a dotenv file could have:
  ```
  PATH=/usr/bin
  PATH=/usr/local/bin
  ```
  Both lines are preserved and matched positionally.
