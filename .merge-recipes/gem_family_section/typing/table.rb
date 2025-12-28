# frozen_string_literal: true

# Node typing for table nodes - identifies gem family tables.
#
# @param node [Object] Table node
# @return [Object] Node with merge type applied, or original node

lambda do |node|
  raw = Ast::Merge::NodeTyping.unwrap(node)

  text = if raw.respond_to?(:to_plaintext)
    raw.to_plaintext.to_s.strip
  elsif raw.respond_to?(:to_commonmark)
    raw.to_commonmark.to_s.strip
  else
    raw.to_s.strip
  end

  if text.include?("tree_haver") || text.include?("ast-merge") || text.include?("prism-merge")
    Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_table)
  else
    node
  end
end

