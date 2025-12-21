#!/usr/bin/env ruby
# frozen_string_literal: true

# Example 2: Link Reference Deduplication
#
# This example demonstrates using signature_generator to match link references
# by their label (e.g., [tree_haver]) rather than full content.
#
# The problem: When merging markdown files, link references like:
#   [tree_haver]: https://github.com/kettle-rb/tree_haver
# can get duplicated because they appear in both template and destination.
#
# The solution: Give link references with the same label identical signatures,
# so the merger treats them as the same node and uses template preference.
#
# Usage: ruby examples/readme_section_merge/02_link_ref_deduplication.rb

require_relative "shared"

include ReadmeSectionMerge

Paths.ensure_output_dir!

print_header("Example 2: Link Reference Deduplication")

puts "Strategy: Use signature_generator to match link references by their"
puts "          label (e.g., [tree_haver]) rather than full content."
puts
puts Colors.yellow("Link references with the same label get the same signature,")
puts Colors.yellow("so template preference will replace old refs, avoiding duplicates.")
puts

# Load the template
template_content = load_template
puts Colors.cyan("📄 Template: GEM_FAMILY_SECTION.md")
puts "   Lines: #{template_content.lines.count}"
puts

# Signature generator that matches link references by their label
link_ref_sig_gen = lambda do |node|
  text = extract_node_text(node)
  canonical_type = Ast::Merge::NodeTyping.merge_type_for(node) ||
    (node.respond_to?(:type) ? node.type : nil)

  # Link references are parsed as paragraphs starting with [label]:
  if canonical_type.to_s == "paragraph"
    # Match patterns like [tree_haver]: or [ts-jsonc]:
    if text =~ /^\[([^\]]+)\]:\s*https?:\/\//
      label = $1
      return [:link_reference, label]
    end
  end

  # Also identify gem family content (same as example 1)
  if gem_family_heading?(node)
    return [:gem_family_section, :heading, text[0, 30]]
  end

  if canonical_type.to_s == "paragraph" && text.include?("*-merge") && text.include?("gem family")
    return [:gem_family_section, :paragraph, :intro]
  end

  if canonical_type.to_s == "table"
    if text.include?("tree_haver") || text.include?("ast-merge")
      return [:gem_family_section, :table, Digest::SHA256.hexdigest(text)[0, 8]]
    end
  end

  # Fall through to default signature
  node
end

# Process each test file
TEST_FILES.each do |filename, description|
  dest_file = Paths.fixture_path(filename)
  output_file = Paths.output_path("exp2", filename)

  next unless File.exist?(dest_file)

  dest_content = File.read(dest_file)

  merger = Markly::Merge::SmartMerger.new(
    template_content,
    dest_content,
    preference: :template,
    add_template_only_nodes: true,
    signature_generator: link_ref_sig_gen,
  )

  run_merge(
    description: description,
    merger: merger,
    output_file: output_file,
  )
  puts
end

puts Colors.bold("Output files: #{Paths::OUTPUT_DIR}/exp2_*.md")
