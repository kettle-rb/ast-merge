# frozen_string_literal: true

module Ast
  module Merge
    module Text
      # Conflict resolver for text-based AST merging.
      #
      # Uses content-based matching with destination-order preservation:
      # 1. Lines are matched by normalized content (whitespace-trimmed)
      # 2. Destination order is preserved (destination is source of truth for structure)
      # 3. Template-only lines are optionally added at the end
      # 4. Freeze blocks are always preserved from destination
      #
      # @example
      #   resolver = ConflictResolver.new(template_analysis, dest_analysis)
      #   result = MergeResult.new
      #   resolver.resolve(result)
      class ConflictResolver < ConflictResolverBase
        # Initialize the conflict resolver
        #
        # @param template_analysis [TextAnalysis] Analysis of template
        # @param dest_analysis [TextAnalysis] Analysis of destination
        # @param preference [Symbol] :destination or :template
        # @param add_template_only_nodes [Boolean] Whether to add template-only lines
        def initialize(
          template_analysis,
          dest_analysis,
          preference: :destination,
          add_template_only_nodes: false
        )
          super(
            strategy: :batch,
            preference: preference,
            template_analysis: template_analysis,
            dest_analysis: dest_analysis,
            add_template_only_nodes: add_template_only_nodes
          )
        end

        protected

        # Resolve using content-based matching with destination order preservation
        #
        # @param result [MergeResult] Result object to populate
        # @return [void]
        def resolve_batch(result)
          template_statements = @template_analysis.statements
          dest_statements = @dest_analysis.statements

          # Build content index for matching
          template_by_content = build_content_index(template_statements)

          # Track matched template indices
          matched_template_indices = Set.new

          # Process destination in order - destination structure is preserved
          dest_statements.each do |dest_node|
            if freeze_node?(dest_node)
              # Freeze blocks are always preserved from destination
              add_freeze_block(result, dest_node)
              next
            end

            # Find matching template line by normalized content
            normalized = dest_node.normalized_content
            template_match = find_unmatched(template_by_content[normalized], matched_template_indices)

            if template_match
              matched_template_indices << template_match[:index]
              resolve_matched_pair(result, template_match[:node], dest_node)
            else
              # Destination-only content - always preserve
              result.add_line(dest_node.content)
              result.record_decision(DECISION_APPENDED, nil, dest_node)
            end
          end

          # Add template-only lines if configured
          if @add_template_only_nodes
            add_unmatched_template_lines(result, template_statements, matched_template_indices)
          end
        end

        private

        # Build an index of statements by normalized content
        #
        # @param statements [Array] Statements to index
        # @return [Hash] Map of normalized content => [{node:, index:}, ...]
        def build_content_index(statements)
          index = Hash.new { |h, k| h[k] = [] }
          statements.each_with_index do |node, idx|
            next if freeze_node?(node)

            normalized = node.normalized_content
            index[normalized] << {node: node, index: idx}
          end
          index
        end

        # Find first unmatched entry from a list
        #
        # @param entries [Array, nil] List of {node:, index:} hashes
        # @param matched_indices [Set] Already matched indices
        # @return [Hash, nil] First unmatched entry or nil
        def find_unmatched(entries, matched_indices)
          return nil unless entries

          entries.find { |e| !matched_indices.include?(e[:index]) }
        end

        # Add a freeze block to the result
        #
        # @param result [MergeResult] Result to populate
        # @param freeze_node [FreezeNodeBase] Freeze block node
        def add_freeze_block(result, freeze_node)
          freeze_node.content.split("\n").each do |line|
            result.add_line(line)
          end
          result.record_decision(DECISION_FROZEN, nil, freeze_node)
        end

        # Add unmatched template lines in their original order
        #
        # @param result [MergeResult] Result to populate
        # @param template_statements [Array] All template statements
        # @param matched_indices [Set] Indices of matched template nodes
        def add_unmatched_template_lines(result, template_statements, matched_indices)
          template_statements.each_with_index do |template_node, idx|
            next if matched_indices.include?(idx)
            next if freeze_node?(template_node)

            result.add_line(template_node.content)
            result.record_decision(DECISION_ADDED, template_node, nil)
          end
        end

        # Resolve a matched pair of nodes
        #
        # @param result [MergeResult] Result to populate
        # @param template_node [LineNode] Template node
        # @param dest_node [LineNode] Destination node
        def resolve_matched_pair(result, template_node, dest_node)
          if template_node.content == dest_node.content
            # Identical content
            result.add_line(dest_node.content)
            result.record_decision(DECISION_IDENTICAL, template_node, dest_node)
          elsif @preference == :template
            # Template wins - use template content
            result.add_line(template_node.content)
            result.record_decision(DECISION_KEPT_TEMPLATE, template_node, dest_node)
          else
            # Destination wins (default) - use destination content
            result.add_line(dest_node.content)
            result.record_decision(DECISION_KEPT_DEST, template_node, dest_node)
          end
        end
      end
    end
  end
end
