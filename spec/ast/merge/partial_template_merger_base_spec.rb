# frozen_string_literal: true

RSpec.describe Ast::Merge::PartialTemplateMergerBase do
  FakeNode = Struct.new(:text, :source_position, keyword_init: true)
  FakeAnalysis = Struct.new(:source, keyword_init: true)

  let(:merger_class) do
    Class.new(described_class) do
      def create_analysis(content)
        content
      end

      def create_smart_merger(template_content, destination_content)
        Struct.new(:merge_result).new(
          Struct.new(:content, :stats).new(template_content, {template: template_content, destination: destination_content})
        )
      end

      def find_section_end(statements, injection_point)
        injection_point.anchor.index
      end

      def node_to_text(node, analysis = nil)
        pos = node.respond_to?(:source_position) ? node.source_position : nil
        if analysis&.respond_to?(:source) && pos
          analysis.source.lines[(pos[:start_line] - 1)..(pos[:end_line] - 1)].join
        else
          [node, analysis].compact.join("|")
        end
      end
    end
  end

  let(:merger) do
    merger_class.new(
      template: "template section\n",
      destination: "destination document\n",
      anchor: {type: :heading, text: /Section/},
    )
  end

  describe "#build_merged_content" do
    it "normalizes separators to a single blank line between before, section, and after content" do
      result = merger.send(
        :build_merged_content,
        "# Before\n\n\n",
        "## Section\nBody\n\n",
        "# After\n\n",
      )

      expect(result).to eq("# Before\n\n## Section\nBody\n\n# After\n")
    end

    it "does not prepend a separator when only section content exists" do
      result = merger.send(:build_merged_content, "", "## Section\n", nil)

      expect(result).to eq("## Section\n")
    end

    it "joins before and after with one blank line when the merged section is empty" do
      result = merger.send(:build_merged_content, "# Before\n", "", "# After\n")

      expect(result).to eq("# Before\n\n# After\n")
    end

    it "returns an empty string when all content parts are blank" do
      result = merger.send(:build_merged_content, "", "\n", nil)

      expect(result).to eq("")
    end
  end

  describe "source-backed structural recomposition" do
    it "preserves exact surrounding destination whitespace when statement line ranges are available" do
      destination = <<~MD
        # Before


        ## Section
        Old body



        # After
      MD

      analysis = FakeAnalysis.new(source: destination)
      statements = Ast::Merge::Navigable::Statement.build_list([
        FakeNode.new(text: "# Before", source_position: {start_line: 1, end_line: 1}),
        FakeNode.new(text: "## Section", source_position: {start_line: 4, end_line: 5}),
        FakeNode.new(text: "# After", source_position: {start_line: 9, end_line: 9}),
      ])
      injection_point = Struct.new(:anchor).new(statements[1])
      source_preserving_merger = merger_class.new(
        template: "## Section\nNew body\n",
        destination: destination,
        anchor: {type: :heading, text: /Section/},
        replace_mode: true,
      )

      result = source_preserving_merger.send(:perform_section_merge, analysis, statements, injection_point)

      expect(result.content).to eq("# Before\n\n\n## Section\nNew body\n\n\n\n# After\n")
    end
  end
end
