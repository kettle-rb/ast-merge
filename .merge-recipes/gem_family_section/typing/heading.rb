# frozen_string_literal: true

# Node typing for heading nodes - identifies gem family H3 headings.
#
# @param node [Object] Heading node
# @return [Object] Node with merge type applied, or original node

lambda do |node|
  raw = Ast::Merge::NodeTyping.unwrap(node)
  level = raw.respond_to?(:header_level) ? raw.header_level : nil

  text = if raw.respond_to?(:to_plaintext)
    raw.to_plaintext.to_s.strip
  elsif raw.respond_to?(:to_commonmark)
    raw.to_commonmark.to_s.strip
  else
    raw.to_s.strip
  end

  if level == 3 && text.include?("*-merge") && text.include?("Gem Family")
    Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_heading)
  else
    node
  end
end

