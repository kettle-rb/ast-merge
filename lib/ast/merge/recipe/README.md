# Ast::Merge::Recipe

`Ast::Merge::Recipe` provides declarative merge configuration that can live in YAML instead of Ruby call sites.

## The four pieces

### `Preset`

`Ast::Merge::Recipe::Preset` stores reusable merge options such as:

- `preference`
- `add_missing`
- `signature_generator`
- `node_typing`
- `match_refiner`
- `freeze_token`
- `normalize_whitespace`
- `rehydrate_link_references`

Use `Preset#to_h` when you want to pass those options directly to a format-specific `SmartMerger`.

```ruby
preset = Ast::Merge::Recipe::Preset.load("recipes/my_merge.yml")
options = preset.to_h
```

### `Config`

`Ast::Merge::Recipe::Config` extends `Preset` with file-oriented recipe data:

- `template`
- `targets`
- `injection`
- `when_missing`

It also resolves template paths and expands target globs relative to the recipe file.

### `Runner`

`Ast::Merge::Recipe::Runner` executes a `Config` against target files.

In the stock `ast-merge` gem, the built-in runner supports Markdown partial-template flows through:

- `parser: :markly`
- `parser: :commonmarker`

For other formats, the stable API in this gem is still `Preset#to_h`; callers pass those options to the format-specific merger they are already using.

### `ScriptLoader`

`Ast::Merge::Recipe::ScriptLoader` loads companion Ruby scripts referenced by a recipe.

A recipe named `my_recipe.yml` looks for scripts in a sibling directory named `my_recipe/`.

## Minimal preset example

```yaml
name: my_merge
parser: psych
merge:
  preference: destination
  add_missing: true
freeze_token: my-project
```

```ruby
preset = Ast::Merge::Recipe::Preset.load("recipes/my_merge.yml")
merger = Psych::Merge::SmartMerger.new(template, destination, **preset.to_h)
```

## Full recipe example

```yaml
name: gem_family_section
template: GEM_FAMILY_SECTION.md
targets:
  - README.md

injection:
  anchor:
    type: heading
    text: "/Gem Family/"
  position: replace
  boundary:
    type: heading
    same_or_shallower: true

merge:
  preference: template
  add_missing: true

when_missing: skip
```

```ruby
recipe = Ast::Merge::Recipe::Config.load(".merge-recipes/gem_family_section.yml")
runner = Ast::Merge::Recipe::Runner.new(recipe, dry_run: true, parser: :markly)
results = runner.run
```

## Script references

Recipe values such as `signature_generator`, `node_typing`, and `add_missing` can point at Ruby files that return callables.

Example layout:

```text
recipes/
  gem_family_section.yml
  gem_family_section/
    signature_generator.rb
    heading_typing.rb
```

Example script:

```ruby
lambda do |node|
  next node unless node.respond_to?(:text)

  if node.text.include?("Gem Family")
    [:gem_family_heading]
  else
    node
  end
end
```

Inline lambda expressions are also supported by `ScriptLoader`.

## Anchor text matching

Anchor matching uses node `.text`, which is plain text rather than source markup.

For Markdown headings that means formatting is stripped:

| Source | `.text` |
|--------|---------|
| `` ### The `*-merge` Gem Family `` | `The *-merge Gem Family` |
| `[link text](url)` | `link text` |

Write anchor patterns against the plain-text form:

```yaml
anchor:
  type: heading
  text: "/\\*-merge Gem Family/"
```

## Markdown-specific recipe options

The built-in runner forwards these options to Markdown partial-template mergers when present:

- `merge.normalize_whitespace`
- `merge.rehydrate_link_references`

Those options stay in the recipe model so callers can keep a single YAML representation even when execution happens elsewhere.
