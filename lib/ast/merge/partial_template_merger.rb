# frozen_string_literal: true

module Ast
  module Merge
    # Merges a partial template into a specific section of a destination document.
    #
    # Unlike the full SmartMerger which merges entire documents, PartialTemplateMerger:
    # 1. Finds a specific section in the destination (using InjectionPoint)
    # 2. Replaces/merges only that section with the template
    # 3. Leaves the rest of the destination unchanged
    #
    # This is useful for updating a specific section (like a "Gem Family" section)
    # across multiple files while preserving file-specific content.
    #
    # @example Basic usage
    #   merger = PartialTemplateMerger.new(
    #     template: template_content,
    #     destination: destination_content,
    #     anchor: { type: :heading, text: /Gem Family/ },
    #     parser: :markly
    #   )
    #   result = merger.merge
    #   puts result.content
    #
    # @example With boundary
    #   merger = PartialTemplateMerger.new(
    #     template: template_content,
    #     destination: destination_content,
    #     anchor: { type: :heading, text: /Installation/ },
    #     boundary: { type: :heading },  # Stop at next heading
    #     parser: :markly
    #   )
    #
    class PartialTemplateMerger
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

      # @return [Symbol] Parser to use (:markly, :commonmarker, etc.)
      attr_reader :parser

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

      # Initialize a PartialTemplateMerger.
      #
      # @param template [String] The template content (the section to merge in)
      # @param destination [String] The destination content
      # @param anchor [Hash] Anchor matcher: { type: :heading, text: /pattern/ }
      # @param boundary [Hash, nil] Boundary matcher (defaults to same type as anchor)
      # @param parser [Symbol] Parser to use (:markly, :commonmarker, :prism, :psych)
      # @param preference [Symbol, Hash] Which content wins (:template, :destination, or per-type hash)
      # @param add_missing [Boolean, Proc] Whether to add template nodes not in destination
      # @param when_missing [Symbol] What to do if section not found (:skip, :append, :prepend)
      # @param replace_mode [Boolean] If true, template replaces section entirely (no merge)
      # @param signature_generator [Proc, nil] Custom signature generator for SmartMerger
      # @param node_typing [Hash, nil] Node typing configuration for per-type preferences
      def initialize(
        template:,
        destination:,
        anchor:,
        boundary: nil,
        parser: :markly,
        preference: :template,
        add_missing: true,
        when_missing: :skip,
        replace_mode: false,
        signature_generator: nil,
        node_typing: nil
      )
        @template = template
        @destination = destination
        @anchor = normalize_matcher(anchor)
        @boundary = boundary ? normalize_matcher(boundary) : nil
        @parser = parser
        @preference = preference
        @add_missing = add_missing
        @when_missing = when_missing
        @replace_mode = replace_mode
        @signature_generator = signature_generator
        @node_typing = node_typing
      end

      # Perform the partial template merge.
      #
      # @return [Result] The merge result
      def merge
        # Parse destination and find injection point
        d_analysis = create_analysis(destination)
        d_statements = NavigableStatement.build_list(d_analysis.statements)

        finder = InjectionPointFinder.new(d_statements)
        injection_point = finder.find(
          type: anchor[:type],
          text: anchor[:text],
          position: :replace,
          boundary_type: boundary&.dig(:type),
          boundary_text: boundary&.dig(:text)
        )

        if injection_point.nil?
          return handle_missing_section(d_analysis)
        end

        # Found the section - now merge
        perform_section_merge(d_analysis, d_statements, injection_point)
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
        result.compact
      end

      def normalize_text_pattern(text)
        return nil if text.nil?
        return text if text.is_a?(Regexp)

        # Handle /regex/ syntax in strings
        if text.is_a?(String) && text.start_with?("/") && text.end_with?("/")
          Regexp.new(text[1..-2])
        else
          text
        end
      end

      def handle_missing_section(_d_analysis)
        case when_missing
        when :skip
          Result.new(
            content: destination,
            has_section: false,
            changed: false,
            message: "Section not found, skipping"
          )
        when :append
          # Append template at end of document
          new_content = destination.chomp + "\n\n" + template
          Result.new(
            content: new_content,
            has_section: false,
            changed: true,
            message: "Section not found, appended template"
          )
        when :prepend
          # Prepend template at start (after any frontmatter)
          new_content = template + "\n\n" + destination
          Result.new(
            content: new_content,
            has_section: false,
            changed: true,
            message: "Section not found, prepended template"
          )
        else
          Result.new(
            content: destination,
            has_section: false,
            changed: false,
            message: "Section not found, no action taken"
          )
        end
      end

      def perform_section_merge(_d_analysis, d_statements, injection_point)
        # Determine section boundaries in destination
        section_start_idx = injection_point.anchor.index
        section_end_idx = find_section_end(d_statements, injection_point)

        # Extract the three parts: before, section, after
        before_statements = d_statements[0...section_start_idx]
        section_statements = d_statements[section_start_idx..section_end_idx]
        after_statements = d_statements[(section_end_idx + 1)..]

        # Determine the merged section content
        section_content = statements_to_content(section_statements)
        merged_section, stats = merge_section_content(section_content)

        # Reconstruct the document
        before_content = statements_to_content(before_statements)
        after_content = statements_to_content(after_statements)

        new_content = build_merged_content(before_content, merged_section, after_content)

        changed = new_content != destination

        Result.new(
          content: new_content,
          has_section: true,
          changed: changed,
          stats: stats,
          injection_point: injection_point,
          message: changed ? "Section merged successfully" : "Section unchanged"
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

      def find_section_end(statements, injection_point)
        # If boundary was specified and found, use it (exclusive - section ends before boundary)
        if injection_point.boundary
          return injection_point.boundary.index - 1
        end

        # Otherwise, find the next node of same type (for headings, same or higher level)
        anchor = injection_point.anchor
        anchor_type = anchor.type

        # For headings, find next heading of same or higher level
        if heading_type?(anchor_type)
          anchor_level = get_heading_level(anchor)

          ((anchor.index + 1)...statements.length).each do |idx|
            stmt = statements[idx]
            if heading_type?(stmt.type)
              stmt_level = get_heading_level(stmt)
              if stmt_level && anchor_level && stmt_level <= anchor_level
                # Found next heading of same or higher level - section ends before it
                return idx - 1
              end
            end
          end
        else
          # For non-headings, find next node of same type
          ((anchor.index + 1)...statements.length).each do |idx|
            stmt = statements[idx]
            if stmt.type == anchor_type
              return idx - 1
            end
          end
        end

        # Section extends to end of document
        statements.length - 1
      end

      def heading_type?(type)
        type.to_s == "heading" || type == :heading || type == :header
      end

      def get_heading_level(stmt)
        inner = stmt.respond_to?(:unwrapped_node) ? stmt.unwrapped_node : stmt.node

        if inner.respond_to?(:header_level)
          inner.header_level
        elsif inner.respond_to?(:level)
          inner.level
        else
          nil
        end
      end

      def statements_to_content(statements)
        return "" if statements.nil? || statements.empty?

        statements.map do |stmt|
          node = stmt.respond_to?(:node) ? stmt.node : stmt
          node_to_text(node)
        end.join
      end

      def node_to_text(node)
        # Unwrap if needed
        inner = node
        while inner.respond_to?(:inner_node) && inner.inner_node != inner
          inner = inner.inner_node
        end

        if inner.respond_to?(:to_commonmark)
          inner.to_commonmark.to_s
        elsif inner.respond_to?(:to_s)
          inner.to_s
        else
          ""
        end
      end

      def build_merged_content(before, section, after)
        parts = []

        # Before content
        unless before.nil? || before.strip.empty?
          parts << before.chomp
        end

        # Merged section
        unless section.nil? || section.strip.empty?
          parts << section.chomp
        end

        # After content
        unless after.nil? || after.strip.empty?
          parts << after.chomp
        end

        result = parts.join("\n\n")
        result += "\n" unless result.end_with?("\n")
        result
      end

      def create_analysis(content)
        case parser
        when :markly
          require "markly/merge" unless defined?(Markly::Merge)
          Markly::Merge::FileAnalysis.new(content)
        when :commonmarker
          require "commonmarker/merge" unless defined?(Commonmarker::Merge)
          Commonmarker::Merge::FileAnalysis.new(content)
        when :prism
          require "prism/merge" unless defined?(Prism::Merge)
          Prism::Merge::FileAnalysis.new(content)
        when :psych
          require "psych/merge" unless defined?(Psych::Merge)
          Psych::Merge::FileAnalysis.new(content)
        else
          raise ArgumentError, "Unknown parser: #{parser}"
        end
      end

      def create_smart_merger(template_content, destination_content)
        merger_class = case parser
        when :markly
          require "markly/merge" unless defined?(Markly::Merge)
          Markly::Merge::SmartMerger
        when :commonmarker
          require "commonmarker/merge" unless defined?(Commonmarker::Merge)
          Commonmarker::Merge::SmartMerger
        when :prism
          require "prism/merge" unless defined?(Prism::Merge)
          Prism::Merge::SmartMerger
        when :psych
          require "psych/merge" unless defined?(Psych::Merge)
          Psych::Merge::SmartMerger
        else
          raise ArgumentError, "Unknown parser: #{parser}"
        end

        # Build options hash, only including non-nil values
        options = {
          preference: preference,
          add_template_only_nodes: add_missing,
        }
        options[:signature_generator] = signature_generator if signature_generator
        options[:node_typing] = node_typing if node_typing

        merger_class.new(template_content, destination_content, **options)
      end
    end
  end
end

