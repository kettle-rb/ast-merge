# TreeHaver needs to be loaded early, so we can make the DependencyTags available
require "tree_haver"
require "tree_haver/rspec"

# NOTE: We DON'T require "ast-merge" or "ast/merge/rspec" here because this file
# loads BEFORE SimpleCov, and we need SimpleCov to instrument ast-merge's code first.
# The registration of known gems happens in spec_helper.rb AFTER SimpleCov loads.
