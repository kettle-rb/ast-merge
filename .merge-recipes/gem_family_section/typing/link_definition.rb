# frozen_string_literal: true

# Node typing for link_definition nodes - identifies gem family link refs.
#
# The node is a TreeHaver node (or equivalent) which provides a unified
# API with #text, #type methods that work across all backends.
#
# @param node [Object] TreeHaver node (or equivalent with unified API)
# @return [Object] Node with merge type applied, or original node

# Known gem family link reference labels
GEM_FAMILY_LABELS = %w[
  tree_haver ast-merge prism-merge psych-merge json-merge jsonc-merge
  bash-merge rbs-merge dotenv-merge toml-merge markdown-merge markly-merge
  commonmarker-merge kettle-dev kettle-jem prism psych ts-json ts-jsonc
  ts-bash ts-toml dotenv rbs toml-rb markly commonmarker
].freeze

lambda do |node|
  # TreeHaver nodes provide #text method for normalized text extraction
  text = node.text.to_s.strip

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

