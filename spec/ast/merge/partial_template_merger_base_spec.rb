# frozen_string_literal: true

RSpec.describe Ast::Merge::PartialTemplateMergerBase do
  let(:merger_class) do
    Class.new(described_class) do
      def create_analysis(content)
        content
      end

      def create_smart_merger(template_content, destination_content)
        [template_content, destination_content]
      end

      def find_section_end(statements, injection_point)
        [statements, injection_point]
      end

      def node_to_text(node, analysis = nil)
        [node, analysis].compact.join("|")
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
end
