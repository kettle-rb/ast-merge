# frozen_string_literal: true

module Ast
  module Merge
    # Base class for emitters that convert AST structures back to text.
    # Provides common functionality for tracking indentation, managing output lines,
    # and handling comments.
    #
    # Subclasses implement format-specific emission methods (e.g., emit_pair for JSON,
    # emit_variable_assignment for Bash, etc.)
    #
    # @example Implementing a custom emitter
    #   class MyEmitter < Ast::Merge::EmitterBase
    #     def emit_my_construct(data)
    #       add_comma_if_needed if @needs_separator
    #       @lines << "#{current_indent}my_syntax: #{data}"
    #       @needs_separator = true
    #     end
    #   end
    class EmitterBase
      # @return [Array<String>] Output lines
      attr_reader :lines

      # @return [Integer] Current indentation level
      attr_reader :indent_level

      # @return [Integer] Spaces per indent level
      attr_reader :indent_size

      # Initialize a new emitter
      #
      # @param indent_size [Integer] Number of spaces per indent level
      # @param options [Hash] Additional options for subclasses
      def initialize(indent_size: 2, **options)
        @lines = []
        @indent_level = 0
        @indent_size = indent_size
        initialize_subclass_state(**options)
      end

      # Hook for subclasses to initialize their own state
      # @param options [Hash] Additional options
      def initialize_subclass_state(**options)
        # Override in subclasses if needed
      end

      # Emit a blank line
      def emit_blank_line
        @lines << ""
      end

      # Emit leading comments from CommentTracker
      #
      # @param comments [Array<Hash>] Comment hashes with :text, :indent, etc.
      def emit_leading_comments(comments)
        comments.each do |comment|
          emit_tracked_comment(comment)
        end
      end

      # Emit a comment from CommentTracker hash
      # Subclasses should override this to handle format-specific comment syntax
      #
      # @param comment [Hash] Comment hash with :text, :indent, :block, etc.
      def emit_tracked_comment(comment)
        raise NotImplementedError, "Subclasses must implement emit_tracked_comment"
      end

      # Emit a comment using the emitter's native syntax.
      # Subclasses should override this to support full-line and inline emission.
      #
      # @param text [String] Comment text without the delimiter
      # @param inline [Boolean] Whether this is an inline comment
      def emit_comment(text, inline: false)
        raise NotImplementedError, "Subclasses must implement emit_comment"
      end

      # Emit a shared normalized comment region.
      #
      # Preserves explicit blank-line nodes and can also recreate blank gaps between
      # comment lines by consulting original source lines when those gaps are not
      # already represented as `Comment::Empty` nodes.
      #
      # @param region [Comment::Region, nil] Region to emit
      # @param inline [Boolean, nil] Force inline emission mode
      # @param source_lines [Array<String>, nil] Original source lines for gap preservation
      def emit_comment_region(region, inline: nil, source_lines: nil)
        return unless region
        return unless region.respond_to?(:nodes)
        return if region.respond_to?(:empty?) && region.empty?

        inline = region.inline? if inline.nil? && region.respond_to?(:inline?)
        return emit_inline_comment_region(region) if inline

        previous_line = nil
        region.nodes.each do |node|
          current_line = comment_region_line_number(node)
          emit_region_gap_lines(previous_line, current_line, source_lines)
          emit_comment_node(node)
          previous_line = current_line
        end
      end

      # Emit selected regions from a shared comment attachment.
      #
      # @param attachment [Comment::Attachment, nil] Attachment to emit
      # @param leading [Boolean] Whether to emit the leading region
      # @param inline [Boolean] Whether to emit the inline region
      # @param trailing [Boolean] Whether to emit the trailing region
      # @param orphan [Boolean] Whether to emit orphan regions in order
      # @param source_lines [Array<String>, nil] Original source lines for gap preservation
      def emit_comment_attachment(attachment, leading: true, inline: false, trailing: false, orphan: false, source_lines: nil)
        return unless attachment
        return unless attachment.respond_to?(:leading_region) && attachment.respond_to?(:inline_region)

        regions = []
        regions << attachment.leading_region if leading && attachment.leading_region
        regions << attachment.inline_region if inline && attachment.inline_region
        regions << attachment.trailing_region if trailing && attachment.respond_to?(:trailing_region) && attachment.trailing_region
        regions.concat(Array(attachment.orphan_regions)) if orphan && attachment.respond_to?(:orphan_regions)

        previous_region_end_line = nil
        regions.each do |region|
          current_region_start_line = region.respond_to?(:start_line) ? region.start_line : nil
          emit_region_gap_lines(previous_region_end_line, current_region_start_line, source_lines)
          emit_comment_region(region, inline: region.respond_to?(:inline?) ? region.inline? : nil, source_lines: source_lines)
          previous_region_end_line = region.respond_to?(:end_line) ? region.end_line : previous_region_end_line
        end
      end

      # Emit raw lines as-is (for preserving exact formatting)
      #
      # @param raw_lines [Array<String>] Lines to emit without modification
      def emit_raw_lines(raw_lines)
        raw_lines.each { |line| @lines << line.chomp }
      end

      # Get the output as a single string
      # Subclasses may override to customize output format (e.g., to_json, to_yaml)
      #
      # @return [String]
      def to_s
        content = @lines.join("\n")
        content += "\n" unless content.empty? || content.end_with?("\n")
        content
      end

      # Clear the emitter state
      def clear
        @lines = []
        @indent_level = 0
        clear_subclass_state
      end

      # Hook for subclasses to clear their own state
      def clear_subclass_state
        # Override in subclasses if needed
      end

      # Increase indentation level
      def indent
        @indent_level += 1
      end

      # Decrease indentation level
      def dedent
        @indent_level -= 1 if @indent_level > 0
      end

      protected

      # Get the current indentation string
      # @return [String]
      def current_indent
        " " * (@indent_level * @indent_size)
      end

      # Add a line with current indentation
      # @param content [String] Line content
      def add_indented_line(content)
        @lines << "#{current_indent}#{content}"
      end

      private

      def emit_inline_comment_region(region)
        text = Array(region.nodes).filter_map do |node|
          if node.respond_to?(:normalized_content)
            node.normalized_content
          else
            node.to_s
          end
        end.join(" ").strip

        emit_comment(text, inline: true) unless text.empty?
      end

      def emit_comment_node(node)
        if node.respond_to?(:slice)
          @lines << node.slice.to_s.chomp
        elsif node.respond_to?(:text)
          @lines << node.text.to_s.chomp
        else
          emit_comment(node.respond_to?(:normalized_content) ? node.normalized_content : node.to_s)
        end
      end

      def emit_region_gap_lines(previous_line, current_line, source_lines)
        return unless previous_line && current_line && current_line > previous_line + 1

        if source_lines
          gap_lines = source_lines[previous_line, current_line - previous_line - 1] || []
          blank_lines = gap_lines.select { |line| line.to_s.strip.empty? }
          emit_raw_lines(blank_lines) if blank_lines.any?
        else
          (current_line - previous_line - 1).times { emit_blank_line }
        end
      end

      def comment_region_line_number(node)
        return node.line_number if node.respond_to?(:line_number)
        return node.location.start_line if node.respond_to?(:location) && node.location

        nil
      end
    end
  end
end
