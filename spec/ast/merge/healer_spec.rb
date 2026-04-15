# frozen_string_literal: true

RSpec.describe Ast::Merge::Healer do
  describe ".normalize_mode" do
    it "accepts supported modes" do
      expect(described_class.normalize_mode(:heal)).to eq(:heal)
      expect(described_class.normalize_mode("warn")).to eq(:warn)
      expect(described_class.normalize_mode("error")).to eq(:error)
      expect(described_class.normalize_mode(:skip)).to eq(:skip)
    end

    it "rejects unknown modes" do
      expect do
        described_class.normalize_mode(:mystery)
      end.to raise_error(ArgumentError, /Unknown corruption handling mode/)
    end
  end

  describe ".handle" do
    let(:prefix) { "[fixture]" }

    it "returns true for heal" do
      expect(
        described_class.handle(mode: :heal, prefix: prefix, kind: :duplicate_block, message: "healed", warner: ->(*) {}),
      ).to be(true)
    end

    it "warns and returns false for warn" do
      warned = []

      result = described_class.handle(
        mode: :warn,
        prefix: prefix,
        kind: :duplicate_block,
        message: "warning only",
        warner: ->(msg) { warned << msg },
      )

      expect(result).to be(false)
      expect(warned).to eq(["[fixture] Suspected corruption (duplicate_block): warning only"])
    end

    it "raises the provided error class for error" do
      custom_error = Class.new(StandardError)

      expect do
        described_class.handle(
          mode: :error,
          prefix: prefix,
          kind: :duplicate_block,
          message: "boom",
          error_class: custom_error,
          warner: ->(*) {},
        )
      end.to raise_error(custom_error, /\[fixture\] Suspected corruption \(duplicate_block\): boom/)
    end

    it "returns false for skip" do
      expect(
        described_class.handle(mode: :skip, prefix: prefix, kind: :duplicate_block, message: "ignored", warner: ->(*) {}),
      ).to be(false)
    end
  end
end
