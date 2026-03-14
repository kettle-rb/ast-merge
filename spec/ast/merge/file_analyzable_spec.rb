# frozen_string_literal: true

RSpec.describe Ast::Merge::FileAnalyzable do
  let(:analysis_class) do
    Class.new do
      include Ast::Merge::FileAnalyzable

      def initialize(source, statements: [])
        @source = source
        @lines = source.lines.map(&:chomp)
        @freeze_token = "test-merge"
        @signature_generator = nil
        @statements = statements
      end

      def compute_node_signature(node)
        [:owner, node.start_line, node.end_line]
      end
    end
  end

  let(:owner) { Struct.new(:start_line, :end_line).new(2, 2) }
  let(:analysis) { analysis_class.new("header\nbody\nfooter", statements: [owner]) }

  describe "default shared comment hooks" do
    it "reports no comment capability by default" do
      expect(analysis.comment_capability).to be_a(Ast::Merge::Comment::Capability)
      expect(analysis.comment_capability.none?).to be(true)
    end

    it "returns no comment nodes" do
      expect(analysis.comment_nodes).to eq([])
      expect(analysis.comment_node_at(2)).to be_nil
    end

    it "returns an empty region for any requested range" do
      region = analysis.comment_region_for_range(1..2, kind: :leading, repository: :ast_merge)

      expect(region).to be_a(Ast::Merge::Comment::Region)
      expect(region.kind).to eq(:leading)
      expect(region.empty?).to be(true)
      expect(region.metadata[:source]).to eq(:file_analyzable_default)
      expect(region.metadata[:repository]).to eq(:ast_merge)
    end

    it "returns an empty attachment for any owner" do
      attachment = analysis.comment_attachment_for(owner, repository: :ast_merge)

      expect(attachment).to be_a(Ast::Merge::Comment::Attachment)
      expect(attachment.owner).to eq(owner)
      expect(attachment.empty?).to be(true)
      expect(attachment.metadata[:source]).to eq(:file_analyzable_default)
      expect(attachment.metadata[:repository]).to eq(:ast_merge)
    end

    it "builds an empty augmenter that preserves the no-comment capability" do
      augmenter = analysis.comment_augmenter(repository: :ast_merge)

      expect(augmenter).to be_a(Ast::Merge::Comment::Augmenter)
      expect(augmenter.capability.none?).to be(true)
      expect(augmenter.attachment_for(owner)).to be_a(Ast::Merge::Comment::Attachment)
      expect(augmenter.attachment_for(owner).empty?).to be(true)
      expect(augmenter.preamble_region).to be_nil
      expect(augmenter.postlude_region).to be_nil
      expect(augmenter.orphan_regions).to eq([])
    end

    it "reports no leading freeze directives by default" do
      expect(analysis.owner_leading_comment_freeze?(owner)).to be(false)
      expect(analysis.owner_leading_comment_unfreeze?(owner)).to be(false)
    end
  end

  describe "owner-leading freeze helpers" do
    let(:analysis_class) do
      Class.new do
        include Ast::Merge::FileAnalyzable

        def initialize(source, statements: [])
          @source = source
          @lines = source.lines.map(&:chomp)
          @freeze_token = "test-merge"
          @signature_generator = nil
          @statements = statements
        end

        def compute_node_signature(node)
          [:owner, node.start_line, node.end_line]
        end

        def comment_attachment_for(owner, **options)
          Ast::Merge::Comment::Attachment.new(
            owner: owner,
            leading_region: Ast::Merge::Comment::Region.new(
              kind: :leading,
              nodes: [Ast::Merge::Comment::Line.new(text: "# test-merge:freeze", line_number: 1)],
              metadata: options,
            ),
          )
        end
      end
    end

    let(:analysis) { analysis_class.new("# test-merge:freeze\nbody", statements: [owner]) }

    it "detects leading freeze directives through comment attachments" do
      expect(analysis.owner_leading_comment_freeze?(owner)).to be(true)
      expect(analysis.owner_leading_comment_unfreeze?(owner)).to be(false)
    end
  end
end
