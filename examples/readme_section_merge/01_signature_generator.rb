#!/usr/bin/env ruby
# frozen_string_literal: true

# Example 1: Section-Aware Signature Generator
#
# This example demonstrates using a custom signature_generator to identify
# gem family section content by giving related nodes common signature prefixes.
#
# The signature_generator approach works by:
# 1. Detecting the H3 "Gem Family" heading
# 2. Identifying related tables and paragraphs by content patterns
# 3. Giving them matching signatures so template content replaces destination
#
# Usage: ruby examples/readme_section_merge/01_signature_generator.rb

require_relative "shared"

include ReadmeSectionMerge
include Colors

Paths.ensure_output_dir!

print_header("Example 1: Section-Aware Signature Generator")

puts "Strategy: Use signature_generator to identify the gem family section"
puts "          content by giving all related nodes a common signature prefix."
puts
puts yellow("This approach gives matching signatures to section content,")
puts yellow("so template and destination tables match even with different content.")
puts

# Load the template
template_content = load_template
puts cyan("📄 Template: GEM_FAMILY_SECTION.md")
puts "   Lines: #{template_content.lines.count}"
puts

# Custom signature generator that identifies gem family section content
section_aware_sig_gen = lambda do |node|
  text = extract_node_text(node)

  # Check if this is the gem family H3 heading
  if gem_family_heading?(node)
    return [:gem_family_section, :heading, text[0, 30]]
  end

  canonical_type = Ast::Merge::NodeTyping.merge_type_for(node) ||
    (node.respond_to?(:type) ? node.type : nil)

  # Check if this is a paragraph about the gem family (intro text)
  if canonical_type.to_s == "paragraph"
    if text.include?("*-merge") && text.include?("gem family")
      return [:gem_family_section, :paragraph, :intro]
    end
  end

  # Check if this is one of the gem family tables
  if canonical_type.to_s == "table"
    if text.include?("tree_haver") || text.include?("ast-merge") ||
        text.include?("prism-merge") || text.include?("kettle-dev")
      return [:gem_family_section, :table, Digest::SHA256.hexdigest(text)[0, 8]]
    end
  end

  # Fall through to default signature
  node
end

# Process each test file
TEST_FILES.each do |filename, description|
  dest_file = Paths.fixture_path(filename)
  output_file = Paths.output_path("exp1", filename)

  next unless File.exist?(dest_file)

  dest_content = File.read(dest_file)

  merger = Markly::Merge::SmartMerger.new(
    template_content,
    dest_content,
    preference: :template,           # Template wins on conflicts
    add_template_only_nodes: true,   # Add new content from template
    signature_generator: section_aware_sig_gen,
  )

  run_merge(
    description: description,
    merger: merger,
    output_file: output_file,
  )
  puts
end

puts Colors.bold("Output files: #{Paths::OUTPUT_DIR}/exp1_*.md")
