# frozen_string_literal: true

# Signature generator for gem family section content.
#
# This gives matching signatures to gem family content so template and destination
# sections match even when the content differs slightly.
#
# @param node [Object] Markdown node
# @return [Array, nil] Signature for the node, or nil for default behavior

lambda do |node|
  # Extract text content from the node
  text = if node.respond_to?(:to_plaintext)
    node.to_plaintext.to_s.strip
  elsif node.respond_to?(:to_commonmark)
    node.to_commonmark.to_s.strip
  else
    node.to_s.strip
  end

  # Get the node type
  type = if node.respond_to?(:type)
    node.type.to_s
  else
    "unknown"
  end

  # Check heading
  if type == "heading"
    raw = Ast::Merge::NodeTyping.unwrap(node)
    level = raw.respond_to?(:header_level) ? raw.header_level : nil
    if level == 3 && text.include?("*-merge") && text.include?("Gem Family")
      return [:gem_family, :heading, "*-merge Gem Family"]
    end
  end

  # Check tables
  if type == "table"
    if text.include?("tree_haver") || text.include?("ast-merge") || text.include?("prism-merge")
      if text.include?("Format") && text.include?("Parser Backend")
        return [:gem_family, :table, :main_gem_table]
      elsif text.include?("Purpose") && text.include?("Description")
        return [:gem_family, :table, :example_table]
      end
    end
  end

  # Check paragraphs
  if type == "paragraph"
    if text.include?("*-merge") && text.include?("gem family")
      return [:gem_family, :paragraph, :intro]
    elsif text.include?("Example implementations")
      return [:gem_family, :paragraph, :example_intro]
    end
  end

  # Check link reference definitions
  if type == "link_definition" || type.to_s == "link_definition"
    # Known gem family link labels
    gem_family_labels = %w[
      tree_haver ast-merge prism-merge psych-merge json-merge jsonc-merge
      bash-merge rbs-merge dotenv-merge toml-merge markdown-merge markly-merge
      commonmarker-merge kettle-dev kettle-jem prism psych ts-json ts-jsonc
      ts-bash ts-toml dotenv rbs toml-rb markly commonmarker
    ]

    if text =~ /^\[([^\]]+)\]:/
      label = $1
      if gem_family_labels.include?(label)
        return [:gem_family, :link_ref, label]
      end
    end
  end

  # Default: let the system generate its own signature
  nil
end

