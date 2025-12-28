# frozen_string_literal: true

# Filter for add_template_only_nodes - only adds gem_family nodes.
#
# This ensures we add missing link refs from the template but don't add
# the entire template section to files that don't have the gem family section.
#
# @param node [Object] The node being considered
# @param entry [Hash] Entry information including :signature
# @return [Boolean] True if node should be added

lambda do |node, entry|
  sig = entry[:signature]

  # Only add nodes that have a gem_family signature
  return false unless sig.is_a?(Array) && sig.first == :gem_family

  true
end
