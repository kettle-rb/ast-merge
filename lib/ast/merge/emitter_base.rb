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
    end
  end
end
