# frozen_string_literal: true

# External gems
require "ostruct"

# External RSpec & related config
require "kettle/test/rspec"

# Internal ENV config
require_relative "config/debug"
require_relative "config/tree_haver"

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

# Load ONLY the registry and helper classes (not RSpec configuration yet)
# This allows us to register known gems before RSpec.configure runs
require "ast/merge/rspec/setup"

# Register known merge gems that ast-merge tests depend on
# This must happen AFTER SimpleCov loads (above) and AFTER ast-merge loads (above)
# but BEFORE the RSpec configuration runs. This ensures the gems are registered when
# the before(:suite) hook in dependency_tags_config.rb sets up the exclusion filters.
Ast::Merge::RSpec::MergeGemRegistry.register_known_gems(
  :markly_merge,
  :commonmarker_merge,
  :markdown_merge,
  :prism_merge,
  :bash_merge,
  :rbs_merge,
  :json_merge,
  :jsonc_merge,
  :toml_merge,
  :psych_merge,
  :dotenv_merge,
)

# Now load the RSpec configuration (before(:suite) hooks, exclusion filters)
# This must come AFTER register_known_gems so the registry has gems to configure
require "ast/merge/rspec/dependency_tags_config"

# Load shared examples for ast-merge
require "ast/merge/rspec/shared_examples"

# Load merge gems to trigger their registrations with MergeGemRegistry
# Gems that fail to load (not installed, missing dependencies) are silently skipped.
# If a gem loads successfully, it will re-register itself (which just updates the
# existing registration from register_known_gems above).
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

RSpec.configure do |config|
  config.before do
    # Speed up polling loops
    allow(described_class).to receive(:sleep) unless described_class.nil?
  end
end
