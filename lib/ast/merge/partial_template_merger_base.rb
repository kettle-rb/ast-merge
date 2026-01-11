# frozen_string_literal: true

module Ast
  module Merge
    # Base class for merging a partial template into a specific section of a destination document.
    #
    # Unlike the full SmartMerger which merges entire documents, PartialTemplateMergerBase:
    # 1. Finds a specific section in the destination (using InjectionPoint)
    # 2. Replaces/merges only that section with the template
    # 3. Leaves the rest of the destination unchanged
    #
    # This is an abstract base class. Subclasses must implement:
    # - #create_analysis(content) - Create a FileAnalysis for the given content
    # - #create_smart_merger(template, section) - Create a SmartMerger for the section merge
    # - #find_section_end(statements, injection_point) - Find where the section ends
    # - #node_to_text(node, analysis) - Convert a node to source text
    #
    # @abstract Subclass and implement parser-specific methods
    # @see Markdown::Merge::PartialTemplateMerger For markdown implementation
    #
    class PartialTemplateMergerBase
      # Result of a partial template merge
      class Result
        # @return [String] The merged content
        attr_reader :content

        # @return [Boolean] Whether the destination had a matching section
        attr_reader :has_section

        # @return [Boolean] Whether the content changed
        attr_reader :changed

        # @return [Hash] Statistics about the merge
        attr_reader :stats

        # @return [InjectionPoint, nil] The injection point found (if any)
        attr_reader :injection_point

        # @return [String, nil] Message about the merge
        attr_reader :message

        def initialize(content:, has_section:, changed:, stats: {}, injection_point: nil, message: nil)
          @content = content
          @has_section = has_section
          @changed = changed
          @stats = stats
          @injection_point = injection_point
          @message = message
        end

        # @return [Boolean] Whether a section was found
        def section_found?
          has_section
        end
      end

      # @return [String] The template content (the section to inject)
      attr_reader :template

      # @return [String] The destination content
      attr_reader :destination

      # @return [Hash] Anchor matcher configuration
      attr_reader :anchor

      # @return [Hash, nil] Boundary matcher configuration
      attr_reader :boundary

      # @return [Symbol, Hash] Merge preference (:template, :destination, or per-type hash)
      attr_reader :preference

      # @return [Boolean, Proc] Whether to add template-only nodes
      attr_reader :add_missing

      # @return [Symbol] What to do when section not found (:skip, :append, :prepend)
      attr_reader :when_missing

      # @return [Proc, nil] Custom signature generator for node matching
      attr_reader :signature_generator

      # @return [Hash, nil] Node typing configuration for per-type preferences
      attr_reader :node_typing

      # @return [Object, nil] Match refiner for fuzzy matching unmatched nodes
      attr_reader :match_refiner

      # Initialize a PartialTemplateMergerBase.
      #
      # @param template [String] The template content (the section to merge in)
      # @param destination [String] The destination content
      # @param anchor [Hash] Anchor matcher: { type: :heading, text: /pattern/ }
      # @param boundary [Hash, nil] Boundary matcher (defaults to same type as anchor)
      # @param preference [Symbol, Hash] Which content wins (:template, :destination, or per-type hash)
      # @param add_missing [Boolean, Proc] Whether to add template nodes not in destination
      # @param when_missing [Symbol] What to do if section not found (:skip, :append, :prepend)
      # @param replace_mode [Boolean] If true, template replaces section entirely (no merge)
      # @param signature_generator [Proc, nil] Custom signature generator for SmartMerger
      # @param node_typing [Hash, nil] Node typing configuration for per-type preferences
      # @param match_refiner [Object, nil] Match refiner for fuzzy matching (e.g., ContentMatchRefiner)
      def initialize(
        template:,
        destination:,
        anchor:,
        boundary: nil,
        preference: :template,
        add_missing: true,
        when_missing: :skip,
        replace_mode: false,
        signature_generator: nil,
        node_typing: nil,
        match_refiner: nil
      )
        @template = template
        @destination = destination
        @anchor = normalize_matcher(anchor)
        @boundary = boundary ? normalize_matcher(boundary) : nil
        @preference = preference
        @add_missing = add_missing
        @when_missing = when_missing
        @replace_mode = replace_mode
        @signature_generator = signature_generator
        @node_typing = node_typing
        @match_refiner = match_refiner
      end

      # Perform the partial template merge.
      #
      # @return [Result] The merge result
      def merge
        # Parse destination and find injection point
        d_analysis = create_analysis(destination)
        d_statements = Navigable::Statement.build_list(d_analysis.statements)

        finder = Navigable::InjectionPointFinder.new(d_statements)
        injection_point = finder.find(
          type: anchor[:type],
          text: anchor[:text],
          position: :replace,
          boundary_type: boundary&.dig(:type),
          boundary_text: boundary&.dig(:text),
          boundary_same_or_shallower: boundary&.dig(:same_or_shallower) || false,
        )

        if injection_point.nil?
          return handle_missing_section(d_analysis)
        end

        # Found the section - now merge
        perform_section_merge(d_analysis, d_statements, injection_point)
      end

      protected

      # Create a FileAnalysis for the given content.
      #
      # @abstract Subclasses must implement this method
      # @param content [String] The content to analyze
      # @return [Object] A FileAnalysis instance
      def create_analysis(content)
        raise NotImplementedError, "#{self.class} must implement #create_analysis"
      end

      # Create a SmartMerger for merging the section.
      #
      # @abstract Subclasses must implement this method
      # @param template_content [String] The template content
      # @param destination_content [String] The destination section content
      # @return [Object] A SmartMerger instance
      def create_smart_merger(template_content, destination_content)
        raise NotImplementedError, "#{self.class} must implement #create_smart_merger"
      end

      # Find where the section ends.
      #
      # @abstract Subclasses must implement this method
      # @param statements [Array<NavigableStatement>] All statements
      # @param injection_point [InjectionPoint] The injection point
      # @return [Integer] Index of the last statement in the section
      def find_section_end(statements, injection_point)
        raise NotImplementedError, "#{self.class} must implement #find_section_end"
      end

      # Convert a node to its source text.
      #
      # @abstract Subclasses must implement this method
      # @param node [Object] The node to convert
      # @param analysis [Object, nil] The analysis object for source lookup
      # @return [String] The source text
      def node_to_text(node, analysis = nil)
        raise NotImplementedError, "#{self.class} must implement #node_to_text"
      end

      private

      def normalize_matcher(matcher)
        return {} if matcher.nil?

        result = {}
        result[:type] = matcher[:type]&.to_sym
        result[:text] = normalize_text_pattern(matcher[:text])
        result[:level] = matcher[:level] if matcher[:level]
        result[:level_lte] = matcher[:level_lte] if matcher[:level_lte]
        result[:level_gte] = matcher[:level_gte] if matcher[:level_gte]
        result[:same_or_shallower] = matcher[:same_or_shallower] if matcher.key?(:same_or_shallower)
        result.compact
      end

      def normalize_text_pattern(text)
        return if text.nil?
        return text if text.is_a?(Regexp)

        # Handle /regex/ syntax in strings
        if text.is_a?(String) && text.start_with?("/") && text.end_with?("/")
          Regexp.new(text[1..-2])
        else
          text
        end
      end

      def handle_missing_section(d_analysis)
        case when_missing
        when :append
          # Append template to end of destination
          new_content = destination.chomp + "\n\n" + template
          Result.new(
            content: new_content,
            has_section: false,
            changed: true,
            message: "Section not found, appended template",
          )
        when :prepend
          # Prepend template to beginning of destination
          new_content = template + "\n\n" + destination
          Result.new(
            content: new_content,
            has_section: false,
            changed: true,
            message: "Section not found, prepended template",
          )
        else
          Result.new(
            content: destination,
            has_section: false,
            changed: false,
            message: "Section not found, skipping",
          )
        end
      end

      def perform_section_merge(d_analysis, d_statements, injection_point)
        # Determine section boundaries in destination
        section_start_idx = injection_point.anchor.index
        section_end_idx = find_section_end(d_statements, injection_point)

        # Extract the three parts: before, section, after
        before_statements = d_statements[0...section_start_idx]
        section_statements = d_statements[section_start_idx..section_end_idx]
        after_statements = d_statements[(section_end_idx + 1)..]

        # Determine the merged section content
        section_content = statements_to_content(section_statements, d_analysis)
        merged_section, stats = merge_section_content(section_content)

        # Reconstruct the document using source-based extraction
        before_content = statements_to_content(before_statements, d_analysis)
        after_content = statements_to_content(after_statements, d_analysis)

        new_content = build_merged_content(before_content, merged_section, after_content)

        changed = new_content != destination

        Result.new(
          content: new_content,
          has_section: true,
          changed: changed,
          stats: stats,
          injection_point: injection_point,
          message: changed ? "Section merged successfully" : "Section unchanged",
        )
      end

      def merge_section_content(section_content)
        # Use SmartMerger for intelligent merging of the section
        # The behavior depends on preference setting:
        # - :template with replace_mode: true -> full replacement
        # - :template with replace_mode: false -> merge with template winning conflicts
        # - :destination -> merge with destination winning conflicts

        if replace_mode?
          # Full replacement: just use template content directly
          [template, {mode: :replace}]
        else
          # Intelligent merge: use SmartMerger
          merger = create_smart_merger(template, section_content)
          result = merger.merge_result
          [result.content, result.stats.merge(mode: :merge)]
        end
      end

      # Check if we're in replace mode (vs merge mode)
      # Replace mode means template completely replaces the section
      def replace_mode?
        @replace_mode == true
      end

      def statements_to_content(statements, analysis = nil)
        return "" if statements.nil? || statements.empty?

        statements.map do |stmt|
          node = stmt.respond_to?(:node) ? stmt.node : stmt
          node_to_text(node, analysis)
        end.join
      end

      def build_merged_content(before, section, after)
        result = +""

        # Before content
        unless before.nil? || before.strip.empty?
          result << before.chomp("\n")
        end

        # Merged section - ensure exactly one blank line before it if there's content before
        unless section.nil? || section.strip.empty?
          unless result.empty?
            # Ensure exactly one blank line between before and section
            result << "\n" unless result.end_with?("\n")
            result << "\n" unless result.end_with?("\n\n")
          end
          result << section.chomp("\n")
        end

        # After content - ensure exactly one blank line before it if there's content before
        unless after.nil? || after.strip.empty?
          unless result.empty?
            # Ensure exactly one blank line between section and after
            result << "\n" unless result.end_with?("\n")
            result << "\n" unless result.end_with?("\n\n")
          end
          result << after.chomp("\n")
        end

        result << "\n" unless result.empty? || result.end_with?("\n")
        result
      end
    end
  end
end
