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

RSpec.shared_examples "Ast::Merge::FileAnalyzable" do
  # Required let blocks:
  # - file_analysis_class: The class under test (e.g., MyMerge::FileAnalysis)
  # - freeze_node_class: The freeze node class (e.g., MyMerge::FreezeNode)
  # - sample_source: A valid source string for this parser
  # - sample_source_with_freeze: Source containing a freeze block
  # - build_file_analysis: Lambda that creates a file analysis instance

  describe "module inclusion" do
    it "includes Ast::Merge::FileAnalyzable" do
      expect(file_analysis_class.ancestors).to include(Ast::Merge::FileAnalyzable)
    end
  end

  describe "attr_readers from FileAnalyzable" do
    let(:analysis) { build_file_analysis.call(sample_source) }

    it "has #source reader" do
      expect(analysis).to respond_to(:source)
    end

    it "has #lines reader" do
      expect(analysis).to respond_to(:lines)
    end

    it "has #freeze_token reader" do
      expect(analysis).to respond_to(:freeze_token)
    end

    it "has #signature_generator reader" do
      expect(analysis).to respond_to(:signature_generator)
    end

    it "has #statements reader" do
      expect(analysis).to respond_to(:statements)
    end
  end

  describe "#freeze_blocks" do
    context "without freeze blocks" do
      let(:analysis) { build_file_analysis.call(sample_source) }

      it "returns an empty array" do
        expect(analysis.freeze_blocks).to eq([])
      end
    end

    context "with freeze blocks" do
      let(:analysis) { build_file_analysis.call(sample_source_with_freeze) }

      it "returns an array of FreezeNode instances" do
        expect(analysis.freeze_blocks).to be_an(Array)
        analysis.freeze_blocks.each do |block|
          expect(block).to be_a(freeze_node_class)
        end
      end
    end
  end

  describe "#in_freeze_block?" do
    let(:analysis) { build_file_analysis.call(sample_source_with_freeze) }

    it "returns false for lines outside freeze blocks" do
      expect(analysis.in_freeze_block?(1)).to be false
    end

    it "responds to the method" do
      expect(analysis).to respond_to(:in_freeze_block?)
    end
  end

  describe "#freeze_block_at" do
    let(:analysis) { build_file_analysis.call(sample_source_with_freeze) }

    it "returns nil for lines outside freeze blocks" do
      expect(analysis.freeze_block_at(1)).to be_nil
    end

    it "responds to the method" do
      expect(analysis).to respond_to(:freeze_block_at)
    end
  end

  describe "#signature_at" do
    let(:analysis) { build_file_analysis.call(sample_source) }

    it "returns nil for invalid index" do
      expect(analysis.signature_at(-1)).to be_nil
      expect(analysis.signature_at(9999)).to be_nil
    end

    it "responds to the method" do
      expect(analysis).to respond_to(:signature_at)
    end
  end

  describe "#line_at" do
    let(:analysis) { build_file_analysis.call(sample_source) }

    it "returns nil for line 0" do
      expect(analysis.line_at(0)).to be_nil
    end

    it "returns nil for negative line" do
      expect(analysis.line_at(-1)).to be_nil
    end

    it "responds to the method" do
      expect(analysis).to respond_to(:line_at)
    end
  end

  describe "#normalized_line" do
    let(:analysis) { build_file_analysis.call(sample_source) }

    it "responds to the method" do
      expect(analysis).to respond_to(:normalized_line)
    end
  end

  describe "#generate_signature" do
    let(:analysis) { build_file_analysis.call(sample_source) }

    it "responds to the method" do
      expect(analysis).to respond_to(:generate_signature)
    end
  end
end
