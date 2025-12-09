# frozen_string_literal: true

module Ast
  module Merge
    # Abstract base class for SmartMerger implementations across all *-merge gems.
    #
    # SmartMergerBase provides the standard interface and common functionality
    # for intelligent file merging. Subclasses implement format-specific parsing,
    # analysis, and merge logic while inheriting the common API.
    #
    # ## Standard Options
    #
    # All SmartMerger implementations support these common options:
    #
    # - `signature_match_preference` - `:destination` (default) or `:template`
    # - `add_template_only_nodes` - `false` (default) or `true`
    # - `signature_generator` - Custom signature proc or `nil`
    # - `freeze_token` - Token for freeze block markers
    # - `match_refiner` - Fuzzy match refiner or `nil`
    # - `regions` - Region configurations for nested merging
    # - `region_placeholder` - Custom placeholder for regions
    #
    # ## Implementing a SmartMerger
    #
    # Subclasses must implement:
    # - `analysis_class` - Returns the FileAnalysis class for this format
    # - `perform_merge` - Performs the format-specific merge logic
    #
    # Subclasses may override:
    # - `default_freeze_token` - Format-specific default freeze token
    # - `resolver_class` - Returns the ConflictResolver class (if different)
    # - `result_class` - Returns the MergeResult class (if different)
    # - `aligner_class` - Returns the FileAligner class (if used)
    # - `parse_content` - Custom parsing logic
    # - `build_analysis_options` - Additional analysis options
    # - `build_resolver_options` - Additional resolver options
    #
    # @example Implementing a custom SmartMerger
    #   class MyFormat::SmartMerger < Ast::Merge::SmartMergerBase
    #     def analysis_class
    #       MyFormat::FileAnalysis
    #     end
    #
    #     def default_freeze_token
    #       "myformat-merge"
    #     end
    #
    #     private
    #
    #     def perform_merge
    #       alignment = @aligner.align
    #       process_alignment(alignment)
    #       @result
    #     end
    #   end
    #
    # @abstract Subclass and implement {#analysis_class} and {#perform_merge}
    # @api public
    class SmartMergerBase
      include RegionMergeable

      # @return [String] Template source content
      attr_reader :template_content

      # @return [String] Destination source content
      attr_reader :dest_content

      # @return [Object] Analysis of the template file
      attr_reader :template_analysis

      # @return [Object] Analysis of the destination file
      attr_reader :dest_analysis

      # @return [Object, nil] Aligner for finding matches (if applicable)
      attr_reader :aligner

      # @return [Object] Resolver for handling conflicts
      attr_reader :resolver

      # @return [Object] Result object tracking merged content
      attr_reader :result

      # @return [Symbol, Hash] Preference for signature matches
      attr_reader :signature_match_preference

      # @return [Boolean] Whether to add template-only nodes
      attr_reader :add_template_only_nodes

      # @return [String] Token for freeze block markers
      attr_reader :freeze_token

      # @return [Proc, nil] Custom signature generator
      attr_reader :signature_generator

      # @return [Object, nil] Match refiner for fuzzy matching
      attr_reader :match_refiner

      # Creates a new SmartMerger for intelligent file merging.
      #
      # @param template_content [String] Template source content
      # @param dest_content [String] Destination source content
      #
      # @param signature_generator [Proc, nil] Optional proc to generate custom signatures.
      #   The proc receives a node and should return one of:
      #   - An array representing the node's signature
      #   - `nil` to indicate the node should have no signature
      #   - The original node to fall through to default signature computation
      #
      # @param signature_match_preference [Symbol, Hash] Controls which version to use
      #   when nodes have matching signatures but different content:
      #   - `:destination` (default) - Use destination version (preserves customizations)
      #   - `:template` - Use template version (applies updates)
      #   - Hash for per-type preferences: `{ default: :destination, special: :template }`
      #
      # @param add_template_only_nodes [Boolean] Controls whether to add nodes that only
      #   exist in template:
      #   - `false` (default) - Skip template-only nodes
      #   - `true` - Add template-only nodes to result
      #
      # @param freeze_token [String, nil] Token to use for freeze block markers.
      #   Default varies by format (e.g., "prism-merge", "markly-merge")
      #
      # @param match_refiner [#call, nil] Optional match refiner for fuzzy matching.
      #   Default: nil (fuzzy matching disabled)
      #
      # @param regions [Array<Hash>, nil] Region configurations for nested merging.
      #   Each hash should contain:
      #   - `:detector` - RegionDetectorBase instance
      #   - `:merger_class` - SmartMerger class for the region (optional)
      #   - `:merger_options` - Options for the region merger (optional)
      #   - `:regions` - Nested region configs (optional, for recursive regions)
      #
      # @param region_placeholder [String, nil] Custom placeholder prefix for regions.
      #   Default: "<<<AST_MERGE_REGION_"
      #
      # @param format_options [Hash] Format-specific parser options passed to FileAnalysis.
      #   These are merged with freeze_token and signature_generator in build_full_analysis_options.
      #   Examples:
      #   - Markly: `flags: Markly::FOOTNOTES, extensions: [:table, :strikethrough]`
      #   - Commonmarker: `options: { parse: { smart: true } }`
      #   - Prism: (no additional parser options needed)
      #
      # @raise [Ast::Merge::TemplateParseError] If template has syntax errors
      # @raise [Ast::Merge::DestinationParseError] If destination has syntax errors
      def initialize(
        template_content,
        dest_content,
        signature_generator: nil,
        signature_match_preference: :destination,
        add_template_only_nodes: false,
        freeze_token: nil,
        match_refiner: nil,
        regions: nil,
        region_placeholder: nil,
        **format_options
      )
        @template_content = template_content
        @dest_content = dest_content
        @signature_generator = signature_generator
        @signature_match_preference = signature_match_preference
        @add_template_only_nodes = add_template_only_nodes
        @freeze_token = freeze_token || default_freeze_token
        @match_refiner = match_refiner
        @format_options = format_options

        # Set up region support
        setup_regions(regions: regions || [], region_placeholder: region_placeholder)

        # Extract regions before parsing (if configured)
        template_for_parsing = extract_template_regions(@template_content)
        dest_for_parsing = extract_dest_regions(@dest_content)

        # Parse and analyze both files
        @template_analysis = parse_and_analyze(template_for_parsing, :template)
        @dest_analysis = parse_and_analyze(dest_for_parsing, :destination)

        # Set up aligner (if applicable)
        @aligner = build_aligner if respond_to?(:aligner_class, true) && aligner_class

        # Set up resolver
        @resolver = build_resolver

        # Set up result
        @result = build_result
      end

      # Perform the merge operation and return the merged content as a string.
      #
      # @return [String] The merged content
      def merge
        merge_result.to_s
      end

      # Perform the merge operation and return the full result object.
      #
      # This method is memoized - subsequent calls return the cached result.
      #
      # @return [Object] The merge result (format-specific MergeResult subclass)
      def merge_result
        return @merge_result if @merge_result

        @merge_result = DebugLogger.time("#{self.class.name}#merge") do
          result = perform_merge

          # Substitute merged regions back into the result if configured
          if regions_configured? && (merged_content = result.content_string)
            final_content = substitute_merged_regions(merged_content)
            update_result_content(result, final_content)
          end

          result
        end
      end

      # Perform the merge and return detailed debug information.
      #
      # @return [Hash] Hash containing:
      #   - `:content` [String] - Final merged content
      #   - `:statistics` [Hash] - Merge decision counts
      #   - `:debug` [String, nil] - Debug output (if available)
      def merge_with_debug
        content = merge
        stats = if @result.respond_to?(:statistics)
          @result.statistics
        elsif @result.respond_to?(:decision_summary)
          @result.decision_summary
        else
          {}
        end

        debug = @result.respond_to?(:debug_output) ? @result.debug_output : nil

        {
          content: content,
          statistics: stats,
          debug: debug,
        }
      end

      # Get merge statistics.
      #
      # @return [Hash] Statistics about the merge
      def stats
        merge_result # Ensure merge has run
        if @result.respond_to?(:statistics)
          @result.statistics
        elsif @result.respond_to?(:decision_summary)
          @result.decision_summary
        else
          {}
        end
      end

      protected

      # Returns the FileAnalysis class for this format.
      #
      # @return [Class] The analysis class
      # @abstract Subclasses must implement this method
      def analysis_class
        raise NotImplementedError, "#{self.class}#analysis_class must be implemented"
      end

      # Returns the default freeze token for this format.
      #
      # @return [String] The default freeze token (e.g., "prism-merge")
      def default_freeze_token
        "ast-merge"
      end

      # Returns the ConflictResolver class for this format.
      #
      # Override if your format uses a custom resolver.
      #
      # @return [Class, nil] The resolver class, or nil to skip resolver creation
      def resolver_class
        nil
      end

      # Returns the MergeResult class for this format.
      #
      # Override if your format uses a custom result class.
      #
      # @return [Class, nil] The result class, or nil to skip result creation
      def result_class
        nil
      end

      # Returns the FileAligner class for this format.
      #
      # Override if your format uses an aligner.
      #
      # @return [Class, nil] The aligner class, or nil if not used
      def aligner_class
        nil
      end

      # Performs the format-specific merge logic.
      #
      # This method should use @template_analysis, @dest_analysis, @resolver, etc.
      # to perform the merge and populate @result.
      #
      # @return [Object] The merge result (typically @result)
      # @abstract Subclasses must implement this method
      def perform_merge
        raise NotImplementedError, "#{self.class}#perform_merge must be implemented"
      end

      # Build additional options for FileAnalysis.
      #
      # Override to add format-specific options.
      #
      # @return [Hash] Additional options for the analysis class
      def build_analysis_options
        {}
      end

      # Build additional options for ConflictResolver.
      #
      # Override to add format-specific options.
      #
      # @return [Hash] Additional options for the resolver class
      def build_resolver_options
        {}
      end

      # Update the result content after region substitution.
      #
      # Override if your result class needs special handling.
      #
      # @param result [Object] The merge result
      # @param content [String] The final content with regions substituted
      def update_result_content(result, content)
        if result.respond_to?(:content=)
          result.content = content
        elsif result.respond_to?(:set_content)
          result.set_content(content)
        end
        # Otherwise, assume the result will be recreated or doesn't need updating
      end

      private

      # Parse and analyze content, raising appropriate errors.
      #
      # @param content [String] Content to parse
      # @param source [Symbol] :template or :destination
      # @return [Object] The analysis result
      def parse_and_analyze(content, source)
        options = build_full_analysis_options

        analysis = DebugLogger.time("#{self.class.name}#analyze_#{source}") do
          analysis_class.new(content, **options)
        end

        # Check if analysis is valid (handles cases where parser stores errors without raising)
        if analysis.respond_to?(:valid?) && !analysis.valid?
          error_class = source == :template ? template_parse_error_class : destination_parse_error_class
          errors = analysis.respond_to?(:errors) ? analysis.errors : []
          raise error_class.new(errors: errors, content: content)
        end

        analysis
      rescue StandardError => e
        # Don't re-wrap our own parse errors
        raise if e.is_a?(template_parse_error_class) || e.is_a?(destination_parse_error_class)

        error_class = source == :template ? template_parse_error_class : destination_parse_error_class
        raise error_class.new(errors: [e], content: content)
      end

      # Returns the TemplateParseError class for this merger.
      # Override in subclasses to use format-specific error classes.
      #
      # @return [Class] The template parse error class
      def template_parse_error_class
        TemplateParseError
      end

      # Returns the DestinationParseError class for this merger.
      # Override in subclasses to use format-specific error classes.
      #
      # @return [Class] The destination parse error class
      def destination_parse_error_class
        DestinationParseError
      end

      # Build the complete options hash for FileAnalysis.
      #
      # Override this method to completely control what options are passed.
      # By default, includes freeze_token, signature_generator, and format_options.
      #
      # @return [Hash] Options for the analysis class
      def build_full_analysis_options
        {
          freeze_token: @freeze_token,
          signature_generator: @signature_generator,
        }.merge(build_analysis_options).merge(@format_options)
      end

      # Build the aligner instance.
      #
      # Override if your aligner has a different constructor signature.
      #
      # @return [Object] The aligner instance
      def build_aligner
        aligner_class.new(@template_analysis, @dest_analysis, match_refiner: @match_refiner)
      end

      # Build the resolver instance.
      #
      # Override if your resolver has a different constructor signature.
      #
      # @return [Object, nil] The resolver instance
      def build_resolver
        return nil unless resolver_class

        options = {
          preference: @signature_match_preference,
          template_analysis: @template_analysis,
          dest_analysis: @dest_analysis,
          add_template_only_nodes: @add_template_only_nodes,
          match_refiner: @match_refiner,
        }.merge(build_resolver_options)

        resolver_class.new(**options)
      end

      # Build the result instance.
      #
      # Override if your result class has a different constructor signature.
      #
      # @return [Object, nil] The result instance
      def build_result
        return nil unless result_class

        if result_class.instance_method(:initialize).arity == 0
          result_class.new
        else
          result_class.new(
            template_analysis: @template_analysis,
            dest_analysis: @dest_analysis,
          )
        end
      end
    end
  end
end
