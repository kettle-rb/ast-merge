# frozen_string_literal: true

require_relative "analysis"
require_relative "conflict_resolver"
require_relative "merge_result"

module Ast
  module Merge
    module Text
      # Smart merger for text-based files.
      #
      # Provides intelligent merging of two text files using a simple line-based AST
      # where lines are top-level nodes and words are nested nodes.
      #
      # @example Basic merge (destination customizations preserved)
      #   merger = SmartMerger.new(template_content, dest_content)
      #   result = merger.merge
      #   puts result  # Merged content
      #
      # @example Template wins merge
      #   merger = SmartMerger.new(
      #     template_content,
      #     dest_content,
      #     signature_match_preference: :template,
      #     add_template_only_nodes: true
      #   )
      #   result = merger.merge
      #
      # @example With freeze blocks
      #   template = <<~TEXT
      #     Line one
      #     Line two
      #   TEXT
      #
      #   dest = <<~TEXT
      #     Line one modified
      #     # text-merge:freeze
      #     Custom content
      #     # text-merge:unfreeze
      #   TEXT
      #
      #   merger = SmartMerger.new(template, dest)
      #   result = merger.merge
      #   # => "Line one modified\n# text-merge:freeze\nCustom content\n# text-merge:unfreeze"
      #
      # @example With regions (embedded code blocks)
      #   merger = SmartMerger.new(
      #     template_content,
      #     dest_content,
      #     regions: [
      #       { detector: FencedCodeBlockDetector.ruby, merger_class: SomeRubyMerger }
      #     ]
      #   )
      class SmartMerger < SmartMergerBase
        # Default freeze token for text merging
        DEFAULT_FREEZE_TOKEN = "text-merge"

        # Initialize a new SmartMerger
        #
        # @param template_content [String] Template text content
        # @param dest_content [String] Destination text content
        # @param signature_match_preference [Symbol] :destination or :template
        # @param add_template_only_nodes [Boolean] Whether to add template-only lines
        # @param freeze_token [String] Token for freeze block markers
        # @param signature_generator [Proc, nil] Custom signature generator
        # @param regions [Array<Hash>, nil] Region configurations for nested merging
        # @param region_placeholder [String, nil] Custom placeholder for regions
        def initialize(
          template_content,
          dest_content,
          signature_match_preference: :destination,
          add_template_only_nodes: false,
          freeze_token: DEFAULT_FREEZE_TOKEN,
          signature_generator: nil,
          regions: nil,
          region_placeholder: nil
        )
          super(
            template_content,
            dest_content,
            signature_generator: signature_generator,
            signature_match_preference: signature_match_preference,
            add_template_only_nodes: add_template_only_nodes,
            freeze_token: freeze_token,
            regions: regions,
            region_placeholder: region_placeholder,
          )
        end

        # Get merge statistics
        #
        # @return [Hash] Statistics about the merge
        def stats
          merge_result # Ensure merge has run
          {
            template_lines: @template_analysis.statements.count { |s| s.is_a?(LineNode) },
            dest_lines: @dest_analysis.statements.count { |s| s.is_a?(LineNode) },
            result_lines: @result.lines.size,
            decisions: @result.decision_summary,
          }
        end

        protected

        # @return [Class] The analysis class for text files
        def analysis_class
          TextAnalysis
        end

        # @return [String] The default freeze token
        def default_freeze_token
          DEFAULT_FREEZE_TOKEN
        end

        # @return [Class] The resolver class for text files
        def resolver_class
          ConflictResolver
        end

        # @return [Class] The result class for text files
        def result_class
          MergeResult
        end

        # Perform the text-specific merge
        #
        # @return [MergeResult] The merge result
        def perform_merge
          @resolver.resolve(@result)
          @result
        end

        # Build the resolver with positional arguments (Text::ConflictResolver signature)
        def build_resolver
          ConflictResolver.new(
            @template_analysis,
            @dest_analysis,
            signature_match_preference: @signature_match_preference,
            add_template_only_nodes: @add_template_only_nodes,
          )
        end
      end
    end
  end
end
