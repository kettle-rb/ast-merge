# frozen_string_literal: true

module Ast
  module Merge
    # Wraps any node (parser-backed or synthetic) with uniform navigation.
    #
    # Provides two levels of navigation:
    # 1. **Flat list navigation**: prev_statement, next_statement, index
    #    - Works for ALL nodes (synthetic and parser-backed)
    #    - Represents position in the flattened statement list
    #
    # 2. **Tree navigation**: tree_parent, tree_next, tree_previous, tree_children
    #    - Only available for parser-backed nodes
    #    - Delegates to inner_node's tree methods
    #
    # This allows code to work with the flat list for simple merging,
    # while still accessing tree structure for section-aware operations.
    #
    # @example Basic usage
    #   statements = NavigableStatement.build_list(raw_statements)
    #   stmt = statements[0]
    #
    #   # Flat navigation (always works)
    #   stmt.next           # => next statement in flat list
    #   stmt.previous       # => previous statement in flat list
    #   stmt.index          # => position in array
    #
    #   # Tree navigation (when available)
    #   stmt.tree_parent    # => parent in original AST (or nil)
    #   stmt.tree_next      # => next sibling in original AST (or nil)
    #   stmt.tree_children  # => children in original AST (or [])
    #
    # @example Section grouping
    #   # Group statements into sections by heading level
    #   sections = NavigableStatement.group_by_heading(statements, level: 3)
    #   sections.each do |section|
    #     puts "Section: #{section.heading.text}"
    #     section.statements.each { |s| puts "  - #{s.type}" }
    #   end
    #
    class NavigableStatement
      # @return [Object] The wrapped node (parser-backed or synthetic)
      attr_reader :node

      # @return [Integer] Index in the flattened statement list
      attr_reader :index

      # @return [NavigableStatement, nil] Previous statement in flat list
      attr_accessor :prev_statement

      # @return [NavigableStatement, nil] Next statement in flat list
      attr_accessor :next_statement

      # @return [Object, nil] Optional context/metadata for this statement
      attr_accessor :context

      # Initialize a NavigableStatement wrapper.
      #
      # @param node [Object] The node to wrap
      # @param index [Integer] Position in the statement list
      def initialize(node, index:)
        @node = node
        @index = index
        @prev_statement = nil
        @next_statement = nil
        @context = nil
      end

      class << self
        # Build a linked list of NavigableStatements from raw statements.
        #
        # @param raw_statements [Array<Object>] Raw statement nodes
        # @return [Array<NavigableStatement>] Linked statement list
        def build_list(raw_statements)
          statements = raw_statements.each_with_index.map do |node, i|
            new(node, index: i)
          end

          # Link siblings in flat list
          statements.each_cons(2) do |prev_stmt, next_stmt|
            prev_stmt.next_statement = next_stmt
            next_stmt.prev_statement = prev_stmt
          end

          statements
        end

        # Find statements matching a query.
        #
        # @param statements [Array<NavigableStatement>] Statement list
        # @param type [Symbol, String, nil] Node type to match (nil = any)
        # @param text [String, Regexp, nil] Text pattern to match
        # @yield [NavigableStatement] Optional block for custom matching
        # @return [Array<NavigableStatement>] Matching statements
        def find_matching(statements, type: nil, text: nil, &block)
          statements.select do |stmt|
            matches = true
            matches &&= stmt.type.to_s == type.to_s if type
            matches &&= text.is_a?(Regexp) ? stmt.text.match?(text) : stmt.text.include?(text.to_s) if text
            matches &&= yield(stmt) if block_given?
            matches
          end
        end

        # Find the first statement matching criteria.
        #
        # @param statements [Array<NavigableStatement>] Statement list
        # @param type [Symbol, String, nil] Node type to match
        # @param text [String, Regexp, nil] Text pattern to match
        # @yield [NavigableStatement] Optional block for custom matching
        # @return [NavigableStatement, nil] First matching statement
        def find_first(statements, type: nil, text: nil, &block)
          find_matching(statements, type: type, text: text, &block).first
        end
      end

      # ============================================================
      # Flat list navigation (always available)
      # ============================================================

      # @return [NavigableStatement, nil] Next statement in flat list
      def next
        next_statement
      end

      # @return [NavigableStatement, nil] Previous statement in flat list
      def previous
        prev_statement
      end

      # @return [Boolean] true if this is the first statement
      def first?
        prev_statement.nil?
      end

      # @return [Boolean] true if this is the last statement
      def last?
        next_statement.nil?
      end

      # Iterate from this statement to the end (or until block returns false).
      #
      # @yield [NavigableStatement] Each statement
      # @return [Enumerator, nil]
      def each_following(&block)
        return to_enum(:each_following) unless block_given?

        current = self.next
        while current
          break unless yield(current)
          current = current.next
        end
      end

      # Collect statements until a condition is met.
      #
      # @yield [NavigableStatement] Each statement
      # @return [Array<NavigableStatement>] Statements until condition
      def take_until(&block)
        result = []
        each_following do |stmt|
          break if yield(stmt)
          result << stmt
          true
        end
        result
      end

      # ============================================================
      # Tree navigation (delegates to inner_node when available)
      # ============================================================

      # @return [Object, nil] Parent node in original AST
      def tree_parent
        inner = unwrapped_node
        inner.parent if inner.respond_to?(:parent)
      end

      # @return [Object, nil] Next sibling in original AST
      def tree_next
        inner = unwrapped_node
        inner.next if inner.respond_to?(:next)
      end

      # @return [Object, nil] Previous sibling in original AST
      def tree_previous
        inner = unwrapped_node
        inner.previous if inner.respond_to?(:previous)
      end

      # @return [Array<Object>] Children in original AST
      def tree_children
        inner = unwrapped_node
        if inner.respond_to?(:each)
          inner.to_a
        elsif inner.respond_to?(:children)
          inner.children
        else
          []
        end
      end

      # @return [Object, nil] First child in original AST
      def tree_first_child
        inner = unwrapped_node
        inner.first_child if inner.respond_to?(:first_child)
      end

      # @return [Object, nil] Last child in original AST
      def tree_last_child
        inner = unwrapped_node
        inner.last_child if inner.respond_to?(:last_child)
      end

      # @return [Boolean] true if tree navigation is available
      def has_tree_navigation?
        inner = unwrapped_node
        inner.respond_to?(:parent) || inner.respond_to?(:next)
      end

      # @return [Boolean] true if this is a synthetic node (no tree navigation)
      def synthetic?
        !has_tree_navigation?
      end

      # Calculate the tree depth (distance from root).
      #
      # @return [Integer] Depth in tree (0 = root level)
      def tree_depth
        depth = 0
        current = tree_parent
        while current
          depth += 1
          # Navigate up through parents
          if current.respond_to?(:parent)
            current = current.parent
          else
            break
          end
        end
        depth
      end

      # Check if this node is at same or shallower depth than another.
      # Useful for determining section boundaries.
      #
      # @param other [NavigableStatement, Integer] Other statement or depth value
      # @return [Boolean] true if this node is at same or shallower depth
      def same_or_shallower_than?(other)
        other_depth = other.is_a?(Integer) ? other : other.tree_depth
        tree_depth <= other_depth
      end

      # ============================================================
      # Node delegation
      # ============================================================

      # @return [Symbol, String] Node type
      def type
        node.respond_to?(:type) ? node.type : node.class.name.split("::").last
      end

      # @return [Array, Object, nil] Node signature for matching
      def signature
        node.signature if node.respond_to?(:signature)
      end

      # @return [String] Node text content
      def text
        if node.respond_to?(:to_plaintext)
          node.to_plaintext.to_s
        elsif node.respond_to?(:to_commonmark)
          node.to_commonmark.to_s
        elsif node.respond_to?(:slice)
          node.slice.to_s
        elsif node.respond_to?(:text)
          node.text.to_s
        else
          node.to_s
        end
      end

      # @return [Hash, nil] Source position info
      def source_position
        node.source_position if node.respond_to?(:source_position)
      end

      # @return [Integer, nil] Start line number
      def start_line
        pos = source_position
        pos[:start_line] if pos
      end

      # @return [Integer, nil] End line number
      def end_line
        pos = source_position
        pos[:end_line] if pos
      end

      # ============================================================
      # Node attribute helpers (language-agnostic)
      # ============================================================

      # Check if this node matches a type.
      #
      # @param expected_type [Symbol, String] Type to check
      # @return [Boolean]
      def type?(expected_type)
        type.to_s == expected_type.to_s
      end

      # Check if this node's text matches a pattern.
      #
      # @param pattern [String, Regexp] Pattern to match
      # @return [Boolean]
      def text_matches?(pattern)
        case pattern
        when Regexp
          text.match?(pattern)
        else
          text.include?(pattern.to_s)
        end
      end

      # Get an attribute from the underlying node.
      #
      # Tries multiple method names to support different parser APIs.
      #
      # @param name [Symbol, String] Attribute name
      # @param aliases [Array<Symbol>] Alternative method names
      # @return [Object, nil] Attribute value
      def node_attribute(name, *aliases)
        inner = unwrapped_node
        [name, *aliases].each do |method_name|
          return inner.send(method_name) if inner.respond_to?(method_name)
        end
        nil
      end

      # ============================================================
      # Utilities
      # ============================================================

      # Get the unwrapped inner node.
      #
      # @return [Object] The innermost node
      def unwrapped_node
        current = node
        while current.respond_to?(:inner_node) && current.inner_node != current
          current = current.inner_node
        end
        current
      end

      # @return [String] Human-readable representation
      def inspect
        "#<NavigableStatement[#{index}] type=#{type} tree=#{has_tree_navigation?}>"
      end

      # @return [String] String representation
      def to_s
        text.to_s.strip[0, 50]
      end

      # Delegate unknown methods to the wrapped node.
      def method_missing(method, *args, &block)
        if node.respond_to?(method)
          node.send(method, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method, include_private = false)
        node.respond_to?(method, include_private) || super
      end
    end

    # Represents a location in a document where content can be injected.
    #
    # InjectionPoint is language-agnostic - it works with any AST structure.
    # It defines WHERE to inject content and HOW (as child, sibling, or replacement).
    #
    # @example Inject as first child of a class
    #   point = InjectionPoint.new(
    #     anchor: class_node,
    #     position: :first_child
    #   )
    #
    # @example Inject after a specific method
    #   point = InjectionPoint.new(
    #     anchor: method_node,
    #     position: :after
    #   )
    #
    # @example Replace a range of nodes
    #   point = InjectionPoint.new(
    #     anchor: start_node,
    #     position: :replace,
    #     boundary: end_node
    #   )
    #
    class InjectionPoint
      # Valid positions for injection
      POSITIONS = %i[
        before
        #
        Insert
        as
        previous
        sibling
        of
        anchor
        after
        #
        Insert
        as
        next
        sibling
        of
        anchor
        first_child
        #
        Insert
        as
        first
        child
        of
        anchor
        last_child
        #
        Insert
        as
        last
        child
        of
        anchor
        replace
        #
        Replace
        anchor
        (and
        optionally
        through
        boundary)
      ].freeze

      # @return [NavigableStatement] The anchor node for injection
      attr_reader :anchor

      # @return [Symbol] Position relative to anchor (:before, :after, :first_child, :last_child, :replace)
      attr_reader :position

      # @return [NavigableStatement, nil] End boundary for :replace position
      attr_reader :boundary

      # @return [Hash] Additional metadata about this injection point
      attr_reader :metadata

      # Initialize an InjectionPoint.
      #
      # @param anchor [NavigableStatement] The reference node
      # @param position [Symbol] Where to inject relative to anchor
      # @param boundary [NavigableStatement, nil] End boundary for replacements
      # @param metadata [Hash] Additional info (e.g., match details)
      def initialize(anchor:, position:, boundary: nil, **metadata)
        validate_position!(position)
        validate_boundary!(position, boundary)

        @anchor = anchor
        @position = position
        @boundary = boundary
        @metadata = metadata
      end

      # @return [Boolean] true if this is a replacement (not insertion)
      def replacement?
        position == :replace
      end

      # @return [Boolean] true if this injects as a child
      def child_injection?
        %i[first_child last_child].include?(position)
      end

      # @return [Boolean] true if this injects as a sibling
      def sibling_injection?
        %i[before after].include?(position)
      end

      # Get all statements that would be replaced.
      #
      # @return [Array<NavigableStatement>] Statements to replace (empty if not replacement)
      def replaced_statements
        return [] unless replacement?
        return [anchor] unless boundary

        result = [anchor]
        current = anchor.next
        while current && current != boundary
          result << current
          current = current.next
        end
        result << boundary if boundary
        result
      end

      # @return [Integer, nil] Start line of injection point
      def start_line
        anchor.start_line
      end

      # @return [Integer, nil] End line of injection point
      def end_line
        (boundary || anchor).end_line
      end

      # @return [String] Human-readable representation
      def inspect
        boundary_info = boundary ? " to #{boundary.index}" : ""
        "#<InjectionPoint position=#{position} anchor=#{anchor.index}#{boundary_info}>"
      end

      private

      def validate_position!(position)
        return if POSITIONS.include?(position)

        raise ArgumentError, "Invalid position: #{position}. Must be one of: #{POSITIONS.join(", ")}"
      end

      def validate_boundary!(position, boundary)
        return unless boundary && position != :replace

        raise ArgumentError, "boundary is only valid with position: :replace"
      end
    end

    # Finds injection points in a document based on matching rules.
    #
    # This is language-agnostic - the matching rules work on the unified
    # NavigableStatement interface regardless of the underlying parser.
    #
    # @example Find where to inject constants in a Ruby class
    #   finder = InjectionPointFinder.new(statements)
    #   point = finder.find(
    #     type: :class,
    #     text: /class Choo/,
    #     position: :first_child
    #   )
    #
    # @example Find and replace a constant definition
    #   point = finder.find(
    #     type: :constant_assignment,
    #     text: /DAR\s*=/,
    #     position: :replace
    #   )
    #
    class InjectionPointFinder
      # @return [Array<NavigableStatement>] The statement list to search
      attr_reader :statements

      def initialize(statements)
        @statements = statements
      end

      # Find an injection point based on matching criteria.
      #
      # @param type [Symbol, String, nil] Node type to match
      # @param text [String, Regexp, nil] Text pattern to match
      # @param position [Symbol] Where to inject (:before, :after, :first_child, :last_child, :replace)
      # @param boundary_type [Symbol, String, nil] Node type for replacement boundary
      # @param boundary_text [String, Regexp, nil] Text pattern for replacement boundary
      # @param boundary_matcher [Proc, nil] Custom matcher for boundary (receives NavigableStatement, returns boolean)
      # @param boundary_same_or_shallower [Boolean] If true, boundary is next node at same or shallower tree depth
      # @yield [NavigableStatement] Optional custom matcher
      # @return [InjectionPoint, nil] Injection point if anchor found
      def find(type: nil, text: nil, position:, boundary_type: nil, boundary_text: nil, boundary_matcher: nil, boundary_same_or_shallower: false, &block)
        anchor = NavigableStatement.find_first(statements, type: type, text: text, &block)
        return unless anchor

        boundary = nil
        if position == :replace && (boundary_type || boundary_text || boundary_matcher || boundary_same_or_shallower)
          # Find boundary starting after anchor
          remaining = statements[(anchor.index + 1)..]

          if boundary_same_or_shallower
            # Find next node at same or shallower tree depth
            # This is language-agnostic: ends section at next sibling or ancestor's sibling
            anchor_depth = anchor.tree_depth
            boundary = remaining.find do |stmt|
              # Must match type if specified
              next false if boundary_type && stmt.type.to_s != boundary_type.to_s
              next false if boundary_text && !stmt.text_matches?(boundary_text)
              # Check tree depth
              stmt.same_or_shallower_than?(anchor_depth)
            end
          elsif boundary_matcher
            # Use custom matcher
            boundary = remaining.find { |stmt| boundary_matcher.call(stmt) }
          else
            boundary = NavigableStatement.find_first(
              remaining,
              type: boundary_type,
              text: boundary_text,
            )
          end
        end

        InjectionPoint.new(
          anchor: anchor,
          position: position,
          boundary: boundary,
          match: {type: type, text: text},
        )
      end

      # Find all injection points matching criteria.
      #
      # @param (see #find)
      # @return [Array<InjectionPoint>] All matching injection points
      def find_all(type: nil, text: nil, position:, &block)
        anchors = NavigableStatement.find_matching(statements, type: type, text: text, &block)
        anchors.map do |anchor|
          InjectionPoint.new(anchor: anchor, position: position)
        end
      end
    end
  end
end
