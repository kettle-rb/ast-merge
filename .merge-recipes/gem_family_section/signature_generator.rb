# frozen_string_literal: true

# Signature generator for gem family section content.
#
# This gives matching signatures to gem family content so template and destination
# sections match even when the content differs slightly.
#
# The node passed here is a TreeHaver node (or equivalent) which provides a unified
# API with #text, #type, #source_position methods that work across all backends.
#
# @param node [Object] TreeHaver node (or equivalent with unified API)
# @return [Array, nil] Signature for the node, or nil for default behavior

lambda do |node|
  # TreeHaver nodes provide #text method for normalized text extraction
  text = node.text.to_s.strip

  # Get the node type
  type = node.type.to_s

  # Check heading
  if type == "heading"
    level = node.respond_to?(:header_level) ? node.header_level : nil
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
    # Match intro paragraph - various phrasings for gem family intro
    # Template uses: "The `*-merge` gem family provides intelligent, AST-based merging"
    # Destination uses: "This gem is part of a family of gems that provide intelligent merging"
    if text.include?("*-merge") && text.include?("gem family")
      return [:gem_family, :paragraph, :intro]
    elsif text.include?("family of gems") && text.include?("intelligent merging")
      return [:gem_family, :paragraph, :intro]
    elsif text.include?("part of a family") && text.include?("intelligent merging")
      return [:gem_family, :paragraph, :intro]
    elsif text.include?("Example implementations")
      return [:gem_family, :paragraph, :example_intro]
    end
  end

  # Check link reference definitions
  if type == "link_definition"
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

