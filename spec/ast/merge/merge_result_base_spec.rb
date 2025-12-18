# frozen_string_literal: true

RSpec.describe Ast::Merge::MergeResultBase do
  describe "decision constants" do
    it "defines DECISION_KEPT_TEMPLATE" do
      expect(described_class::DECISION_KEPT_TEMPLATE).to eq(:kept_template)
    end

    it "defines DECISION_KEPT_DEST" do
      expect(described_class::DECISION_KEPT_DEST).to eq(:kept_destination)
    end

    it "defines DECISION_MERGED" do
      expect(described_class::DECISION_MERGED).to eq(:merged)
    end

    it "defines DECISION_ADDED" do
      expect(described_class::DECISION_ADDED).to eq(:added)
    end

    it "defines DECISION_FREEZE_BLOCK" do
      expect(described_class::DECISION_FREEZE_BLOCK).to eq(:freeze_block)
    end

    it "defines DECISION_REPLACED" do
      expect(described_class::DECISION_REPLACED).to eq(:replaced)
    end

    it "defines DECISION_APPENDED" do
      expect(described_class::DECISION_APPENDED).to eq(:appended)
    end
  end

  describe "#initialize" do
    context "with no arguments" do
      subject(:result) { described_class.new }

      it "starts with empty lines" do
        expect(result.lines).to eq([])
      end

      it "starts with empty decisions" do
        expect(result.decisions).to eq([])
      end

      it "has nil template_analysis" do
        expect(result.template_analysis).to be_nil
      end

      it "has nil dest_analysis" do
        expect(result.dest_analysis).to be_nil
      end

      it "has empty conflicts" do
        expect(result.conflicts).to eq([])
      end

      it "has empty frozen_blocks" do
        expect(result.frozen_blocks).to eq([])
      end

      it "has empty stats" do
        expect(result.stats).to eq({})
      end
    end

    context "with template_analysis and dest_analysis" do
      subject(:result) do
        described_class.new(
          template_analysis: template_analysis,
          dest_analysis: dest_analysis,
        )
      end

      let(:template_analysis) { double("template") }
      let(:dest_analysis) { double("dest") }

      it "stores template_analysis" do
        expect(result.template_analysis).to eq(template_analysis)
      end

      it "stores dest_analysis" do
        expect(result.dest_analysis).to eq(dest_analysis)
      end
    end

    context "with conflicts" do
      subject(:result) { described_class.new(conflicts: conflicts) }

      let(:conflicts) { [{location: 1, message: "test"}] }

      it "stores conflicts" do
        expect(result.conflicts).to eq(conflicts)
      end
    end

    context "with frozen_blocks" do
      subject(:result) { described_class.new(frozen_blocks: frozen_blocks) }

      let(:frozen_blocks) { [{start: 1, end: 5}] }

      it "stores frozen_blocks" do
        expect(result.frozen_blocks).to eq(frozen_blocks)
      end
    end

    context "with stats" do
      subject(:result) { described_class.new(stats: stats) }

      let(:stats) { {nodes_added: 5, nodes_removed: 2} }

      it "stores stats" do
        expect(result.stats).to eq(stats)
      end
    end
  end

  describe "#content" do
    subject(:result) { described_class.new }

    it "returns @lines array" do
      expect(result.content).to eq([])
      expect(result.content).to be(result.lines)
    end

    it "reflects changes to @lines" do
      result.lines << "line1"
      result.lines << "line2"
      expect(result.content).to eq(%w[line1 line2])
    end
  end

  describe "#to_s" do
    subject(:result) { described_class.new }

    context "when lines is empty" do
      it "returns empty string" do
        expect(result.to_s).to eq("")
      end
    end

    context "when lines has content" do
      before do
        result.lines << "line1"
        result.lines << "line2"
      end

      it "joins lines with newlines" do
        expect(result.to_s).to eq("line1\nline2")
      end
    end
  end

  describe "#content?" do
    subject(:result) { described_class.new }

    context "when lines is empty" do
      it "returns false" do
        expect(result.content?).to be(false)
      end
    end

    context "when lines has content" do
      before { result.lines << "line1" }

      it "returns true" do
        expect(result.content?).to be(true)
      end
    end
  end

  describe "#empty?" do
    it "returns true when no lines" do
      result = described_class.new
      expect(result.empty?).to be(true)
    end

    it "returns false when lines exist" do
      result = described_class.new
      result.instance_variable_get(:@lines) << "content"
      expect(result.empty?).to be(false)
    end
  end

  describe "#line_count" do
    it "returns 0 for empty result" do
      result = described_class.new
      expect(result.line_count).to eq(0)
    end

    it "returns correct count" do
      result = described_class.new
      lines = result.instance_variable_get(:@lines)
      lines << "line1"
      lines << "line2"
      expect(result.line_count).to eq(2)
    end
  end

  describe "#decision_summary" do
    it "returns empty hash for no decisions" do
      result = described_class.new
      expect(result.decision_summary).to eq({})
    end

    it "summarizes decisions by type" do
      result = described_class.new
      decisions = result.instance_variable_get(:@decisions)
      decisions << {decision: :kept_template}
      decisions << {decision: :kept_template}
      decisions << {decision: :kept_destination}

      summary = result.decision_summary
      expect(summary[:kept_template]).to eq(2)
      expect(summary[:kept_destination]).to eq(1)
    end
  end

  describe "#inspect" do
    it "returns a readable string" do
      result = described_class.new
      expect(result.inspect).to include("MergeResult")
      expect(result.inspect).to include("lines=0")
      expect(result.inspect).to include("decisions=0")
    end
  end

  describe "#track_decision (protected)" do
    # We test via a subclass that exposes the method
    let(:test_class) do
      Class.new(described_class) do
        def add_tracked_decision(decision, source, line: nil)
          track_decision(decision, source, line: line)
        end
      end
    end

    it "records decision type" do
      result = test_class.new
      result.add_tracked_decision(:kept_template, :template)

      expect(result.decisions.first[:decision]).to eq(:kept_template)
    end

    it "records source" do
      result = test_class.new
      result.add_tracked_decision(:kept_template, :template)

      expect(result.decisions.first[:source]).to eq(:template)
    end

    it "records line number when provided" do
      result = test_class.new
      result.add_tracked_decision(:kept_template, :template, line: 5)

      expect(result.decisions.first[:line]).to eq(5)
    end

    it "records timestamp" do
      result = test_class.new
      result.add_tracked_decision(:kept_template, :template)

      expect(result.decisions.first[:timestamp]).to be_a(Time)
    end

    it "records nil line when not provided" do
      result = test_class.new
      result.add_tracked_decision(:kept_template, :template)

      expect(result.decisions.first[:line]).to be_nil
    end
  end

  describe "subclass inheritance" do
    let(:subclass) do
      Class.new(described_class) do
        def add_line(content, decision:, source:)
          @lines << content
          track_decision(decision, source)
        end
      end
    end

    it "inherits decision constants" do
      expect(subclass::DECISION_KEPT_TEMPLATE).to eq(:kept_template)
      expect(subclass::DECISION_FREEZE_BLOCK).to eq(:freeze_block)
    end

    it "can use track_decision" do
      result = subclass.new
      result.add_line("test", decision: :kept_template, source: :template)

      expect(result.line_count).to eq(1)
      expect(result.decisions.length).to eq(1)
    end
  end
end
