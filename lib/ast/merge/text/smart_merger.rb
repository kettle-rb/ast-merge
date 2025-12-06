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
      class SmartMerger
        # Default freeze token for text merging
        DEFAULT_FREEZE_TOKEN = "text-merge"

        # @return [TextAnalysis] Analysis of the template file
        attr_reader :template_analysis

        # @return [TextAnalysis] Analysis of the destination file
        attr_reader :dest_analysis

        # @return [ConflictResolver] Resolver for handling conflicts
        attr_reader :resolver

        # @return [MergeResult] Result object
        attr_reader :result

        # Initialize a new SmartMerger
        #
        # @param template_content [String] Template text content
        # @param dest_content [String] Destination text content
        # @param signature_match_preference [Symbol] :destination or :template
        # @param add_template_only_nodes [Boolean] Whether to add template-only lines
        # @param freeze_token [String] Token for freeze block markers
        # @param signature_generator [Proc, nil] Custom signature generator
        def initialize(
          template_content,
          dest_content,
          signature_match_preference: :destination,
          add_template_only_nodes: false,
          freeze_token: DEFAULT_FREEZE_TOKEN,
          signature_generator: nil
        )
          @template_analysis = TextAnalysis.new(
            template_content,
            freeze_token: freeze_token,
            signature_generator: signature_generator
          )
          @dest_analysis = TextAnalysis.new(
            dest_content,
            freeze_token: freeze_token,
            signature_generator: signature_generator
          )
          @resolver = ConflictResolver.new(
            @template_analysis,
            @dest_analysis,
            signature_match_preference: signature_match_preference,
            add_template_only_nodes: add_template_only_nodes
          )
          @result = MergeResult.new(
            template_analysis: @template_analysis,
            dest_analysis: @dest_analysis
          )
          @signature_match_preference = signature_match_preference
          @add_template_only_nodes = add_template_only_nodes
        end

        # Perform the merge
        #
        # @return [String] Merged content
        def merge
          @resolver.resolve(@result)
          @result.to_s
        end

        # Get merge statistics
        #
        # @return [Hash] Statistics about the merge
        def stats
          {
            template_lines: @template_analysis.statements.count { |s| s.is_a?(LineNode) },
            dest_lines: @dest_analysis.statements.count { |s| s.is_a?(LineNode) },
            result_lines: @result.lines.size,
            decisions: @result.decision_summary
          }
        end
      end
    end
  end
end
