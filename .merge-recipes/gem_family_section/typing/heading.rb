# frozen_string_literal: true

# Node typing for heading nodes - identifies gem family H3 headings.
#
# The node is a TreeHaver node (or equivalent) which provides a unified
# API with #text, #type, #header_level methods that work across all backends.
#
# @param node [Object] TreeHaver node (or equivalent with unified API)
# @return [Object] Node with merge type applied, or original node

lambda do |node|
  # TreeHaver nodes provide #text method for normalized text extraction
  text = node.text.to_s.strip
  level = node.respond_to?(:header_level) ? node.header_level : nil

  if level == 3 && text.include?("*-merge") && text.include?("Gem Family")
    Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_heading)
  else
    node
  end
end

