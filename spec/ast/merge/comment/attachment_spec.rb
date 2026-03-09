# frozen_string_literal: true

RSpec.describe Ast::Merge::Comment::Attachment do
  let(:owner) { Ast::Merge::Comment::Line.new(text: "# owner proxy", line_number: 20) }
  let(:leading_region) do
    Ast::Merge::Comment::Region.new(
      kind: :leading,
      nodes: [Ast::Merge::Comment::Line.new(text: "# Leading", line_number: 1)],
    )
  end
  let(:inline_region) do
    Ast::Merge::Comment::Region.new(
      kind: :inline,
      nodes: [Ast::Merge::Comment::Line.new(text: "# Inline", line_number: 20)],
    )
  end
  let(:orphan_region) do
    Ast::Merge::Comment::Region.new(
      kind: :orphan,
      nodes: [Ast::Merge::Comment::Line.new(text: "# Orphan", line_number: 50)],
    )
  end

  describe "#regions" do
    it "returns all non-nil regions in a stable order" do
      attachment = described_class.new(
        owner: owner,
        leading_region: leading_region,
        inline_region: inline_region,
        orphan_regions: [orphan_region],
      )

      expect(attachment.regions).to eq([leading_region, inline_region, orphan_region])
    end

    it "is empty when no regions are provided" do
      attachment = described_class.new(owner: owner)

      expect(attachment).to be_empty
      expect(attachment.regions).to eq([])
    end
  end

  describe "#freeze_marker?" do
    it "returns true when any region contains a freeze marker" do
      marker_region = Ast::Merge::Comment::Region.new(
        kind: :trailing,
        nodes: [Ast::Merge::Comment::Line.new(text: "# psych-merge:freeze", line_number: 30)],
      )

      attachment = described_class.new(
        owner: owner,
        leading_region: leading_region,
        trailing_region: marker_region,
      )

      expect(attachment.freeze_marker?("psych-merge")).to be(true)
      expect(attachment.freeze_marker?("prism-merge")).to be(false)
    end
  end

  describe "#inspect" do
    it "includes owner and region count for debugging" do
      attachment = described_class.new(owner: owner, leading_region: leading_region)

      expect(attachment.inspect).to include("owner")
      expect(attachment.inspect).to include("regions=1")
    end
  end
end
