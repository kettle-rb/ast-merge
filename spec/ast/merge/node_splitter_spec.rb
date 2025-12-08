# frozen_string_literal: true

RSpec.describe Ast::Merge::NodeSplitter do
  describe Ast::Merge::NodeSplitter::TypedNodeWrapper do
    let(:mock_node) do
      double("MockNode", name: :test_method, class: Class.new { def self.name = "TestNode" })
    end

    describe "#initialize" do
      it "stores the node and merge_type" do
        wrapper = described_class.new(mock_node, :custom_type)

        expect(wrapper.node).to eq(mock_node)
        expect(wrapper.merge_type).to eq(:custom_type)
      end
    end

    describe "#method_missing" do
      it "delegates to the wrapped node" do
        wrapper = described_class.new(mock_node, :custom_type)

        expect(wrapper.name).to eq(:test_method)
      end
    end

    describe "#respond_to_missing?" do
      it "returns true for methods the wrapped node responds to" do
        wrapper = described_class.new(mock_node, :custom_type)

        expect(wrapper.respond_to?(:name)).to be true
        expect(wrapper.respond_to?(:nonexistent_method)).to be false
      end
    end

    describe "#typed_node?" do
      it "returns true" do
        wrapper = described_class.new(mock_node, :custom_type)

        expect(wrapper.typed_node?).to be true
      end
    end

    describe "#unwrap" do
      it "returns the original node" do
        wrapper = described_class.new(mock_node, :custom_type)

        expect(wrapper.unwrap).to eq(mock_node)
      end
    end

    describe "#==" do
      it "compares by node and merge_type when comparing to another wrapper" do
        wrapper1 = described_class.new(mock_node, :custom_type)
        wrapper2 = described_class.new(mock_node, :custom_type)
        wrapper3 = described_class.new(mock_node, :different_type)

        expect(wrapper1).to eq(wrapper2)
        expect(wrapper1).not_to eq(wrapper3)
      end

      it "compares to the wrapped node when comparing to a non-wrapper" do
        wrapper = described_class.new(mock_node, :custom_type)

        expect(wrapper == mock_node).to be true
      end
    end

    describe "#inspect" do
      it "includes merge_type and node info" do
        wrapper = described_class.new(mock_node, :custom_type)

        expect(wrapper.inspect).to include("TypedNodeWrapper")
        expect(wrapper.inspect).to include("custom_type")
      end
    end

    describe "#hash" do
      it "returns consistent hash for same node and merge_type" do
        wrapper1 = described_class.new(mock_node, :custom_type)
        wrapper2 = described_class.new(mock_node, :custom_type)

        expect(wrapper1.hash).to eq(wrapper2.hash)
      end

      it "returns different hash for different merge_types" do
        wrapper1 = described_class.new(mock_node, :type_a)
        wrapper2 = described_class.new(mock_node, :type_b)

        expect(wrapper1.hash).not_to eq(wrapper2.hash)
      end
    end

    describe "#eql?" do
      it "returns true for equal wrappers" do
        wrapper1 = described_class.new(mock_node, :custom_type)
        wrapper2 = described_class.new(mock_node, :custom_type)

        expect(wrapper1.eql?(wrapper2)).to be true
      end

      it "returns false for different merge_types" do
        wrapper1 = described_class.new(mock_node, :type_a)
        wrapper2 = described_class.new(mock_node, :type_b)

        expect(wrapper1.eql?(wrapper2)).to be false
      end
    end

    describe "#method_missing" do
      it "raises NoMethodError when wrapped node does not respond to method" do
        wrapper = described_class.new(mock_node, :custom_type)

        expect { wrapper.nonexistent_method_xyz }.to raise_error(NoMethodError)
      end
    end
  end

  describe ".with_merge_type" do
    let(:mock_node) { double("MockNode") }

    it "creates a TypedNodeWrapper with the given merge_type" do
      result = described_class.with_merge_type(mock_node, :my_type)

      expect(result).to be_a(Ast::Merge::NodeSplitter::TypedNodeWrapper)
      expect(result.merge_type).to eq(:my_type)
      expect(result.node).to eq(mock_node)
    end
  end

  describe ".typed_node?" do
    it "returns true for TypedNodeWrapper" do
      mock_node = double("MockNode")
      wrapper = described_class.with_merge_type(mock_node, :type)

      expect(described_class.typed_node?(wrapper)).to be true
    end

    it "returns false for regular objects" do
      expect(described_class.typed_node?("string")).to be false
      expect(described_class.typed_node?(nil)).to be false
      expect(described_class.typed_node?(Object.new)).to be false
    end
  end

  describe ".merge_type_for" do
    it "returns merge_type for TypedNodeWrapper" do
      mock_node = double("MockNode")
      wrapper = described_class.with_merge_type(mock_node, :special_type)

      expect(described_class.merge_type_for(wrapper)).to eq(:special_type)
    end

    it "returns nil for non-wrapped nodes" do
      expect(described_class.merge_type_for("string")).to be_nil
      expect(described_class.merge_type_for(nil)).to be_nil
    end
  end

  describe ".unwrap" do
    it "unwraps TypedNodeWrapper" do
      mock_node = double("MockNode")
      wrapper = described_class.with_merge_type(mock_node, :type)

      expect(described_class.unwrap(wrapper)).to eq(mock_node)
    end

    it "returns non-wrapped nodes unchanged" do
      node = "regular_node"

      expect(described_class.unwrap(node)).to eq(node)
    end
  end

  describe ".process" do
    let(:mock_node) do
      node_class = Class.new do
        def self.name
          "CallNode"
        end
      end
      double("MockNode", class: node_class, name: :gem)
    end

    it "returns node unchanged when splitter_config is nil" do
      result = described_class.process(mock_node, nil)

      expect(result).to eq(mock_node)
    end

    it "returns node unchanged when splitter_config is empty" do
      result = described_class.process(mock_node, {})

      expect(result).to eq(mock_node)
    end

    it "returns node unchanged when no matching splitter is found" do
      config = {
        DefNode: ->(node) { described_class.with_merge_type(node, :method) }
      }

      result = described_class.process(mock_node, config)

      expect(result).to eq(mock_node)
    end

    it "processes node through matching splitter by symbol key" do
      config = {
        CallNode: ->(node) { described_class.with_merge_type(node, :call_type) }
      }

      result = described_class.process(mock_node, config)

      expect(described_class.typed_node?(result)).to be true
      expect(result.merge_type).to eq(:call_type)
    end

    it "processes node through matching splitter by string key" do
      config = {
        "CallNode" => ->(node) { described_class.with_merge_type(node, :string_key_type) }
      }

      result = described_class.process(mock_node, config)

      expect(result.merge_type).to eq(:string_key_type)
    end

    it "allows splitter to return node unchanged" do
      config = {
        CallNode: ->(node) { node }
      }

      result = described_class.process(mock_node, config)

      expect(result).to eq(mock_node)
      expect(described_class.typed_node?(result)).to be false
    end

    it "allows splitter to return nil" do
      config = {
        CallNode: ->(_node) { nil }
      }

      result = described_class.process(mock_node, config)

      expect(result).to be_nil
    end

    context "with fully-qualified class name" do
      let(:namespaced_node) do
        node_class = Class.new do
          def self.name
            "Prism::CallNode"
          end
        end
        double("NamespacedNode", class: node_class, name: :test)
      end

      it "finds splitter by fully-qualified symbol key" do
        config = {
          "Prism::CallNode": ->(node) { described_class.with_merge_type(node, :fq_type) }
        }

        result = described_class.process(namespaced_node, config)

        expect(result.merge_type).to eq(:fq_type)
      end

      it "finds splitter by fully-qualified string key" do
        config = {
          "Prism::CallNode" => ->(node) { described_class.with_merge_type(node, :fq_string_type) }
        }

        result = described_class.process(namespaced_node, config)

        expect(result.merge_type).to eq(:fq_string_type)
      end

      it "finds splitter by underscored naming convention" do
        config = {
          prism_call_node: ->(node) { described_class.with_merge_type(node, :underscored_type) }
        }

        result = described_class.process(namespaced_node, config)

        expect(result.merge_type).to eq(:underscored_type)
      end
    end

    context "with already-typed node" do
      it "processes TypedNodeWrapper through matching splitter" do
        wrapped = described_class.with_merge_type(mock_node, :original_type)
        config = {
          CallNode: ->(node) { described_class.with_merge_type(node, :rewrapped_type) }
        }

        result = described_class.process(wrapped, config)

        expect(result.merge_type).to eq(:rewrapped_type)
      end
    end
  end

  describe ".validate!" do
    it "accepts nil" do
      expect { described_class.validate!(nil) }.not_to raise_error
    end

    it "accepts empty hash" do
      expect { described_class.validate!({}) }.not_to raise_error
    end

    it "accepts valid configuration with symbol keys" do
      config = {
        CallNode: ->(_node) { nil },
        DefNode: ->(_node) { nil }
      }

      expect { described_class.validate!(config) }.not_to raise_error
    end

    it "accepts valid configuration with string keys" do
      config = {
        "CallNode" => ->(_node) { nil }
      }

      expect { described_class.validate!(config) }.not_to raise_error
    end

    it "raises ArgumentError for non-Hash" do
      expect { described_class.validate!("not a hash") }
        .to raise_error(ArgumentError, /must be a Hash/)
    end

    it "raises ArgumentError for non-Symbol/String keys" do
      config = { 123 => ->(_node) { nil } }

      expect { described_class.validate!(config) }
        .to raise_error(ArgumentError, /keys must be Symbol or String/)
    end

    it "raises ArgumentError for non-callable values" do
      config = { CallNode: "not callable" }

      expect { described_class.validate!(config) }
        .to raise_error(ArgumentError, /must be callable/)
    end
  end
end
