# frozen_string_literal: true

# Tests for table formatting preservation during markdown merges.
# The fix uses source-based rendering to preserve original formatting.

RSpec.describe "Table Formatting Preservation", :commonmarker_merge, :markly_merge do
  # Input markdown with padded/aligned table columns
  let(:markdown_with_padded_table) do
    <<~MD
      # Test Document

      | Name        | Value      | Description                    |
      |-------------|------------|--------------------------------|
      | short       | 1          | A short description            |
      | much_longer | 12345      | A much longer description here |
    MD
  end

  shared_examples "table formatting handling" do |backend|
    let(:analysis_class) do
      case backend
      when :markly
        require "markly/merge"
        Markly::Merge::FileAnalysis
      when :commonmarker
        require "commonmarker/merge"
        Commonmarker::Merge::FileAnalysis
      else
        raise ArgumentError, "Unknown backend: #{backend}"
      end
    end

    describe "source-based rendering with #{backend}" do
      it "parses tables correctly" do
        analysis = analysis_class.new(markdown_with_padded_table)

        table_nodes = analysis.statements.select do |node|
          node.respond_to?(:type) && node.type.to_s == "table"
        end

        expect(table_nodes).not_to be_empty
      end

      it "preserves table padding when using source_range" do
        analysis = analysis_class.new(markdown_with_padded_table)

        # Build NavigableStatements
        statements = Ast::Merge::NavigableStatement.build_list(analysis.statements)

        # Find the table
        table_stmt = statements.find { |s| s.type.to_s == "table" }
        expect(table_stmt).not_to be_nil

        # Extract using source_range (should preserve padding)
        pos = table_stmt.node.source_position
        source_text = analysis.source_range(pos[:start_line], pos[:end_line])

        # The source text should contain the original padded columns
        expect(source_text).to include("|-------------|")
        expect(source_text).to include("| Name        |")
      end

      it "documents that to_commonmark normalizes table padding" do
        analysis = analysis_class.new(markdown_with_padded_table)

        # Find the table node and use to_commonmark
        table_stmt = analysis.statements.find do |node|
          node.respond_to?(:type) && node.type.to_s == "table"
        end
        expect(table_stmt).not_to be_nil

        inner = table_stmt
        while inner.respond_to?(:inner_node) && inner.inner_node != inner
          inner = inner.inner_node
        end

        rendered = inner.respond_to?(:to_commonmark) ? inner.to_commonmark : inner.to_s

        # to_commonmark normalizes padding - this is expected behavior we work around
        expect(rendered).to include("| --- |")
      end
    end
  end

  context "with markly backend", :markly_merge do
    it_behaves_like "table formatting handling", :markly
  end

  context "with commonmarker backend", :commonmarker_merge do
    it_behaves_like "table formatting handling", :commonmarker
  end
end
