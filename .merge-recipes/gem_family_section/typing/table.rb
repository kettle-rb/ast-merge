# frozen_string_literal: true

# Node typing for table nodes - identifies gem family tables.
#
# The node is a TreeHaver node (or equivalent) which provides a unified
# API with #text, #type methods that work across all backends.
#
# @param node [Object] TreeHaver node (or equivalent with unified API)
# @return [Object] Node with merge type applied, or original node

lambda do |node|
  # TreeHaver nodes provide #text method for normalized text extraction
  text = node.text.to_s.strip

  if text.include?("tree_haver") || text.include?("ast-merge") || text.include?("prism-merge")
    Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_table)
  else
    node
  end
end
