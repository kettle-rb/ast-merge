# frozen_string_literal: true

RSpec.describe Ast::Merge::Ruleset::FeatureProfile do
  describe "#to_h" do
    it "normalizes feature metadata and derived booleans" do
      profile = described_class.new(
        owner_selector: :shared_default,
        match_key: :signature,
        read_strategy: :native_read_portable_write,
        attachment_strategy: :normalize_tracked_layout_merge,
        comment_style: :hash_comment,
        render_family: :toml_pairs_and_tables,
        comment_capability: Ast::Merge::Comment::Capability.native_full(source: :fixture, style: :hash_comment),
        support_style: Ast::Merge::Comment::SupportStyle.native_read_portable_write(source: :fixture, style: :hash_comment),
        capabilities: {layout_aware: true},
        logical_owners: {link_definition: :preserve_if_referenced},
        metadata: {source: :fixture},
      )

      expect(profile.to_h).to include(
        owner_selector: :shared_default,
        match_key: :signature,
        read_strategy: :native_read_portable_write,
        attachment_strategy: :normalize_tracked_layout_merge,
        comment_style: :hash_comment,
        render_family: :toml_pairs_and_tables,
        capabilities: {layout_aware: true},
        logical_owners: {link_definition: :preserve_if_referenced},
        metadata: {source: :fixture},
        layout_aware: true,
        logical_owner: true,
        comment_aware: true,
        structural_only: false,
      )
    end

    it "detects structural-only profiles" do
      profile = described_class.new(
        owner_selector: :shared_default,
        match_key: :signature,
      )

      expect(profile.layout_aware?).to be(false)
      expect(profile.logical_owner?).to be(false)
      expect(profile.comment_aware?).to be(false)
      expect(profile.structural_only?).to be(true)
    end
  end
end
