# frozen_string_literal: true

require "ast/merge/text"

RSpec.describe Ast::Merge::Text::TextAnalysis do
  describe "#initialize" do
    it "parses source into line statements" do
      source = "Hello world\nGoodbye world"
      analysis = described_class.new(source)

      expect(analysis.statements.size).to eq(2)
      expect(analysis.statements[0]).to be_a(Ast::Merge::Text::LineNode)
      expect(analysis.statements[1]).to be_a(Ast::Merge::Text::LineNode)
    end

    it "handles empty source" do
      analysis = described_class.new("")

      expect(analysis.statements).to be_empty
    end

    it "handles single line without newline" do
      analysis = described_class.new("Hello world")

      expect(analysis.statements.size).to eq(1)
      expect(analysis.statements[0].content).to eq("Hello world")
    end

    it "handles trailing newline correctly" do
      analysis = described_class.new("Hello world\n")

      expect(analysis.statements.size).to eq(1)
      expect(analysis.statements[0].content).to eq("Hello world")
    end

    it "preserves empty lines in the middle" do
      source = "Line one\n\nLine three"
      analysis = described_class.new(source)

      expect(analysis.statements.size).to eq(3)
      expect(analysis.statements[0].content).to eq("Line one")
      expect(analysis.statements[1].content).to eq("")
      expect(analysis.statements[2].content).to eq("Line three")
    end
  end

  describe "freeze blocks" do
    it "parses freeze blocks with default token" do
      source = <<~TEXT
        Line one
        # text-merge:freeze
        Frozen content
        # text-merge:unfreeze
        Line four
      TEXT
      analysis = described_class.new(source)

      expect(analysis.statements.size).to eq(3)
      expect(analysis.statements[0]).to be_a(Ast::Merge::Text::LineNode)
      expect(analysis.statements[0].content).to eq("Line one")
      expect(analysis.statements[1]).to be_a(Ast::Merge::FreezeNodeBase)
      expect(analysis.statements[2]).to be_a(Ast::Merge::Text::LineNode)
      expect(analysis.statements[2].content).to eq("Line four")
    end

    it "parses freeze blocks with custom token" do
      source = <<~TEXT
        Line one
        # custom:freeze
        Frozen content
        # custom:unfreeze
        Line four
      TEXT
      analysis = described_class.new(source, freeze_token: "custom")

      expect(analysis.statements.size).to eq(3)
      expect(analysis.statements[1]).to be_a(Ast::Merge::FreezeNodeBase)
    end

    it "raises error for unclosed freeze block" do
      source = <<~TEXT
        Line one
        # text-merge:freeze
        Frozen content
      TEXT

      expect { described_class.new(source) }.to raise_error(
        Ast::Merge::FreezeNodeBase::InvalidStructureError,
        /Unclosed freeze block/
      )
    end

    it "extracts freeze reason when provided" do
      source = <<~TEXT
        # text-merge:freeze Custom reason here
        Frozen content
        # text-merge:unfreeze
      TEXT
      analysis = described_class.new(source)

      expect(analysis.statements.size).to eq(1)
      expect(analysis.statements[0]).to be_a(Ast::Merge::FreezeNodeBase)
      expect(analysis.statements[0].reason).to eq("Custom reason here")
    end
  end

  describe "#compute_node_signature" do
    it "returns signature for LineNode" do
      source = "Hello world"
      analysis = described_class.new(source)
      line_node = analysis.statements[0]

      expect(analysis.compute_node_signature(line_node)).to eq([:line, "Hello world"])
    end

    it "returns signature for FreezeNodeBase" do
      source = <<~TEXT
        # text-merge:freeze
        Frozen
        # text-merge:unfreeze
      TEXT
      analysis = described_class.new(source)
      freeze_node = analysis.statements[0]

      expect(analysis.compute_node_signature(freeze_node)).to eq([:freeze_block, 1, 3])
    end

    it "returns nil for unknown node types" do
      analysis = described_class.new("Hello")

      expect(analysis.compute_node_signature("not a node")).to be_nil
    end
  end

  describe "#fallthrough_node?" do
    it "returns true for LineNode" do
      source = "Hello world"
      analysis = described_class.new(source)
      line_node = analysis.statements[0]

      expect(analysis.fallthrough_node?(line_node)).to be true
    end

    it "returns true for FreezeNodeBase" do
      source = <<~TEXT
        # text-merge:freeze
        Frozen
        # text-merge:unfreeze
      TEXT
      analysis = described_class.new(source)
      freeze_node = analysis.statements[0]

      expect(analysis.fallthrough_node?(freeze_node)).to be true
    end

    it "returns false for other types" do
      analysis = described_class.new("Hello")

      expect(analysis.fallthrough_node?("not a node")).to be false
    end
  end
end
