# frozen_string_literal: true

# kettle-jem:freeze
# To retain chunks of comments & code during ast-merge templating:
# Wrap custom sections with freeze markers (e.g., as above and below this comment chunk).
# ast-merge will then preserve content between those markers across template runs.
# kettle-jem:unfreeze


# Define a base default task early so other files can enhance it.
desc "Default tasks aggregator"
task :default do
  puts "Default task complete."
end

# External gems that define tasks - add here!
require "kettle/dev"

### TEMPLATING TASKS
begin
  require "kettle/jem"
rescue LoadError
  desc("(stub) kettle:jem:selftest is unavailable")
  task("kettle:jem:selftest") do
    warn("NOTE: kettle-jem isn't installed, or is disabled for #{RUBY_VERSION} in the current environment")
  end
end

require "kettle/jem"


### RELEASE TASKS
# Setup stone_checksums
begin
  require "stone_checksums"
rescue LoadError
  desc("(stub) build:generate_checksums is unavailable")
  task("build:generate_checksums") do
    warn("NOTE: stone_checksums isn't installed, or is disabled for #{RUBY_VERSION} in the current environment")
  end
end
