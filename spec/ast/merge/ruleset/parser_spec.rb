# frozen_string_literal: true

RSpec.describe Ast::Merge::Ruleset::Parser do
  describe ".parse" do
    let(:valid_ruleset) do
      <<~RULESET
        # comment

        format toml
        owners line_bound_statements
        match signature
        read native_read_portable_write
        attach normalize_tracked_layout_merge
        comment_style hash_comment
        render toml_pairs_and_tables
        capability inline_comments true
        logical_owner link_definition preserve_if_referenced
      RULESET
    end

    it "parses a ruleset into normalized attributes" do
      parsed = described_class.parse(valid_ruleset, path: "/tmp/example.ruleset")

      expect(parsed).to include(
        source: valid_ruleset,
        path: "/tmp/example.ruleset",
        format: :toml,
        owners: :line_bound_statements,
        match: :signature,
        read: :native_read_portable_write,
        attach: :normalize_tracked_layout_merge,
        comment_style: :hash_comment,
        render: :toml_pairs_and_tables,
      )
      expect(parsed[:capabilities]).to eq(inline_comments: true)
      expect(parsed[:logical_owners]).to eq(link_definition: :preserve_if_referenced)
      expect(parsed[:directives].first).to include(name: :format, line_number: 3)
      expect(parsed[:directives].last).to include(name: :logical_owner)
    end

    it "normalizes legacy read-strategy names" do
      parsed = described_class.parse(<<~RULESET)
        format toml
        owners line_bound_statements
        match signature
        read native_read_synthetic_write
        attach normalize_tracked_layout_merge
      RULESET

      expect(parsed[:read]).to eq(:native_read_portable_write)
    end

    it "rejects missing required directives" do
      expect do
        described_class.parse(<<~RULESET)
          format toml
          owners line_bound_statements
          read native_read_portable_write
          attach normalize_tracked_layout_merge
        RULESET
      end.to raise_error(ArgumentError, /missing required directives: match/)
    end

    it "rejects unknown directives" do
      expect do
        described_class.parse(<<~RULESET)
          format toml
          owners line_bound_statements
          match signature
          read native_read_portable_write
          attach normalize_tracked_layout_merge
          frobnicate yes
        RULESET
      end.to raise_error(ArgumentError, /Unknown directive frobnicate/)
    end

    it "rejects duplicate logical owner names" do
      expect do
        described_class.parse(<<~RULESET)
          format markdown
          owners link_definitions
          match normalized_reference
          read source_augmented_portable_write
          attach tracker_layout_merge
          logical_owner link_definition preserve_if_referenced
          logical_owner link_definition preserve_always
        RULESET
      end.to raise_error(ArgumentError, /Duplicate logical_owner link_definition/)
    end
  end
end
