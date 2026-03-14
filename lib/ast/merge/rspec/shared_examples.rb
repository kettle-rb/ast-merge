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
# - "Ast::Merge::Comment::Attachment" - validates merge-facing comment attachments
# - "Ast::Merge::Comment::Augmenter" - validates shared comment augmenter behavior
# - "Ast::Merge::Comment::Region" - validates merge-facing comment regions
# - "Ast::Merge::ConflictResolverBase" - validates conflict resolver base implementation
# - "Ast::Merge::DebugLogger" - validates debug logging integration
# - "Ast::Merge::FileAnalyzable" - validates file analysis mixin integration
# - "Ast::Merge::FreezeNodeBase" - validates freeze node base implementation
# - "Ast::Merge::MergeResultBase" - validates merge result implementation
# - "Ast::Merge::MergerConfig" - validates merger configuration
# - "Ast::Merge::RemovalModeCompliance" - validates generic remove_template_missing_nodes behavior
# - "a reproducible merge" - validates merge scenarios with fixtures and idempotency

require_relative "shared_examples/comment_attachment"
require_relative "shared_examples/comment_augmenter"
require_relative "shared_examples/comment_region"
require_relative "shared_examples/conflict_resolver_base"
require_relative "shared_examples/debug_logger"
require_relative "shared_examples/file_analyzable"
require_relative "shared_examples/freeze_node_base"
require_relative "shared_examples/merge_result_base"
require_relative "shared_examples/merger_config"
require_relative "shared_examples/removal_mode_compliance"
require_relative "shared_examples/reproducible_merge"
