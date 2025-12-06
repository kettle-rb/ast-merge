# frozen_string_literal: true

# Load all Ast::Merge shared examples for RSpec
#
# Usage:
#   require "ast/merge/rspec/shared_examples"
#
# This will load all shared examples provided by ast-merge,
# making them available for use in any *-merge gem's test suite.
#
# Available shared examples:
# - "Ast::Merge::ConflictResolverBase" - validates conflict resolver base implementation
# - "Ast::Merge::DebugLogger" - validates debug logging integration
# - "Ast::Merge::FileAnalyzable" - validates file analysis mixin integration
# - "Ast::Merge::FreezeNodeBase" - validates freeze node base implementation
# - "Ast::Merge::MergeResultBase" - validates merge result implementation
# - "Ast::Merge::MergerConfig" - validates merger configuration
# - "a reproducible merge" - validates merge scenarios with fixtures and idempotency

require_relative "shared_examples/conflict_resolver_base"
require_relative "shared_examples/debug_logger"
require_relative "shared_examples/file_analyzable"
require_relative "shared_examples/freeze_node_base"
require_relative "shared_examples/merge_result_base"
require_relative "shared_examples/merger_config"
require_relative "shared_examples/reproducible_merge"
