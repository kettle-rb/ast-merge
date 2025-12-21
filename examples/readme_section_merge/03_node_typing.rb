#!/usr/bin/env ruby
# frozen_string_literal: true

# Example 3: Per-Node-Type Preference with node_typing (RECOMMENDED)
#
# This example demonstrates using node_typing with Hash preference for
# precise per-node-type merge control.
#
# This is the recommended approach because:
# 1. It's more precise - you control exactly which node types use template
# 2. It's more readable - the preference hash clearly shows intent
# 3. It's more maintainable - adding new types is just adding to the hash
#
# How it works:
# 1. node_typing lambdas inspect each node and assign a custom merge_type
# 2. The preference Hash maps merge_types to :template or :destination
# 3. Only nodes with gem_family_* merge_types use template content
#
# Usage: ruby examples/readme_section_merge/03_node_typing.rb

require_relative "shared"

include ReadmeSectionMerge

Paths.ensure_output_dir!

print_header("Example 3: Per-Node-Type Preference with node_typing")

puts "Strategy: Use node_typing to tag gem family section content,"
puts "          then use Hash preference to make template win for those nodes."
puts
puts Colors.green("This is the RECOMMENDED approach for section-based merging!")
puts
puts "How it works:"
puts "  1. node_typing lambdas inspect nodes and assign custom merge_types"
puts "  2. Hash preference maps merge_types to :template or :destination"
puts "  3. Only gem_family_* typed nodes use template content"
puts

# Load the template
template_content = load_template
puts Colors.cyan("📄 Template: GEM_FAMILY_SECTION.md")
puts "   Lines: #{template_content.lines.count}"
puts

# Node typing configuration: identify gem family section content
# Note: Markly nodes return type as String (e.g., "table"), not Symbol
gem_family_node_typing = {
  # Tag headings that are the gem family H3
  "heading" => lambda do |node|
    raw = Ast::Merge::NodeTyping.unwrap(node)
    level = raw.respond_to?(:header_level) ? raw.header_level : nil
    text = extract_node_text(node)

    if level == 3 && text.include?("*-merge") && text.include?("Gem Family")
      Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_heading)
    else
      node
    end
  end,

  # Tag tables that contain gem family content
  "table" => lambda do |node|
    text = extract_node_text(node)

    if text.include?("tree_haver") || text.include?("ast-merge") || text.include?("prism-merge")
      Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_table)
    else
      node
    end
  end,

  # Tag paragraphs that are gem family intro or link references
  "paragraph" => lambda do |node|
    text = extract_node_text(node)

    if text.include?("*-merge") && text.include?("gem family")
      Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_paragraph)
    elsif text =~ /^\[([^\]]+)\]:\s*https?:\/\// &&
        (text.include?("tree_haver") || text.include?("ast-merge") ||
         text.include?("prism-merge") || text.include?("kettle"))
      Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_link_ref)
    else
      node
    end
  end,
}

# Per-type preference: template wins for gem family content, destination for everything else
gem_family_preference = {
  default: :destination,
  gem_family_heading: :template,
  gem_family_table: :template,
  gem_family_paragraph: :template,
  gem_family_link_ref: :template,
}

puts "Preference configuration:"
gem_family_preference.each do |type, pref|
  color = (pref == :template) ? Colors.method(:green) : Colors.method(:yellow)
  puts "   #{type}: #{color.call(pref.to_s)}"
end
puts

# Process each test file
TEST_FILES.each do |filename, description|
  dest_file = Paths.fixture_path(filename)
  output_file = Paths.output_path("exp3", filename)

  next unless File.exist?(dest_file)

  dest_content = File.read(dest_file)

  merger = Markly::Merge::SmartMerger.new(
    template_content,
    dest_content,
    preference: gem_family_preference,
    add_template_only_nodes: true,
    node_typing: gem_family_node_typing,
  )

  run_merge(
    description: description,
    merger: merger,
    output_file: output_file,
  )
  puts
end

puts Colors.bold("Output files: #{Paths::OUTPUT_DIR}/exp3_*.md")
puts
puts Colors.bold("Why this approach is recommended:")
puts "  ✓ Precise control over which nodes use template content"
puts "  ✓ Clear, readable preference configuration"
puts "  ✓ Easy to extend with new merge_types"
puts "  ✓ Destination content preserved for non-matching nodes"
