# frozen_string_literal: true

# Node typing for link_definition nodes - identifies gem family link refs.
#
# @param node [Object] Link definition node
# @return [Object] Node with merge type applied, or original node

# Known gem family link reference labels
GEM_FAMILY_LABELS = %w[
  tree_haver ast-merge prism-merge psych-merge json-merge jsonc-merge
  bash-merge rbs-merge dotenv-merge toml-merge markdown-merge markly-merge
  commonmarker-merge kettle-dev kettle-jem prism psych ts-json ts-jsonc
  ts-bash ts-toml dotenv rbs toml-rb markly commonmarker
].freeze

lambda do |node|
  raw = Ast::Merge::NodeTyping.unwrap(node)

  text = if raw.respond_to?(:to_commonmark)
    raw.to_commonmark.to_s.strip
  else
    raw.to_s.strip
  end

  # Extract the label from [label]: url format
  if text =~ /^\[([^\]]+)\]:/
    label = $1
    if GEM_FAMILY_LABELS.include?(label)
      Ast::Merge::NodeTyping.with_merge_type(node, :gem_family_link_ref)
    else
      node
    end
  else
    node
  end
end

