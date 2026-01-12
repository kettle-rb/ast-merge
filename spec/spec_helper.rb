# frozen_string_literal: true

# External gems
require "ostruct"

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

# Load TreeHaver RSpec support first to set up backend availability methods
# This is needed before loading merge gems that depend on backends like markly/commonmarker
require "tree_haver/rspec"

# Load merge gems to trigger their registrations with MergeGemRegistry
# This must happen BEFORE requiring ast/merge/rspec so the registrations
# are complete when RSpec configures exclusion filters.
# Gems that fail to load (not installed, missing dependencies) are silently skipped.
%w[
  markly/merge
  commonmarker/merge
  markdown/merge
  prism/merge
  bash/merge
  rbs/merge
  json/merge
  jsonc/merge
  toml/merge
  psych/merge
  dotenv/merge
].each do |gem_path|
  require gem_path
rescue LoadError
  # Gem not available - will be excluded via dependency tags
end

# RSpec support: dependency tags + shared examples for ast-merge
# (tree_haver/rspec was already loaded above)
require "ast/merge/rspec"

RSpec.configure do |config|
  config.before do
    # Speed up polling loops
    allow(described_class).to receive(:sleep) unless described_class.nil?
  end
end
