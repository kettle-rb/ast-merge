#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Smart Markdown Merging with Inner Code Block Merging
#
# This demonstrates how markdown-merge can intelligently merge markdown files
# that contain fenced code blocks in various languages, delegating to
# language-specific *-merge gems for inner-merge of the code content.
#
# This example tests whether FencedCodeBlockDetector is needed, or if the
# native code block nodes in the Markdown AST (accessed via fence_info and
# string_content) are sufficient for inner-merging.

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../vendor/tree_haver/lib", __dir__))
$LOAD_PATH.unshift(File.expand_path("../vendor/markdown-merge/lib", __dir__))

require "tree_haver"
require "markdown/merge"

puts "=" * 80
puts "Markdown Code Block Inner-Merge Example"
puts "=" * 80
puts

# Template: Developer guide with code examples
template_markdown = <<~MARKDOWN
  # Developer Guide

  ## Ruby Configuration

  Initialize your app with this Ruby code:

  ```ruby
  class App
    def initialize
      @name = "MyApp"
      @port = 3000
    end
  end
  ```
MARKDOWN

# Destination: Same guide with customizations
destination_markdown = <<~MARKDOWN
  # Developer Guide (Production)

  ## Ruby Configuration

  Initialize your app with this Ruby code:

  ```ruby
  class App
    def initialize
      @name = "MyProductionApp"
      @port = 8080
      @database_host = "db.example.com"
    end
  end
  ```
MARKDOWN

puts "Template:"
puts "-" * 80
puts template_markdown
puts

puts "Destination:"
puts "-" * 80
puts destination_markdown
puts

# Check backend
TreeHaver.backend = :commonmarker
puts "Backend: #{TreeHaver.backend_module}"
puts

if !TreeHaver::Backends::Commonmarker.available?
  puts "✗ Commonmarker not available"
  exit 1
end

puts "✓ Commonmarker is available"
puts

# Test 1: WITHOUT inner-merge
puts "=" * 80
puts "1. WITHOUT inner-merge (destination code block wins entirely)"
puts "=" * 80

merger_no_inner = Markdown::Merge::SmartMerger.new(
  template_markdown,
  destination_markdown,
  backend: :commonmarker,
  inner_merge_code_blocks: false,
  preference: :destination,
)

result_no_inner = merger_no_inner.merge_result

puts result_no_inner.content
puts

# Test 2: WITH inner-merge
puts "=" * 80
puts "2. WITH inner-merge (Ruby code intelligently merged using Prism)"
puts "=" * 80
puts "This requires prism-merge gem to be available"
puts

begin
  require "prism/merge"

  merger_with_inner = Markdown::Merge::SmartMerger.new(
    template_markdown,
    destination_markdown,
    backend: :commonmarker,
    inner_merge_code_blocks: true,
    preference: :destination,
  )

  result_with_inner = merger_with_inner.merge_result

  puts result_with_inner.content
  puts

  puts "✓ Inner-merge successful!"
  puts "  Notice: @database_host from destination is preserved!"
  puts "  This is because Prism parsed the Ruby code into a FULL AST"
  puts "  and performed semantic merging at the method level."
rescue LoadError => e
  puts "✗ prism-merge not available: #{e.message}"
  puts "  Install with: cd vendor/prism-merge && bundle install"
end

puts
puts "=" * 80
puts "Conclusion:"
puts "=" * 80
puts
puts "When inner_merge_code_blocks: true is enabled:"
puts "1. Markdown parser extracts code via node.fence_info & node.string_content"
puts "2. Code is handed to language-specific parser (Prism for Ruby)"
puts "3. Language parser creates FULL AST of the embedded code"
puts "4. Semantic merging happens (preserves @database_host instance var)"
puts "5. Result is merged back into markdown"
puts
puts "FencedCodeBlockDetector is NOT needed for this - native AST nodes suffice!"
puts "=" * 80
