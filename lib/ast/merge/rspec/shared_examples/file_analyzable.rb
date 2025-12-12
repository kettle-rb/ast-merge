# frozen_string_literal: true

# Shared examples for validating FileAnalyzable integration
#
# Usage in your spec:
#   require "ast/merge/rspec/shared_examples/file_analyzable"
#
#   RSpec.describe MyMerge::FileAnalysis do
#     it_behaves_like "Ast::Merge::FileAnalyzable" do
#       let(:file_analysis_class) { MyMerge::FileAnalysis }
#       let(:freeze_node_class) { MyMerge::FreezeNode }
#       let(:sample_source) { "# Some valid source for this parser" }
#       let(:sample_source_with_freeze) do
#         <<~SOURCE
#           # Some source
#           # my-merge:freeze
#           frozen content
#           # my-merge:unfreeze
#           # More source
#         SOURCE
#       end
#       # Factory to create file analysis instance
#       let(:build_file_analysis) { ->(source, **opts) { file_analysis_class.new(source, **opts) } }
#     end
#   end
#
# @note The extending class should include Ast::Merge::FileAnalyzable

RSpec.shared_examples("Ast::Merge::FileAnalyzable") do
  # Required let blocks:
  # - file_analysis_class: The class under test (e.g., MyMerge::FileAnalysis)
  # - freeze_node_class: The freeze node class (e.g., MyMerge::FreezeNode)
  # - sample_source: A valid source string for this parser
  # - sample_source_with_freeze: Source containing a freeze block
  # - build_file_analysis: Lambda that creates a file analysis instance

  describe "module inclusion" do
    it "includes Ast::Merge::FileAnalyzable" do
      expect(file_analysis_class.ancestors).to(include(Ast::Merge::FileAnalyzable))
    end
  end

  describe "attr_readers from FileAnalyzable" do
    let(:analysis) { build_file_analysis.call(sample_source) }

    it "has #source reader" do
      expect(analysis).to(respond_to(:source))
    end

    it "has #lines reader" do
      expect(analysis).to(respond_to(:lines))
    end

    it "has #freeze_token reader" do
      expect(analysis).to(respond_to(:freeze_token))
    end

    it "has #signature_generator reader" do
      expect(analysis).to(respond_to(:signature_generator))
    end

    it "has #statements reader" do
      expect(analysis).to(respond_to(:statements))
    end
  end

  describe "#freeze_blocks" do
    context "without freeze blocks" do
      let(:analysis) { build_file_analysis.call(sample_source) }

      it "returns an empty array" do
        expect(analysis.freeze_blocks).to(eq([]))
      end
    end

    context "with freeze blocks" do
      let(:analysis) { build_file_analysis.call(sample_source_with_freeze) }

      it "returns an array of FreezeNode instances" do
        expect(analysis.freeze_blocks).to(be_an(Array))
        analysis.freeze_blocks.each do |block|
          expect(block).to(be_a(freeze_node_class))
        end
      end
    end
  end

  describe "#in_freeze_block?" do
    let(:analysis) { build_file_analysis.call(sample_source_with_freeze) }

    it "returns false for lines outside freeze blocks" do
      expect(analysis.in_freeze_block?(1)).to(be(false))
    end

    it "responds to the method" do
      expect(analysis).to(respond_to(:in_freeze_block?))
    end
  end

  describe "#freeze_block_at" do
    let(:analysis) { build_file_analysis.call(sample_source_with_freeze) }

    it "returns nil for lines outside freeze blocks" do
      expect(analysis.freeze_block_at(1)).to(be_nil)
    end

    it "responds to the method" do
      expect(analysis).to(respond_to(:freeze_block_at))
    end
  end

  describe "#signature_at" do
    let(:analysis) { build_file_analysis.call(sample_source) }

    it "returns nil for invalid index" do
      expect(analysis.signature_at(-1)).to(be_nil)
      expect(analysis.signature_at(9999)).to(be_nil)
    end

    it "responds to the method" do
      expect(analysis).to(respond_to(:signature_at))
    end
  end

  describe "#line_at" do
    let(:analysis) { build_file_analysis.call(sample_source) }

    it "returns nil for line 0" do
      expect(analysis.line_at(0)).to(be_nil)
    end

    it "returns nil for negative line" do
      expect(analysis.line_at(-1)).to(be_nil)
    end

    it "responds to the method" do
      expect(analysis).to(respond_to(:line_at))
    end
  end

  describe "#normalized_line" do
    let(:analysis) { build_file_analysis.call(sample_source) }

    it "responds to the method" do
      expect(analysis).to(respond_to(:normalized_line))
    end
  end

  describe "#generate_signature" do
    let(:analysis) { build_file_analysis.call(sample_source) }

    it "responds to the method" do
      expect(analysis).to(respond_to(:generate_signature))
    end

    context "with NodeTyping::Wrapper" do
      let(:analysis) { build_file_analysis.call(sample_source) }

      it "unwraps NodeTyping::Wrapper and computes signature from underlying node" do
        # Skip if no statements to test with
        skip "No statements available for testing" if analysis.statements.empty?

        node = analysis.statements.first

        # Create a NodeTyping::Wrapper around the node
        wrapper = Ast::Merge::NodeTyping::Wrapper.new(node, :test_type)

        # Create a signature generator that returns the wrapper
        wrapped_analysis = build_file_analysis.call(
          sample_source,
          signature_generator: ->(_n) { wrapper },
        )

        # The signature should be computed from the unwrapped node, not the wrapper itself
        # Get the expected signature from the unwrapped node
        expected_sig = analysis.generate_signature(node)

        # The wrapped analysis should produce the same signature
        actual_sig = wrapped_analysis.generate_signature(node)

        expect(actual_sig).to(eq(expected_sig))
        expect(actual_sig).not_to(be_a(Ast::Merge::NodeTyping::Wrapper))
      end

      it "recognizes NodeTyping::Wrapper in fallthrough_node?" do
        node = analysis.statements.first || {type: :test}
        wrapper = Ast::Merge::NodeTyping::Wrapper.new(node, :test_type)

        expect(analysis.send(:fallthrough_node?, wrapper)).to(be(true))
      end
    end
  end
end
