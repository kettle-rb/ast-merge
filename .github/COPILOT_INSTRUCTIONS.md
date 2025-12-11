# GitHub Copilot Instructions for ast-merge

This document contains important information for AI assistants working on this codebase.

## Tool Usage Preferences

### Prefer Internal Tools Over Terminal Commands

**IMPORTANT**: Copilot cannot see terminal output. Every terminal command requires the user to manually copy/paste the output back to the chat. This is slow and frustrating.

✅ **PREFERRED** - Use internal tools:
- `grep_search` instead of `grep` command
- `file_search` instead of `find` command
- `read_file` instead of `cat` command
- `list_dir` instead of `ls` command
- `replace_string_in_file` or `create_file` instead of `sed` / manual editing

❌ **AVOID** when possible:
- `run_in_terminal` for information gathering
- Running grep/find/cat in terminal

Only use terminal for:
- Running tests (`bundle exec rspec`)
- Installing dependencies (`bundle install`)
- Git operations that require interaction
- Commands that actually need to execute (not just gather info)

## Search Tool Limitations

### grep_search includePattern

**IMPORTANT**: The `**` glob pattern does NOT work in the `includePattern` parameter.

❌ **BROKEN** - Do not use:
```
includePattern: "vendor/prism-merge/**/*.rb"
includePattern: "**/spec/**/*.rb"
```

✅ **WORKS** - Use explicit paths instead:
```
includePattern: "vendor/prism-merge/spec/integration/file_alignment_spec.rb"
includePattern: "vendor/prism-merge/lib/prism/merge/smart_merger.rb"
```

When you need to search across multiple files:
1. Use `grep_search` without `includePattern` to search the entire workspace
2. Or make multiple targeted searches with explicit file paths
3. Or use `file_search` first to find files, then search each explicitly

## Project Structure

- `lib/ast/merge/` - Base library classes (ast-merge gem)
- `vendor/prism-merge/` - Ruby/Prism-specific merge implementation
- `vendor/*/` - Other format-specific merge implementations (markly-merge, json-merge, etc.)

## API Conventions

### SmartMergerBase API
- `merge` - Returns a **String** (the merged content)
- `merge_result` - Returns a **MergeResult** object
- `to_s` on MergeResult returns the merged content as a string

### Comment Classes
- `Ast::Merge::Comment::*` - Generic, language-agnostic comment classes
- `Prism::Merge::Comment::*` - Ruby-specific comment classes with magic comment detection

### Naming Conventions
- File paths must match class paths (Ruby convention)
- Example: `Ast::Merge::Comment::Line` → `lib/ast/merge/comment/line.rb`

## Architecture Notes

### prism-merge (as of December 2024)
- Uses section-based merging with recursive body merging
- Does NOT use FileAligner or ConflictResolver (these were removed as vestigial)
- SmartMerger handles all merge logic directly
- Comment-only files are handled via `Ast::Merge::Text::SmartMerger`

## Testing

Run tests from the appropriate directory:
```bash
# ast-merge tests
cd /var/home/pboling/src/kettle-rb/ast-merge
bundle exec rspec spec/

# prism-merge tests
cd /var/home/pboling/src/kettle-rb/ast-merge/vendor/prism-merge
bundle exec rspec spec/
```

### Coverage Reports

To generate a coverage report for any vendor gem:
```bash
cd /var/home/pboling/src/kettle-rb/ast-merge/vendor/prism-merge  # or other vendor gem
bin/rake coverage && bin/kettle-soup-cover -d
```

This runs tests with coverage instrumentation and generates detailed coverage reports in the `coverage/` directory.

## Common Pitfalls

1. **NEVER add backward compatibility** - The maintainer explicitly prohibits backward compatibility shims, aliases, or deprecation layers. Make clean breaks.
2. **Magic comments** - Ruby-specific, belong in prism-merge not ast-merge
3. **`content_string` is legacy** - Use `to_s` instead
4. **`merged_source` doesn't exist** - `merge` returns a String directly

## Terminal Command Restrictions

### NEVER Pipe Test Commands Through head/tail

**CRITICAL**: NEVER use `head`, `tail`, or any output truncation with test commands (`rspec`, `rake`, `bundle exec rspec`, etc.).

❌ **ABSOLUTELY FORBIDDEN**:
```bash
bundle exec rspec 2>&1 | tail -50
bin/rake coverage 2>&1 | head -100
bin/rspec | tail -200
```

✅ **CORRECT** - Run commands without truncation:
```bash
bundle exec rspec
bin/rake coverage
bin/rspec
```

**Why**: 
- You cannot predict how much output a test run will produce
- Your predictions are ALWAYS wrong
- You cannot see terminal output anyway - the user will copy relevant portions for you
- Truncating output often hides the actual errors or relevant information
- The user knows what's important and will share it with you
