# frozen_string_literal: true

# Mocked tests for PartialTemplateMerger logic without requiring a parser
RSpec.describe Ast::Merge::PartialTemplateMerger do
  describe "Result class (mocked)" do
    it "initializes with all attributes" do
      result = described_class::Result.new(
        content: "test content",
        has_section: true,
        changed: true,
        stats: {mode: :merge},
        injection_point: nil,
        message: "Test message",
      )

      expect(result.content).to eq("test content")
      expect(result.has_section).to be true
      expect(result.changed).to be true
      expect(result.stats).to eq({mode: :merge})
      expect(result.injection_point).to be_nil
      expect(result.message).to eq("Test message")
    end

    describe "#section_found?" do
      it "returns true when has_section is true" do
        result = described_class::Result.new(content: "", has_section: true, changed: false)
        expect(result.section_found?).to be true
      end

      it "returns false when has_section is false" do
        result = described_class::Result.new(content: "", has_section: false, changed: false)
        expect(result.section_found?).to be false
      end
    end
  end

  describe "#initialize" do
    let(:template) { "template content" }
    let(:destination) { "destination content" }

    it "sets all attributes" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading, text: /Test/},
        boundary: {type: :heading},
        parser: :markly,
        preference: :destination,
        add_missing: false,
        when_missing: :append,
        replace_mode: true,
        signature_generator: ->(n) { n },
        node_typing: {heading: ->(n) { n }},
      )

      expect(merger.template).to eq(template)
      expect(merger.destination).to eq(destination)
      expect(merger.anchor[:type]).to eq(:heading)
      expect(merger.boundary[:type]).to eq(:heading)
      expect(merger.parser).to eq(:markly)
      expect(merger.preference).to eq(:destination)
      expect(merger.add_missing).to be false
      expect(merger.when_missing).to eq(:append)
      expect(merger.signature_generator).to be_a(Proc)
      expect(merger.node_typing).to have_key(:heading)
    end

    it "normalizes anchor type to symbol" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: "heading"},
        parser: :markly,
      )
      expect(merger.anchor[:type]).to eq(:heading)
    end

    it "handles nil boundary" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading},
        boundary: nil,
        parser: :markly,
      )
      expect(merger.boundary).to be_nil
    end
  end

  describe "#normalize_matcher (via initialization)" do
    let(:template) { "template" }
    let(:destination) { "destination" }

    it "handles nil matcher" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: nil,
        parser: :markly,
      )
      expect(merger.anchor).to eq({})
    end

    it "preserves Regexp text pattern" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading, text: /Test Pattern/},
        parser: :markly,
      )
      expect(merger.anchor[:text]).to eq(/Test Pattern/)
    end

    it "converts /regex/ string to Regexp" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading, text: "/Test Pattern/"},
        parser: :markly,
      )
      expect(merger.anchor[:text]).to be_a(Regexp)
      expect(merger.anchor[:text]).to eq(/Test Pattern/)
    end

    it "keeps plain string as string" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading, text: "Plain Text"},
        parser: :markly,
      )
      expect(merger.anchor[:text]).to eq("Plain Text")
    end

    it "handles nil text" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading, text: nil},
        parser: :markly,
      )
      expect(merger.anchor[:text]).to be_nil
    end

    it "preserves level option" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading, level: 2},
        parser: :markly,
      )
      expect(merger.anchor[:level]).to eq(2)
    end

    it "preserves level_lte option" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading, level_lte: 3},
        parser: :markly,
      )
      expect(merger.anchor[:level_lte]).to eq(3)
    end

    it "preserves level_gte option" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading, level_gte: 1},
        parser: :markly,
      )
      expect(merger.anchor[:level_gte]).to eq(1)
    end

    it "compacts nil values from result" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading, text: nil, level: nil},
        parser: :markly,
      )
      expect(merger.anchor.keys).not_to include(:text)
      expect(merger.anchor.keys).not_to include(:level)
    end
  end

  describe "#replace_mode?" do
    let(:template) { "template" }
    let(:destination) { "destination" }

    it "returns true when replace_mode is true" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading},
        parser: :markly,
        replace_mode: true,
      )
      expect(merger.send(:replace_mode?)).to be true
    end

    it "returns false when replace_mode is false" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading},
        parser: :markly,
        replace_mode: false,
      )
      expect(merger.send(:replace_mode?)).to be false
    end

    it "returns false by default" do
      merger = described_class.new(
        template: template,
        destination: destination,
        anchor: {type: :heading},
        parser: :markly,
      )
      expect(merger.send(:replace_mode?)).to be false
    end
  end

  describe "#heading_type?" do
    let(:merger) do
      described_class.new(
        template: "t",
        destination: "d",
        anchor: {type: :heading},
        parser: :markly,
      )
    end

    it "returns true for :heading symbol" do
      expect(merger.send(:heading_type?, :heading)).to be true
    end

    it 'returns true for "heading" string' do
      expect(merger.send(:heading_type?, "heading")).to be true
    end

    it "returns true for :header symbol" do
      expect(merger.send(:heading_type?, :header)).to be true
    end

    it "returns false for other types" do
      expect(merger.send(:heading_type?, :paragraph)).to be false
      expect(merger.send(:heading_type?, :list)).to be false
      expect(merger.send(:heading_type?, "other")).to be false
    end
  end

  describe "#get_heading_level" do
    let(:merger) do
      described_class.new(
        template: "t",
        destination: "d",
        anchor: {type: :heading},
        parser: :markly,
      )
    end

    it "returns level from header_level method" do
      node = double("HeadingNode", header_level: 2)
      stmt = double("Statement", node: node)
      allow(stmt).to receive(:respond_to?).with(:unwrapped_node).and_return(false)

      expect(merger.send(:get_heading_level, stmt)).to eq(2)
    end

    it "returns level from level method if no header_level" do
      node = double("HeadingNode")
      allow(node).to receive(:respond_to?).with(:header_level).and_return(false)
      allow(node).to receive(:respond_to?).with(:level).and_return(true)
      allow(node).to receive(:level).and_return(3)

      stmt = double("Statement", node: node)
      allow(stmt).to receive(:respond_to?).with(:unwrapped_node).and_return(false)

      expect(merger.send(:get_heading_level, stmt)).to eq(3)
    end

    it "unwraps node if unwrapped_node method available" do
      inner_node = double("InnerNode", header_level: 1)
      allow(inner_node).to receive(:respond_to?).with(:header_level).and_return(true)

      stmt = double("WrappedStatement")
      allow(stmt).to receive(:respond_to?).with(:unwrapped_node).and_return(true)
      allow(stmt).to receive(:unwrapped_node).and_return(inner_node)

      expect(merger.send(:get_heading_level, stmt)).to eq(1)
    end

    it "returns nil if no level method available" do
      node = double("PlainNode")
      allow(node).to receive(:respond_to?).with(:header_level).and_return(false)
      allow(node).to receive(:respond_to?).with(:level).and_return(false)

      stmt = double("Statement", node: node)
      allow(stmt).to receive(:respond_to?).with(:unwrapped_node).and_return(false)

      expect(merger.send(:get_heading_level, stmt)).to be_nil
    end
  end

  describe "#statements_to_content" do
    let(:merger) do
      described_class.new(
        template: "t",
        destination: "d",
        anchor: {type: :heading},
        parser: :markly,
      )
    end

    it "returns empty string for nil statements" do
      expect(merger.send(:statements_to_content, nil)).to eq("")
    end

    it "returns empty string for empty array" do
      expect(merger.send(:statements_to_content, [])).to eq("")
    end

    it "extracts node from statement and converts to text" do
      node = double("Node")
      allow(node).to receive(:respond_to?).with(:inner_node).and_return(false)
      allow(node).to receive(:respond_to?).with(:to_commonmark).and_return(true)
      allow(node).to receive(:to_commonmark).and_return("Content\n")

      stmt = double("Statement", node: node)
      allow(stmt).to receive(:respond_to?).with(:node).and_return(true)

      result = merger.send(:statements_to_content, [stmt])
      expect(result).to eq("Content\n")
    end
  end

  describe "#node_to_text" do
    let(:merger) do
      described_class.new(
        template: "t",
        destination: "d",
        anchor: {type: :heading},
        parser: :markly,
      )
    end

    it "uses to_commonmark if available" do
      node = double("Node")
      allow(node).to receive(:respond_to?).with(:inner_node).and_return(false)
      allow(node).to receive(:respond_to?).with(:to_commonmark).and_return(true)
      allow(node).to receive(:to_commonmark).and_return("Markdown output")

      expect(merger.send(:node_to_text, node)).to eq("Markdown output")
    end

    it "falls back to to_s if no to_commonmark" do
      node = double("Node")
      allow(node).to receive(:respond_to?).with(:inner_node).and_return(false)
      allow(node).to receive(:respond_to?).with(:to_commonmark).and_return(false)
      allow(node).to receive(:respond_to?).with(:to_s).and_return(true)
      allow(node).to receive(:to_s).and_return("String output")

      expect(merger.send(:node_to_text, node)).to eq("String output")
    end

    it "unwraps nested inner_node" do
      inner = double("InnerNode")
      allow(inner).to receive(:respond_to?).with(:inner_node).and_return(false)
      allow(inner).to receive(:respond_to?).with(:to_commonmark).and_return(true)
      allow(inner).to receive(:to_commonmark).and_return("Inner content")

      outer = double("OuterNode")
      allow(outer).to receive(:respond_to?).with(:inner_node).and_return(true)
      allow(outer).to receive(:inner_node).and_return(inner)

      expect(merger.send(:node_to_text, outer)).to eq("Inner content")
    end

    it "returns empty string if nothing available" do
      node = double("EmptyNode")
      allow(node).to receive(:respond_to?).with(:inner_node).and_return(false)
      allow(node).to receive(:respond_to?).with(:to_commonmark).and_return(false)
      allow(node).to receive(:respond_to?).with(:to_s).and_return(false)

      expect(merger.send(:node_to_text, node)).to eq("")
    end
  end

  describe "#build_merged_content" do
    let(:merger) do
      described_class.new(
        template: "t",
        destination: "d",
        anchor: {type: :heading},
        parser: :markly,
      )
    end

    it "joins non-empty parts with double newline" do
      result = merger.send(:build_merged_content, "Before", "Section", "After")
      expect(result).to eq("Before\n\nSection\n\nAfter\n")
    end

    it "skips nil parts" do
      result = merger.send(:build_merged_content, nil, "Section", "After")
      expect(result).to eq("Section\n\nAfter\n")
    end

    it "skips empty string parts" do
      result = merger.send(:build_merged_content, "", "Section", "")
      expect(result).to eq("Section\n")
    end

    it "skips whitespace-only parts" do
      result = merger.send(:build_merged_content, "   ", "Section", "\n\t")
      expect(result).to eq("Section\n")
    end

    it "ensures trailing newline" do
      result = merger.send(:build_merged_content, "Content", nil, nil)
      expect(result).to end_with("\n")
    end

    it "chomps trailing newlines from parts before joining" do
      result = merger.send(:build_merged_content, "Before\n", "Section\n", "After\n")
      expect(result).to eq("Before\n\nSection\n\nAfter\n")
    end
  end

  describe "#handle_missing_section" do
    let(:template) { "Template Content" }
    let(:destination) { "Destination Content" }

    context "with when_missing: :skip" do
      let(:merger) do
        described_class.new(
          template: template,
          destination: destination,
          anchor: {type: :heading},
          parser: :markly,
          when_missing: :skip,
        )
      end

      it "returns unchanged destination" do
        result = merger.send(:handle_missing_section, nil)
        expect(result.content).to eq(destination)
        expect(result.has_section).to be false
        expect(result.changed).to be false
        expect(result.message).to include("skipping")
      end
    end

    context "with when_missing: :append" do
      let(:merger) do
        described_class.new(
          template: template,
          destination: destination,
          anchor: {type: :heading},
          parser: :markly,
          when_missing: :append,
        )
      end

      it "appends template at end" do
        result = merger.send(:handle_missing_section, nil)
        expect(result.content).to start_with("Destination Content")
        expect(result.content).to end_with("Template Content")
        expect(result.has_section).to be false
        expect(result.changed).to be true
        expect(result.message).to include("appended")
      end
    end

    context "with when_missing: :prepend" do
      let(:merger) do
        described_class.new(
          template: template,
          destination: destination,
          anchor: {type: :heading},
          parser: :markly,
          when_missing: :prepend,
        )
      end

      it "prepends template at start" do
        result = merger.send(:handle_missing_section, nil)
        expect(result.content).to start_with("Template Content")
        expect(result.content).to end_with("Destination Content")
        expect(result.has_section).to be false
        expect(result.changed).to be true
        expect(result.message).to include("prepended")
      end
    end

    context "with unknown when_missing value" do
      let(:merger) do
        described_class.new(
          template: template,
          destination: destination,
          anchor: {type: :heading},
          parser: :markly,
          when_missing: :unknown_value,
        )
      end

      it "returns unchanged destination with no action message" do
        result = merger.send(:handle_missing_section, nil)
        expect(result.content).to eq(destination)
        expect(result.has_section).to be false
        expect(result.changed).to be false
        expect(result.message).to include("no action taken")
      end
    end
  end

  describe "#create_analysis" do
    let(:merger) do
      described_class.new(
        template: "t",
        destination: "d",
        anchor: {type: :heading},
        parser: :unknown_parser,
      )
    end

    it "raises ArgumentError for unknown parser" do
      expect { merger.send(:create_analysis, "content") }.to raise_error(ArgumentError, /Unknown parser/)
    end
  end

  describe "#create_smart_merger" do
    let(:merger) do
      described_class.new(
        template: "t",
        destination: "d",
        anchor: {type: :heading},
        parser: :unknown_parser,
      )
    end

    it "raises ArgumentError for unknown parser" do
      expect { merger.send(:create_smart_merger, "template", "dest") }.to raise_error(ArgumentError, /Unknown parser/)
    end
  end

  describe "#find_section_end" do
    let(:merger) do
      described_class.new(
        template: "t",
        destination: "d",
        anchor: {type: :heading},
        parser: :markly,
      )
    end

    it "returns boundary index - 1 when boundary exists" do
      boundary_stmt = double("BoundaryStatement", index: 5)
      anchor_stmt = double("AnchorStatement", index: 2, type: :heading)
      injection_point = double("InjectionPoint", anchor: anchor_stmt, boundary: boundary_stmt)

      result = merger.send(:find_section_end, [], injection_point)
      expect(result).to eq(4)
    end

    it "returns last index when no boundary and section extends to end" do
      anchor_stmt = double("AnchorStatement", index: 2, type: :paragraph)
      injection_point = double("InjectionPoint", anchor: anchor_stmt, boundary: nil)

      stmt3 = double("Statement3", type: :list)
      stmt4 = double("Statement4", type: :code)
      statements = [nil, nil, nil, stmt3, stmt4]

      result = merger.send(:find_section_end, statements, injection_point)
      expect(result).to eq(4)
    end

    it "finds next same-type node for non-heading types" do
      anchor_stmt = double("AnchorStatement", index: 1, type: :paragraph)
      injection_point = double("InjectionPoint", anchor: anchor_stmt, boundary: nil)

      stmt0 = double("Statement0", type: :heading)
      stmt1 = double("Statement1", type: :paragraph)
      stmt2 = double("Statement2", type: :list)
      stmt3 = double("Statement3", type: :paragraph)
      statements = [stmt0, stmt1, stmt2, stmt3]

      result = merger.send(:find_section_end, statements, injection_point)
      expect(result).to eq(2) # idx - 1 before the next paragraph at idx 3
    end

    it "finds next heading of same or higher level for heading types" do
      anchor_node = double("AnchorNode", header_level: 3)
      anchor_stmt = double("AnchorStatement", index: 1, type: :heading, node: anchor_node)
      allow(anchor_stmt).to receive(:respond_to?).with(:unwrapped_node).and_return(false)

      injection_point = double("InjectionPoint", anchor: anchor_stmt, boundary: nil)

      stmt0_node = double("Stmt0Node", header_level: 1)
      stmt0 = double("Statement0", type: :heading, node: stmt0_node)
      allow(stmt0).to receive(:respond_to?).with(:unwrapped_node).and_return(false)

      stmt1_node = double("Stmt1Node", header_level: 3)
      stmt1 = double("Statement1", type: :heading, node: stmt1_node)
      allow(stmt1).to receive(:respond_to?).with(:unwrapped_node).and_return(false)

      stmt2_node = double("Stmt2Node")
      stmt2 = double("Statement2", type: :paragraph, node: stmt2_node)
      allow(stmt2).to receive(:respond_to?).with(:unwrapped_node).and_return(false)

      stmt3_node = double("Stmt3Node", header_level: 2)
      stmt3 = double("Statement3", type: :heading, node: stmt3_node)
      allow(stmt3).to receive(:respond_to?).with(:unwrapped_node).and_return(false)

      statements = [stmt0, stmt1, stmt2, stmt3]

      result = merger.send(:find_section_end, statements, injection_point)
      # H2 at index 3 is same or higher level than H3, so section ends at index 2
      expect(result).to eq(2)
    end
  end

  describe "#merge_section_content" do
    let(:template) { "Template" }
    let(:destination) { "Destination" }

    context "with replace_mode enabled" do
      let(:merger) do
        described_class.new(
          template: template,
          destination: destination,
          anchor: {type: :heading},
          parser: :markly,
          replace_mode: true,
        )
      end

      it "returns template content directly with replace stats" do
        content, stats = merger.send(:merge_section_content, "old section content")
        expect(content).to eq(template)
        expect(stats[:mode]).to eq(:replace)
      end
    end
  end
end
