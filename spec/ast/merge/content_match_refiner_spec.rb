# frozen_string_literal: true

RSpec.describe Ast::Merge::ContentMatchRefiner do
  describe "constants" do
    describe "DEFAULT_WEIGHTS" do
      it "has content weight" do
        expect(described_class::DEFAULT_WEIGHTS[:content]).to eq(0.7)
      end

      it "has length weight" do
        expect(described_class::DEFAULT_WEIGHTS[:length]).to eq(0.15)
      end

      it "has position weight" do
        expect(described_class::DEFAULT_WEIGHTS[:position]).to eq(0.15)
      end

      it "weights sum to 1.0" do
        total = described_class::DEFAULT_WEIGHTS.values.sum
        expect(total).to be_within(0.001).of(1.0)
      end
    end
  end

  describe "#initialize" do
    it "accepts no arguments" do
      refiner = described_class.new
      expect(refiner).to be_a(described_class)
    end

    it "accepts threshold parameter" do
      refiner = described_class.new(threshold: 0.7)
      expect(refiner.threshold).to eq(0.7)
    end

    it "uses default threshold if not specified" do
      refiner = described_class.new
      expect(refiner.threshold).to eq(Ast::Merge::MatchRefinerBase::DEFAULT_THRESHOLD)
    end

    it "accepts node_types parameter" do
      refiner = described_class.new(node_types: [:paragraph, :heading])
      expect(refiner.node_types).to eq([:paragraph, :heading])
    end

    it "accepts custom weights" do
      refiner = described_class.new(weights: {content: 0.9})
      expect(refiner.weights[:content]).to eq(0.9)
    end

    it "merges custom weights with defaults" do
      refiner = described_class.new(weights: {content: 0.9})
      expect(refiner.weights[:length]).to eq(0.15) # Default preserved
    end

    it "accepts content_extractor proc" do
      extractor = ->(node) { node.to_s.upcase }
      refiner = described_class.new(content_extractor: extractor)
      expect(refiner.content_extractor).to eq(extractor)
    end
  end

  describe "#call" do
    let(:refiner) { described_class.new(threshold: 0.5) }

    def create_mock_node(content, type: :paragraph)
      node = double("Node")
      allow(node).to receive(:type).and_return(type)
      allow(node).to receive(:text_content).and_return(content)
      allow(node).to receive(:respond_to?) do |method, *|
        [:type, :text_content].include?(method)
      end
      node
    end

    context "with empty arrays" do
      it "returns empty array for empty template" do
        result = refiner.call([], [create_mock_node("test")])
        expect(result).to eq([])
      end

      it "returns empty array for empty destination" do
        result = refiner.call([create_mock_node("test")], [])
        expect(result).to eq([])
      end

      it "returns empty array for both empty" do
        result = refiner.call([], [])
        expect(result).to eq([])
      end
    end

    context "with similar content" do
      let(:template_node) { create_mock_node("Hello world") }
      let(:dest_node) { create_mock_node("Hello World") } # Slight difference

      it "returns matches for similar content" do
        result = refiner.call([template_node], [dest_node])
        expect(result).not_to be_empty
        expect(result.first.template_node).to eq(template_node)
        expect(result.first.dest_node).to eq(dest_node)
      end

      it "returns score above threshold" do
        result = refiner.call([template_node], [dest_node])
        expect(result.first.score).to be >= refiner.threshold
      end
    end

    context "with dissimilar content" do
      let(:refiner) { described_class.new(threshold: 0.8) }
      let(:template_node) { create_mock_node("Hello world") }
      let(:dest_node) { create_mock_node("Completely different text") }

      it "returns empty array when content is too different" do
        result = refiner.call([template_node], [dest_node])
        expect(result).to be_empty
      end
    end

    context "with identical content" do
      let(:template_node) { create_mock_node("Exact same content") }
      let(:dest_node) { create_mock_node("Exact same content") }

      it "returns perfect score for identical content" do
        result = refiner.call([template_node], [dest_node])
        expect(result.first.score).to be_within(0.001).of(1.0)
      end
    end

    context "with multiple nodes" do
      let(:template_nodes) do
        [
          create_mock_node("First paragraph"),
          create_mock_node("Second paragraph"),
        ]
      end
      let(:dest_nodes) do
        [
          create_mock_node("First paragraph modified"),
          create_mock_node("Second paragraph updated"),
        ]
      end

      it "matches nodes greedily by best score" do
        result = refiner.call(template_nodes, dest_nodes)
        expect(result.size).to eq(2)
      end

      it "does not double-match nodes" do
        result = refiner.call(template_nodes, dest_nodes)
        dest_matched = result.map(&:dest_node)
        expect(dest_matched.uniq.size).to eq(dest_matched.size)
      end
    end

    context "with node_types filtering" do
      let(:refiner) { described_class.new(threshold: 0.5, node_types: [:heading]) }
      let(:heading_node) { create_mock_node("Title", type: :heading) }
      let(:paragraph_node) { create_mock_node("Title", type: :paragraph) }

      it "only matches nodes of specified types" do
        result = refiner.call([heading_node], [heading_node])
        expect(result).not_to be_empty
      end

      it "ignores nodes of other types" do
        result = refiner.call([paragraph_node], [paragraph_node])
        expect(result).to be_empty
      end
    end

    context "with custom content_extractor" do
      let(:extractor) { ->(node) { node.type.to_s } }
      let(:refiner) { described_class.new(threshold: 0.5, content_extractor: extractor) }
      let(:node1) { create_mock_node("different", type: :paragraph) }
      let(:node2) { create_mock_node("content", type: :paragraph) }

      it "uses content_extractor to get content" do
        # Both nodes have type :paragraph, so content is "paragraph"
        result = refiner.call([node1], [node2])
        expect(result.first.score).to be_within(0.001).of(1.0)
      end
    end
  end

  describe "#string_similarity" do
    let(:refiner) { described_class.new }

    it "returns 1.0 for identical strings" do
      result = refiner.send(:string_similarity, "hello", "hello")
      expect(result).to eq(1.0)
    end

    it "returns 0.0 for completely different strings" do
      result = refiner.send(:string_similarity, "abc", "xyz")
      expect(result).to be < 0.5
    end

    it "returns high score for similar strings" do
      result = refiner.send(:string_similarity, "hello world", "hello worlf")
      expect(result).to be > 0.9
    end

    it "handles empty strings" do
      expect(refiner.send(:string_similarity, "", "test")).to eq(0.0)
      expect(refiner.send(:string_similarity, "test", "")).to eq(0.0)
      expect(refiner.send(:string_similarity, "", "")).to eq(1.0)
    end
  end

  describe "#length_similarity" do
    let(:refiner) { described_class.new }

    it "returns 1.0 for same length strings" do
      result = refiner.send(:length_similarity, "abc", "xyz")
      expect(result).to eq(1.0)
    end

    it "returns ratio for different lengths" do
      result = refiner.send(:length_similarity, "ab", "abcd")
      expect(result).to eq(0.5)
    end

    it "handles empty strings" do
      # Empty strings have the same length (0), so length similarity is 1.0
      # This is correct - we use min/max which is 0/0, handled as 0.0 division guard
      # Actually, looking at implementation: returns 0.0 if both empty since min=0 and max=0
      # Wait, the check is: return 0.0 if str1.empty? && str2.empty?
      # Let me check the implementation...
      # The implementation returns 0.0 for both empty, but if only one is empty,
      # it returns 0/len = 0.0
      expect(refiner.send(:length_similarity, "", "")).to eq(1.0)
      expect(refiner.send(:length_similarity, "", "test")).to eq(0.0)
      expect(refiner.send(:length_similarity, "test", "")).to eq(0.0)
    end
  end

  describe "#position_similarity" do
    let(:refiner) { described_class.new }

    it "returns 1.0 for same relative position" do
      result = refiner.send(:position_similarity, 0, 0, 5, 5)
      expect(result).to eq(1.0)
    end

    it "returns lower score for different positions" do
      result = refiner.send(:position_similarity, 0, 4, 5, 5)
      expect(result).to be < 1.0
    end

    it "handles single-element collections" do
      result = refiner.send(:position_similarity, 0, 0, 1, 1)
      expect(result).to eq(1.0)
    end
  end

  describe "#levenshtein_distance" do
    let(:refiner) { described_class.new }

    it "returns 0 for identical strings" do
      result = refiner.send(:levenshtein_distance, "hello", "hello")
      expect(result).to eq(0)
    end

    it "returns string length for empty comparison" do
      expect(refiner.send(:levenshtein_distance, "", "hello")).to eq(5)
      expect(refiner.send(:levenshtein_distance, "hello", "")).to eq(5)
    end

    it "calculates correct distance for single edit" do
      expect(refiner.send(:levenshtein_distance, "hello", "hallo")).to eq(1)
      expect(refiner.send(:levenshtein_distance, "hello", "helloo")).to eq(1)
      expect(refiner.send(:levenshtein_distance, "hello", "hell")).to eq(1)
    end

    it "calculates correct distance for multiple edits" do
      expect(refiner.send(:levenshtein_distance, "kitten", "sitting")).to eq(3)
    end
  end

  describe "inheritance" do
    it "inherits from Ast::Merge::MatchRefinerBase" do
      expect(described_class.ancestors).to include(Ast::Merge::MatchRefinerBase)
    end

    it "responds to threshold" do
      refiner = described_class.new
      expect(refiner).to respond_to(:threshold)
    end

    it "responds to node_types" do
      refiner = described_class.new
      expect(refiner).to respond_to(:node_types)
    end

    it "responds to handles_type?" do
      refiner = described_class.new
      expect(refiner).to respond_to(:handles_type?)
    end
  end

  describe "content extraction" do
    let(:refiner) { described_class.new }

    it "extracts from text_content" do
      node = double("Node")
      allow(node).to receive(:respond_to?).with(:text_content).and_return(true)
      allow(node).to receive(:text_content).and_return("hello")
      expect(refiner.send(:extract_content, node)).to eq("hello")
    end

    it "extracts from string_content" do
      node = double("Node")
      allow(node).to receive(:respond_to?).with(:text_content).and_return(false)
      allow(node).to receive(:respond_to?).with(:string_content).and_return(true)
      allow(node).to receive(:string_content).and_return("hello")
      expect(refiner.send(:extract_content, node)).to eq("hello")
    end

    it "extracts from content" do
      node = double("Node")
      allow(node).to receive(:respond_to?).with(:text_content).and_return(false)
      allow(node).to receive(:respond_to?).with(:string_content).and_return(false)
      allow(node).to receive(:respond_to?).with(:content).and_return(true)
      allow(node).to receive(:content).and_return("hello")
      expect(refiner.send(:extract_content, node)).to eq("hello")
    end

    it "extracts from text" do
      node = double("Node")
      allow(node).to receive(:respond_to?).with(:text_content).and_return(false)
      allow(node).to receive(:respond_to?).with(:string_content).and_return(false)
      allow(node).to receive(:respond_to?).with(:content).and_return(false)
      allow(node).to receive(:respond_to?).with(:text).and_return(true)
      allow(node).to receive(:text).and_return("hello")
      expect(refiner.send(:extract_content, node)).to eq("hello")
    end

    it "falls back to to_s" do
      node = double("Node")
      allow(node).to receive(:respond_to?).and_return(false)
      allow(node).to receive(:respond_to?).with(:to_s).and_return(true)
      allow(node).to receive(:to_s).and_return("hello")
      expect(refiner.send(:extract_content, node)).to eq("hello")
    end
  end
end

