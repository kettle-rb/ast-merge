# frozen_string_literal: true

# External gems
require "version_gem"

# This gem - only version can be required (never autoloaded)
require_relative "merge/version"

module Ast
  module Merge
    # Base error class for all AST merge operations.
    # All *-merge gems should have their Error class inherit from this.
    # @api public
    class Error < StandardError; end

    # Base class for parse errors in merge operations.
    #
    # This class provides a flexible interface that can be extended by
    # specific merge implementations. It supports:
    # - An `errors` array for parser-specific error objects
    # - An optional `content` attribute for the source that failed to parse
    #
    # Subclasses (TemplateParseError, DestinationParseError) identify whether
    # the error occurred in the template or destination file.
    #
    # @example Basic usage with errors array
    #   raise ParseError.new(errors: [syntax_error])
    #
    # @example With content for debugging
    #   raise ParseError.new(errors: parse_result.errors, content: source_code)
    #
    # @example With custom message
    #   raise ParseError.new("Custom message", errors: [e])
    #
    # @api public
    class ParseError < Error
      # @return [Array] Parser-specific error objects (e.g., Prism::ParseError, RBS::BaseError)
      attr_reader :errors

      # @return [String, nil] The source content that failed to parse (optional)
      attr_reader :content

      # Initialize a new ParseError.
      #
      # @param message [String, nil] Custom error message (auto-generated if nil)
      # @param errors [Array] Array of parser-specific error objects
      # @param content [String, nil] The source content that failed to parse
      def initialize(message = nil, errors: [], content: nil)
        @errors = Array(errors)
        @content = content
        super(message || build_message)
      end

      private

      # Build a default error message from the errors array.
      # Override in subclasses for more specific messages.
      #
      # @return [String] Error message
      def build_message
        if @errors.empty?
          "Unknown #{self.class.name.split("::").map(&:downcase).join(" ")}"
        else
          error_messages = @errors.map { |e| e.respond_to?(:message) ? e.message : e.to_s }
          "#{self.class.name.split("::").map(&:downcase).join(" ")}: #{error_messages.join(", ")}"
        end
      end
    end

    # Raised when the template file has syntax errors.
    #
    # Template files are the "source of truth" that destination files
    # are merged against. When a template cannot be parsed, the merge
    # operation cannot proceed.
    #
    # @example Handling template parse errors
    #   begin
    #     merger = SmartMerger.new(template, destination)
    #   rescue Ast::Merge::TemplateParseError => e
    #     puts "Template syntax error: #{e.message}"
    #     e.errors.each { |error| puts "  #{error.message}" }
    #   end
    #
    # @api public
    class TemplateParseError < ParseError; end

    # Raised when the destination file has syntax errors.
    #
    # Destination files contain user customizations that should be preserved
    # during merges. When a destination cannot be parsed, the merge operation
    # cannot proceed.
    #
    # @example Handling destination parse errors
    #   begin
    #     merger = SmartMerger.new(template, destination)
    #   rescue Ast::Merge::DestinationParseError => e
    #     puts "Destination syntax error: #{e.message}"
    #     e.errors.each { |error| puts "  #{error.message}" }
    #   end
    #
    # @api public
    class DestinationParseError < ParseError; end

    autoload :ConflictResolverBase, "ast/merge/conflict_resolver_base"
    autoload :DebugLogger, "ast/merge/debug_logger"
    autoload :FileAnalyzable, "ast/merge/file_analyzable"
    autoload :FreezeNodeBase, "ast/merge/freeze_node_base"
    autoload :MatchRefinerBase, "ast/merge/match_refiner_base"
    autoload :MatchScoreBase, "ast/merge/match_score_base"
    autoload :MergeResultBase, "ast/merge/merge_result_base"
    autoload :MergerConfig, "ast/merge/merger_config"
    autoload :Text, "ast/merge/text"
  end
end

Ast::Merge::Version.class_eval do
  extend VersionGem::Basic
end
