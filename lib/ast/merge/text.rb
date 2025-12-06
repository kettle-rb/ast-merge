# frozen_string_literal: true

require_relative "text/word_node"
require_relative "text/line_node"
require_relative "text/analysis"
require_relative "text/merge_result"
require_relative "text/conflict_resolver"
require_relative "text/smart_merger"

module Ast
  module Merge
    # Text-based AST module for ast-merge.
    #
    # Provides a simple line/word based AST that can be used with any text file.
    # This serves as both:
    # 1. A reference implementation for *-merge gems
    # 2. A testing tool for validating merge behavior
    #
    # @example Basic usage
    #   require "ast/merge/text"
    #
    #   template = "Line one\nLine two\nLine three"
    #   dest = "Line one modified\nLine two\nCustom line"
    #
    #   merger = Ast::Merge::Text::SmartMerger.new(template, dest)
    #   result = merger.merge
    module Text
      # Default freeze token for text files
      DEFAULT_FREEZE_TOKEN = "text-merge"
    end
  end
end
