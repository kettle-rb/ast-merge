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

    # Raised when the document contains text that matches the region placeholder.
    #
    # Region placeholders are used internally to mark positions in a document
    # where nested regions will be substituted after merging. If the document
    # already contains text that looks like a placeholder, the merge cannot
    # proceed safely.
    #
    # @example Handling placeholder collision
    #   begin
    #     merger = SmartMerger.new(template, destination, regions: [...])
    #   rescue Ast::Merge::PlaceholderCollisionError => e
    #     # Use a custom placeholder to avoid the collision
    #     merger = SmartMerger.new(template, destination,
    #       regions: [...],
    #       region_placeholder: "###MY_CUSTOM_PLACEHOLDER_"
    #     )
    #   end
    #
    # @api public
    class PlaceholderCollisionError < Error
      # @return [String] The placeholder that caused the collision
      attr_reader :placeholder

      # Initialize a new PlaceholderCollisionError.
      #
      # @param placeholder [String] The placeholder string that was found in the document
      def initialize(placeholder)
        @placeholder = placeholder
        super(
          "Document contains placeholder text '#{placeholder}'. " \
          "Use the :region_placeholder option to specify a custom placeholder."
        )
      end
    end

    autoload :ConflictResolverBase, "ast/merge/conflict_resolver_base"
    autoload :DebugLogger, "ast/merge/debug_logger"
    autoload :FencedCodeBlockDetector, "ast/merge/fenced_code_block_detector"
    autoload :FileAnalyzable, "ast/merge/file_analyzable"
    autoload :FreezeNodeBase, "ast/merge/freeze_node_base"
    autoload :MatchRefinerBase, "ast/merge/match_refiner_base"
    autoload :MatchScoreBase, "ast/merge/match_score_base"
    autoload :MergeResultBase, "ast/merge/merge_result_base"
    autoload :MergerConfig, "ast/merge/merger_config"
    autoload :NodeTyping, "ast/merge/node_typing"
    autoload :Region, "ast/merge/region"
    autoload :RegionDetectorBase, "ast/merge/region_detector_base"
    autoload :RegionMergeable, "ast/merge/region_mergeable"
    autoload :SmartMergerBase, "ast/merge/smart_merger_base"
    autoload :Text, "ast/merge/text"
    autoload :TomlFrontmatterDetector, "ast/merge/toml_frontmatter_detector"
    autoload :YamlFrontmatterDetector, "ast/merge/yaml_frontmatter_detector"
  end
end

Ast::Merge::Version.class_eval do
  extend VersionGem::Basic
end
