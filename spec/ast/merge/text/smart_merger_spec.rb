# frozen_string_literal: true

RSpec.describe Ast::Merge::Text::SmartMerger do
  describe "#initialize" do
    let(:template) { "line one\nline two" }
    let(:dest) { "line one\nline three" }

    it "creates a merger with default options" do
      merger = described_class.new(template, dest)
      expect(merger).to be_a(described_class)
    end

    it "inherits from SmartMergerBase" do
      expect(described_class.superclass).to eq(Ast::Merge::SmartMergerBase)
    end

    it "has the default freeze token" do
      merger = described_class.new(template, dest)
      expect(merger.freeze_token).to eq(Ast::Merge::Text::SmartMerger::DEFAULT_FREEZE_TOKEN)
    end
  end

  describe "#merge" do
    let(:template) { "line one\nline two" }
    let(:dest) { "line one\nline three" }

    it "returns merged content as a string" do
      merger = described_class.new(template, dest)
      result = merger.merge
      expect(result).to be_a(String)
    end

    it "preserves destination lines by default" do
      merger = described_class.new(template, dest)
      result = merger.merge
      expect(result).to include("line three")
    end
  end

  describe "#merge_result" do
    let(:template) { "line one\nline two" }
    let(:dest) { "line one\nline three" }

    it "returns a MergeResult object" do
      merger = described_class.new(template, dest)
      result = merger.merge_result
      expect(result).to be_a(Ast::Merge::Text::MergeResult)
    end
  end

  describe "protected methods" do
    let(:template) { "line one" }
    let(:dest) { "line two" }

    describe "#analysis_class" do
      it "returns FileAnalysis" do
        merger = described_class.new(template, dest)
        expect(merger.send(:analysis_class)).to eq(Ast::Merge::Text::FileAnalysis)
      end
    end

    describe "#default_freeze_token" do
      it "returns the DEFAULT_FREEZE_TOKEN constant" do
        merger = described_class.new(template, dest)
        expect(merger.send(:default_freeze_token)).to eq(Ast::Merge::Text::SmartMerger::DEFAULT_FREEZE_TOKEN)
      end
    end

    describe "#resolver_class" do
      it "returns ConflictResolver" do
        merger = described_class.new(template, dest)
        expect(merger.send(:resolver_class)).to eq(Ast::Merge::Text::ConflictResolver)
      end
    end

    describe "#result_class" do
      it "returns MergeResult" do
        merger = described_class.new(template, dest)
        expect(merger.send(:result_class)).to eq(Ast::Merge::Text::MergeResult)
      end
    end
  end

  describe "with regions" do
    let(:yaml_detector) { Ast::Merge::Detector::YamlFrontmatter.new }

    let(:template) do
      <<~MD
        ---
        title: Template
        ---
        Body line one
        Body line two
      MD
    end

    let(:dest) do
      <<~MD
        ---
        title: Destination
        author: Jane
        ---
        Body line one
        Modified body
      MD
    end

    it "accepts regions configuration" do
      merger = described_class.new(
        template,
        dest,
        regions: [{detector: yaml_detector}],
      )

      expect(merger.regions_configured?).to be true
    end

    # Note: Full region merging with Text::SmartMerger requires the result's
    # content method to return a String, but MergeResultBase.content returns
    # an Array. Region merging works correctly with other mergers that return
    # String content.
  end
end
