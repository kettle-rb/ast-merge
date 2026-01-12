# frozen_string_literal: true

# TestableNode is now provided by tree_haver/rspec.
#
# This file exists for backward compatibility and re-exports the shared
# TestableNode from tree_haver so existing tests continue to work.
#
# @see TreeHaver::RSpec::TestableNode

require "tree_haver/rspec/testable_node"

# For backward compatibility, also make it available under the old namespace
module Ast
  module Merge
    module Testing
      # @deprecated Use TreeHaver::RSpec::TestableNode instead
      TestableNode = ::TreeHaver::RSpec::TestableNode

      # @deprecated Use TreeHaver::RSpec::MockInnerNode instead
      MockInnerNode = ::TreeHaver::RSpec::MockInnerNode
    end
  end
end

# Top-level constant is already defined by tree_haver/rspec/testable_node.rb
# but we ensure it's available here for specs that only require this file
TestableNode = TreeHaver::RSpec::TestableNode unless defined?(TestableNode)
