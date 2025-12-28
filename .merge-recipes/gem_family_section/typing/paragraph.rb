# frozen_string_literal: true

# Node typing for paragraph nodes - identifies gem family intro paragraphs.
#
# @param node [Object] Paragraph node
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

  if text.include?("*-merge") && text.include?("gem family")
    Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_paragraph)
  elsif text.include?("Example implementations")
    Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_paragraph)
  else
    node
  end
end

