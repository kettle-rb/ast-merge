# frozen_string_literal: true

RSpec.describe Ast::Merge::NodeWrapperBase do
  # Mock node for testing - use double since TreeHaver::Node may not be loaded
  let(:mock_node) do
    double(
      "mock_tree_haver_node",
      type: :test_type,
      start_point: double(row: 0),
      end_point: double(row: 2),
      start_byte: 0,
      end_byte: 10,
    )
  end

  let(:source_lines) { ["line 1", "line 2", "line 3"] }
  let(:source_string) { source_lines.join("\n") }

  # Concrete subclass for testing
  let(:test_wrapper_class) do
    Class.new(described_class) do
      def compute_signature(node)
        [:test, node.type]
      end
    end
  end

  let(:wrapper) do
    test_wrapper_class.new(mock_node, lines: source_lines, source: source_string)
  end

  describe "#initialize" do
    it "stores the node" do
      expect(wrapper.node).to eq(mock_node)
    end

    it "stores the lines" do
      expect(wrapper.lines).to eq(source_lines)
    end

    it "stores the source" do
      expect(wrapper.source).to eq(source_string)
    end

    it "extracts start_line (1-based)" do
      expect(wrapper.start_line).to eq(1)
    end

    it "extracts end_line (1-based)" do
      expect(wrapper.end_line).to eq(3)
    end

    it "defaults leading_comments to empty array" do
      expect(wrapper.leading_comments).to eq([])
    end

    it "defaults inline_comment to nil" do
      expect(wrapper.inline_comment).to be_nil
    end

    context "with comments" do
      let(:leading) { [{text: "# comment"}] }
      let(:inline) { {text: "# inline"} }

      let(:wrapper_with_comments) do
        test_wrapper_class.new(
          mock_node,
          lines: source_lines,
          leading_comments: leading,
          inline_comment: inline,
        )
      end

      it "stores leading_comments" do
        expect(wrapper_with_comments.leading_comments).to eq(leading)
      end

      it "stores inline_comment" do
        expect(wrapper_with_comments.inline_comment).to eq(inline)
      end
    end

    context "when end_line is before start_line" do
      let(:bad_node) do
        double(
          "mock_bad_node",
          type: :test,
          start_point: double(row: 5),
          end_point: double(row: 2),
        )
      end

      it "corrects end_line to equal start_line" do
        wrapper = test_wrapper_class.new(bad_node, lines: source_lines)
        expect(wrapper.end_line).to eq(wrapper.start_line)
      end
    end

    context "when node uses hash-style points" do
      let(:hash_point_node) do
        double(
          "mock_hash_point_node",
          type: :test,
          start_point: {row: 1},
          end_point: {row: 3},
        )
      end

      it "extracts line info from hash points" do
        wrapper = test_wrapper_class.new(hash_point_node, lines: source_lines)
        expect(wrapper.start_line).to eq(2)
        expect(wrapper.end_line).to eq(4)
      end
    end
  end

  describe "#signature" do
    it "calls compute_signature" do
      expect(wrapper.signature).to eq([:test, :test_type])
    end
  end

  describe "#type" do
    it "returns node type as symbol" do
      expect(wrapper.type).to eq(:test_type)
    end
  end

  describe "#type?" do
    it "returns true for matching type as symbol" do
      expect(wrapper.type?(:test_type)).to be true
    end

    it "returns true for matching type as string" do
      expect(wrapper.type?("test_type")).to be true
    end

    it "returns false for non-matching type" do
      expect(wrapper.type?(:other)).to be false
    end
  end

  describe "#freeze_node?" do
    it "returns false by default" do
      expect(wrapper.freeze_node?).to be false
    end
  end

  describe "#node_wrapper?" do
    it "returns true" do
      expect(wrapper.node_wrapper?).to be true
    end
  end

  describe "#underlying_node" do
    it "returns the underlying node" do
      expect(wrapper.underlying_node).to eq(mock_node)
    end
  end

  describe "#content" do
    it "returns lines from start_line to end_line" do
      expect(wrapper.content).to eq("line 1\nline 2\nline 3")
    end

    context "when start_line is nil" do
      let(:no_point_node) do
        double("mock_no_point_node", type: :test)
      end

      it "returns empty string" do
        wrapper = test_wrapper_class.new(no_point_node, lines: source_lines)
        expect(wrapper.content).to eq("")
      end
    end
  end

  describe "#text" do
    it "extracts text using byte positions" do
      expect(wrapper.text).to eq("line 1\nlin")
    end

    context "when node doesn't support byte positions" do
      let(:no_bytes_node) do
        double(
          "mock_no_bytes_node",
          type: :test,
          start_point: double(row: 0),
          end_point: double(row: 0),
        )
      end

      it "returns empty string" do
        wrapper = test_wrapper_class.new(no_bytes_node, lines: source_lines)
        expect(wrapper.text).to eq("")
      end
    end
  end

  describe "#container? and #leaf?" do
    it "defaults container? to false" do
      expect(wrapper.container?).to be false
    end

    it "returns true for leaf? when not a container" do
      expect(wrapper.leaf?).to be true
    end
  end

  describe "#inspect" do
    it "includes class name, type, and line range" do
      result = wrapper.inspect
      expect(result).to include("type=test_type")
      expect(result).to include("lines=1..3")
    end
  end

  describe "abstract #compute_signature" do
    let(:abstract_wrapper_class) do
      Class.new(described_class)
    end

    it "raises NotImplementedError when not overridden" do
      wrapper = abstract_wrapper_class.new(mock_node, lines: source_lines)
      expect { wrapper.signature }.to raise_error(NotImplementedError)
    end
  end

  describe "distinguishing from NodeTyping::Wrapper" do
    let(:typing_wrapper) do
      Ast::Merge::NodeTyping.with_merge_type(wrapper, :custom_type)
    end

    it "NodeWrapperBase has node_wrapper? returning true" do
      expect(wrapper.node_wrapper?).to be true
    end

    it "NodeTyping::Wrapper has typed_node? returning true" do
      expect(typing_wrapper.typed_node?).to be true
    end

    it "NodeTyping::Wrapper does not have node_wrapper?" do
      expect(typing_wrapper.respond_to?(:node_wrapper?)).to be true  # delegated
      expect(typing_wrapper.node_wrapper?).to be true  # delegates to wrapped NodeWrapperBase
    end

    it "allows double wrapping" do
      expect(typing_wrapper.merge_type).to eq(:custom_type)
      expect(typing_wrapper.type).to eq(:test_type)  # delegated to NodeWrapperBase
      expect(typing_wrapper.start_line).to eq(1)  # delegated
    end

    it "can unwrap NodeTyping::Wrapper to get NodeWrapperBase" do
      unwrapped = Ast::Merge::NodeTyping.unwrap(typing_wrapper)
      expect(unwrapped).to eq(wrapper)
      expect(unwrapped.node_wrapper?).to be true
    end

    it "can get underlying TreeHaver node from NodeWrapperBase" do
      expect(wrapper.underlying_node).to eq(mock_node)
    end
  end
end
