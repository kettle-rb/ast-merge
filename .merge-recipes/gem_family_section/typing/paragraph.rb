# frozen_string_literal: true

# Node typing for paragraph nodes - identifies gem family intro paragraphs.
#
# The node is a TreeHaver node (or equivalent) which provides a unified
# API with #text, #type methods that work across all backends.
#
# @param node [Object] TreeHaver node (or equivalent with unified API)
# @return [Object] Node with merge type applied, or original node

lambda do |node|
  # TreeHaver nodes provide #text method for normalized text extraction
  text = node.text.to_s.strip

  if text.include?("*-merge") && text.include?("gem family")
    Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_paragraph)
  elsif text.include?("family of gems") && text.include?("intelligent merging")
    # Alternate phrasing in destination files
    Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_paragraph)
  elsif text.include?("Example implementations")
    Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_paragraph)
  else
    node
  end
end
