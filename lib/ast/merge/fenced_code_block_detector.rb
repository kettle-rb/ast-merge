# frozen_string_literal: true

module Ast
  module Merge
    # Detects fenced code blocks with a specific language identifier.
    #
    # This detector finds Markdown-style fenced code blocks (using ``` or ~~~)
    # that have a specific language identifier. It can be configured for any
    # language: ruby, json, yaml, mermaid, etc.
    #
    # ## When to Use This Detector
    #
    # **Use FencedCodeBlockDetector when:**
    # - Working with raw Markdown text without parsing to AST
    # - Quick extraction from strings without parser dependencies
    # - Custom text processing requiring line-level precision
    # - Operating on source text directly (e.g., linters, formatters)
    #
    # **Do NOT use FencedCodeBlockDetector when:**
    # - Working with parsed Markdown AST (use native code block nodes instead)
    # - Integrating with markdown-merge's CodeBlockMerger (it uses native nodes)
    # - Using tree_haver's unified Markdown backend API
    #
    # ## Comparison: FencedCodeBlockDetector vs Native AST Nodes
    #
    # ### Native AST Approach (Preferred for AST-based Tools)
    #
    # When working with parsed Markdown AST via tree_haver (commonmarker/markly backends):
    #
    # ```ruby
    # # markdown-merge's CodeBlockMerger uses this approach:
    # language = node.fence_info.split(/\s+/).first  # e.g., "ruby"
    # content = node.string_content                   # Raw code inside block
    #
    # # Then delegate to language-specific parser:
    # case language
    # when "ruby"
    #   merger = Prism::Merge::SmartMerger.new(template, dest, preference: :destination)
    #   merged_content = merger.merge  # Prism parses Ruby code into full AST!
    # when "yaml"
    #   merger = Psych::Merge::SmartMerger.new(template, dest, preference: :destination)
    #   merged_content = merger.merge  # Psych parses YAML into AST!
    # when "json"
    #   merger = Json::Merge::SmartMerger.new(template, dest, preference: :destination)
    #   merged_content = merger.merge  # JSON parser creates AST!
    # when "bash"
    #   merger = Bash::Merge::SmartMerger.new(template, dest, preference: :destination)
    #   merged_content = merger.merge  # tree-sitter parses bash into AST!
    # end
    # ```
    #
    # **Advantages of Native AST approach:**
    # - ✓ Parser handles all edge cases (nested backticks, indentation, etc.)
    # - ✓ Respects node boundaries from authoritative source
    # - ✓ No regex brittleness
    # - ✓ Automatic handling of ``` and ~~~ fence styles
    # - ✓ Enables TRUE language-aware merging (not just text replacement)
    # - ✓ Language-specific parsers create full ASTs of embedded code
    # - ✓ Smart merging at semantic level (method definitions, YAML keys, JSON properties)
    #
    # ### Text-Based Approach (This Class)
    #
    # When working with raw text:
    #
    # ```ruby
    # detector = FencedCodeBlockDetector.ruby
    # regions = detector.detect_all(markdown_text)
    # regions.each do |region|
    #   puts "Ruby code at lines #{region.start_line}-#{region.end_line}"
    #   # region.content is just a string - NO parsing happens
    # end
    # ```
    #
    # **Limitations of text-based approach:**
    # - • Uses regex to find blocks (may miss edge cases)
    # - • Returns strings, not parsed structures
    # - • Cannot perform semantic merging
    # - • Manual handling of fence variations
    # - • No language-specific intelligence
    #
    # ## Real-World Example: markdown-merge Inner Code Block Merging
    #
    # When `inner_merge_code_blocks: true` is enabled in markdown-merge:
    #
    # 1. **Markdown Parser** (commonmarker/markly) parses markdown into AST
    #    - Creates code_block nodes with `fence_info` and `string_content`
    #
    # 2. **CodeBlockMerger** extracts code using native node properties:
    #    ```ruby
    #    language = node.fence_info.split(/\s+/).first
    #    template_code = template_node.string_content
    #    dest_code = dest_node.string_content
    #    ```
    #
    # 3. **Language-Specific Parser** creates FULL AST of the embedded code:
    #    - `Prism::Merge` → Prism parses Ruby into complete AST (ClassNode, DefNode, etc.)
    #    - `Psych::Merge` → Psych parses YAML into document structure
    #    - `Json::Merge` → JSON parser creates object/array tree
    #    - `Bash::Merge` → tree-sitter creates bash statement AST
    #
    # 4. **Smart Merger** performs SEMANTIC merging at AST level:
    #    - Ruby: Merges class definitions, preserves custom methods
    #    - YAML: Merges keys, preserves custom configuration values
    #    - JSON: Merges objects, destination values win on conflicts
    #    - Bash: Merges statements, preserves custom exports
    #
    # 5. **Result** is intelligently merged code, not simple text concatenation!
    #
    # **This means:** The embedded code is FULLY PARSED by its native language parser,
    # enabling true semantic-level merging. FencedCodeBlockDetector would only find
    # the text boundaries - it cannot perform this semantic merging.
    #
    # @example Detecting Ruby code blocks
    #   detector = FencedCodeBlockDetector.new("ruby", aliases: ["rb"])
    #   regions = detector.detect_all(markdown_source)
    #
    # @example Using factory methods
    #   detector = FencedCodeBlockDetector.ruby
    #   detector = FencedCodeBlockDetector.yaml
    #   detector = FencedCodeBlockDetector.json
    #
    # @api public
    class FencedCodeBlockDetector < RegionDetectorBase
      # @return [String] The primary language identifier
      attr_reader :language

      # @return [Array<String>] Alternative language identifiers
      attr_reader :aliases

      # Creates a new detector for the specified language.
      #
      # @param language [String, Symbol] The language identifier (e.g., "ruby", "json")
      # @param aliases [Array<String, Symbol>] Alternative identifiers (e.g., ["rb"] for ruby)
      def initialize(language, aliases: [])
        super()
        @language = language.to_s.downcase
        @aliases = aliases.map { |a| a.to_s.downcase }
        @all_identifiers = [@language] + @aliases
      end

      # @return [Symbol] The region type (e.g., :ruby_code_block)
      def region_type
        :"#{@language}_code_block"
      end

      # Check if a language identifier matches this detector.
      #
      # @param lang [String] The language identifier to check
      # @return [Boolean] true if the language matches
      def matches_language?(lang)
        @all_identifiers.include?(lang.to_s.downcase)
      end

      # Detects all fenced code blocks with the configured language.
      #
      # @param source [String] The full document content
      # @return [Array<Region>] All detected code blocks, sorted by start_line
      def detect_all(source)
        return [] if source.nil? || source.empty?

        regions = []
        lines = source.lines
        in_block = false
        start_line = nil
        content_lines = []
        current_language = nil
        fence_char = nil
        fence_length = nil
        indent = ""

        lines.each_with_index do |line, idx|
          line_num = idx + 1

          if !in_block
            # Match opening fence: ```lang or ~~~lang (optionally indented)
            match = line.match(/^(\s*)(`{3,}|~{3,})(\w*)\s*$/)
            if match
              indent = match[1] || ""
              fence = match[2]
              lang = match[3].downcase

              if @all_identifiers.include?(lang)
                in_block = true
                start_line = line_num
                content_lines = []
                current_language = lang
                fence_char = fence[0]
                fence_length = fence.length
              end
            end
          elsif line.match?(/^#{Regexp.escape(indent)}#{Regexp.escape(fence_char)}{#{fence_length},}\s*$/)
            # Match closing fence (must use same char, same indent, and at least same length)
            opening_fence = "#{fence_char * fence_length}#{current_language}"
            closing_fence = fence_char * fence_length

            regions << build_region(
              type: region_type,
              content: content_lines.join,
              start_line: start_line,
              end_line: line_num,
              delimiters: [opening_fence, closing_fence],
              metadata: {language: current_language, indent: indent.empty? ? nil : indent},
            )
            in_block = false
            start_line = nil
            content_lines = []
            current_language = nil
            fence_char = nil
            fence_length = nil
            indent = ""
          else
            # Accumulate content lines (strip the indent if present)
            content_lines << if indent.empty?
              line
            else
              # Strip the common indent from content lines
              line.sub(/^#{Regexp.escape(indent)}/, "")
            end
          end
        end

        # Note: Unclosed blocks are ignored (no region created)
        regions
      end

      # @return [String] A description of this detector
      def inspect
        aliases_str = @aliases.empty? ? "" : " aliases=#{@aliases.inspect}"
        "#<#{self.class.name} language=#{@language}#{aliases_str}>"
      end

      class << self
        # Creates a detector for Ruby code blocks.
        # @return [FencedCodeBlockDetector]
        def ruby
          new("ruby", aliases: ["rb"])
        end

        # Creates a detector for JSON code blocks.
        # @return [FencedCodeBlockDetector]
        def json
          new("json")
        end

        # Creates a detector for YAML code blocks.
        # @return [FencedCodeBlockDetector]
        def yaml
          new("yaml", aliases: ["yml"])
        end

        # Creates a detector for TOML code blocks.
        # @return [FencedCodeBlockDetector]
        def toml
          new("toml")
        end

        # Creates a detector for Mermaid diagram blocks.
        # @return [FencedCodeBlockDetector]
        def mermaid
          new("mermaid")
        end

        # Creates a detector for JavaScript code blocks.
        # @return [FencedCodeBlockDetector]
        def javascript
          new("javascript", aliases: ["js"])
        end

        # Creates a detector for TypeScript code blocks.
        # @return [FencedCodeBlockDetector]
        def typescript
          new("typescript", aliases: ["ts"])
        end

        # Creates a detector for Python code blocks.
        # @return [FencedCodeBlockDetector]
        def python
          new("python", aliases: ["py"])
        end

        # Creates a detector for Bash/Shell code blocks.
        # @return [FencedCodeBlockDetector]
        def bash
          new("bash", aliases: ["sh", "shell", "zsh"])
        end

        # Creates a detector for SQL code blocks.
        # @return [FencedCodeBlockDetector]
        def sql
          new("sql")
        end

        # Creates a detector for HTML code blocks.
        # @return [FencedCodeBlockDetector]
        def html
          new("html")
        end

        # Creates a detector for CSS code blocks.
        # @return [FencedCodeBlockDetector]
        def css
          new("css")
        end

        # Creates a detector for Markdown code blocks (nested markdown).
        # @return [FencedCodeBlockDetector]
        def markdown
          new("markdown", aliases: ["md"])
        end
      end
    end
  end
end
