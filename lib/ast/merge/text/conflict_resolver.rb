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
        # @param template_analysis [FileAnalysis] Analysis of template
        # @param dest_analysis [FileAnalysis] Analysis of destination
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

          # Build index for matching (uses signatures when custom generator present)
          template_index = build_match_index(template_statements)

          # Track matched template indices
          matched_template_indices = Set.new

          # Process destination in order - destination structure is preserved
          dest_statements.each do |dest_node|
            if freeze_node?(dest_node)
              # Freeze blocks are always preserved from destination
              add_freeze_block(result, dest_node)
              next
            end

            # Find matching template line by signature or normalized content
            match_key = signature_key_for(dest_node)
            template_match = find_unmatched(template_index[match_key], matched_template_indices)

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

        # Whether a custom signature generator is in use
        # @return [Boolean]
        def custom_signatures?
          @template_analysis.respond_to?(:signature_generator) &&
            !@template_analysis.signature_generator.nil?
        end

        # Compute the match key for a node.
        # Uses generate_signature when a custom generator is present;
        # falls back to normalized_content for default text matching.
        # @param node [LineNode] the node
        # @return [Object] match key (String or Array)
        def signature_key_for(node)
          if custom_signatures?
            @template_analysis.generate_signature(node)
          else
            node.normalized_content
          end
        end

        # Build an index of statements by match key (signature or normalized content)
        #
        # @param statements [Array] Statements to index
        # @return [Hash] Map of match_key => [{node:, index:}, ...]
        def build_match_index(statements)
          index = Hash.new { |h, k| h[k] = [] }
          statements.each_with_index do |node, idx|
            next if freeze_node?(node)

            key = signature_key_for(node)
            index[key] << {node: node, index: idx}
          end
          index
        end

        # Find first unmatched entry from a list
        #
        # @param entries [Array, nil] List of {node:, index:} hashes
        # @param matched_indices [Set] Already matched indices
        # @return [Hash, nil] First unmatched entry or nil
        def find_unmatched(entries, matched_indices)
          return unless entries

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
