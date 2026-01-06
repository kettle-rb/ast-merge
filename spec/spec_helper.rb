# frozen_string_literal: true

# External RSpec & related config
require "kettle/test/rspec"

# Internal ENV config
require_relative "config/debug"

# Config for development dependencies of this library
# i.e., not configured by this library
#
# Simplecov & related config (must run BEFORE any other requires)
# NOTE: Gemfiles for older rubies won't have kettle-soup-cover.
#       The rescue LoadError handles that scenario.
begin
  require "kettle-soup-cover"
  require "simplecov" if Kettle::Soup::Cover::DO_COV # `.simplecov` is run here!
rescue LoadError => e
  # check the error message and re-raise when unexpected
  raise e unless e.message.include?("kettle")
end

# this library
require "ast/merge"

# Test support files
require_relative "support/testable_node"

# RSpec support: dependency tags + shared examples
# Loads TreeHaver tags (parser backends) + Ast::Merge tags (merge gems) + shared examples
require "ast/merge/rspec"

RSpec.configure do |config|
  config.before do
    # Speed up polling loops
    allow(described_class).to receive(:sleep) unless described_class.nil?
  end
end
