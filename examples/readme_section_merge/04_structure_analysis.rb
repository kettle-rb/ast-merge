#!/usr/bin/env ruby
# frozen_string_literal: true

# Example 4: Document Structure Analysis
#
# This example analyzes how markdown-merge sees the template and destination
# documents, showing node types, signatures, and content previews.
#
# This is useful for:
# - Understanding how nodes are parsed
# - Debugging signature matching issues
# - Verifying node_typing behavior
# - Learning the markdown-merge internals
#
# Usage: ruby examples/readme_section_merge/04_structure_analysis.rb

require_relative "shared"

include ReadmeSectionMerge

print_header("Example 4: Document Structure Analysis")

puts "Analysis: How does markdown-merge see the template and destination?"
puts "          This helps understand the signature matching behavior."
puts

# Load and analyze template
template_content = load_template

puts Colors.cyan("Template structure (GEM_FAMILY_SECTION.md):")
puts
begin
  template_analysis = Markly::Merge::FileAnalysis.new(template_content)
  template_analysis.statements.each_with_index do |node, idx|
    sig = template_analysis.signature_at(idx)
    canonical_type = Ast::Merge::NodeTyping.merge_type_for(node) ||
      (node.respond_to?(:type) ? node.type : nil)

    # Get a preview of content
    preview = case canonical_type.to_s
    when "heading"
      raw = Ast::Merge::NodeTyping.unwrap(node)
      raw.respond_to?(:to_plaintext) ? raw.to_plaintext.strip[0, 40] : "[heading]"
    when "paragraph"
      raw = Ast::Merge::NodeTyping.unwrap(node)
      text = raw.respond_to?(:to_plaintext) ? raw.to_plaintext.strip : ""
      text[0, 50]
    when "table"
      "[table with #{count_table_rows(node)} rows]"
    else
      "[#{canonical_type}]"
    end

    puts "   #{idx}: #{canonical_type.to_s.ljust(12)} | #{preview}..."
    puts "       sig: #{sig.inspect[0, 60]}..."
  end
rescue => e
  puts "   #{Colors.red("Error analyzing template:")} #{e.message}"
end

puts
puts Colors.cyan("Destination gem-family section (destination_toml.md):")
puts
dest_content = File.read(Paths.fixture_path("destination_toml.md"))
begin
  dest_analysis = Markly::Merge::FileAnalysis.new(dest_content)
  in_section = false
  shown_count = 0

  dest_analysis.statements.each_with_index do |node, idx|
    sig = dest_analysis.signature_at(idx)
    canonical_type = Ast::Merge::NodeTyping.merge_type_for(node) ||
      (node.respond_to?(:type) ? node.type : nil)

    text = extract_node_text(node)

    # Start showing when we hit the gem family heading
    if gem_family_heading?(node)
      in_section = true
    end

    # Stop when we hit the next H2 or different H3
    if in_section && canonical_type.to_s == "heading"
      raw = Ast::Merge::NodeTyping.unwrap(node)
      level = raw.respond_to?(:header_level) ? raw.header_level : nil
      if level && level <= 2
        in_section = false
      elsif level == 3 && !gem_family_heading?(node)
        in_section = false
      end
    end

    next unless in_section || text.include?("tree_haver") || text.include?("ts-json")
    break if shown_count > 10  # Limit output

    preview = text[0, 50]
    puts "   #{idx}: #{canonical_type.to_s.ljust(12)} | #{preview}..."
    puts "       sig: #{sig.inspect[0, 60]}..."
    shown_count += 1
  end
rescue => e
  puts "   #{Colors.red("Error analyzing destination:")} #{e.message}"
end

# Signature comparison
puts
puts Colors.bold("━" * 80)
puts Colors.bold("Signature Comparison")
puts Colors.bold("━" * 80)
puts
puts "Matching signatures means nodes will be paired for merge resolution."
puts "Different signatures means nodes are treated as distinct."
puts

begin
  template_analysis = Markly::Merge::FileAnalysis.new(template_content)
  dest_analysis = Markly::Merge::FileAnalysis.new(dest_content)

  # Find the main gem family table in both
  template_table_sig = nil
  template_analysis.statements.each_with_index do |node, idx|
    type = Ast::Merge::NodeTyping.merge_type_for(node) || node.type
    if type.to_s == "table"
      text = extract_node_text(node)
      if text.include?("tree_haver")
        template_table_sig = template_analysis.signature_at(idx)
        puts Colors.cyan("Template gem family table signature:")
        puts "   #{template_table_sig.inspect}"
        break
      end
    end
  end

  dest_table_sig = nil
  dest_analysis.statements.each_with_index do |node, idx|
    type = Ast::Merge::NodeTyping.merge_type_for(node) || node.type
    if type.to_s == "table"
      text = extract_node_text(node)
      if text.include?("tree_haver")
        dest_table_sig = dest_analysis.signature_at(idx)
        puts Colors.cyan("Destination gem family table signature:")
        puts "   #{dest_table_sig.inspect}"
        break
      end
    end
  end

  puts
  if template_table_sig == dest_table_sig
    puts Colors.green("✓ Signatures MATCH - tables will be paired for merge")
  else
    puts Colors.red("✗ Signatures DIFFER - tables will NOT be paired")
    puts "   Template: #{template_table_sig.inspect}"
    puts "   Dest:     #{dest_table_sig.inspect}"
  end
rescue => e
  puts Colors.red("Error comparing signatures: #{e.message}")
end

puts
puts Colors.bold("Key Insights:")
puts
puts "1. Tables match by: [:table, row_count, header_content_hash]"
puts "2. Headings match by: [:heading, level, text_content]"
puts "3. Paragraphs match by: [:paragraph, content_hash]"
puts
puts "For the gem family table to match, both template and destination must have:"
puts "   - Same number of table rows"
puts "   - Same header row content (column names)"

# Helper to count table rows
def count_table_rows(node)
  raw = Ast::Merge::NodeTyping.unwrap(node)
  return 0 unless raw.respond_to?(:each)

  count = 0
  raw.each { count += 1 }
  count
rescue
  "?"
end
