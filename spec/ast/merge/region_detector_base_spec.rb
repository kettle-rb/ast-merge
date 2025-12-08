# frozen_string_literal: true

RSpec.describe Ast::Merge::RegionDetectorBase do
  # Create a concrete implementation for testing
  let(:test_detector_class) do
    Class.new(described_class) do
      def region_type
        :test_region
      end

      def detect_all(source)
        # Simple implementation that finds lines starting with ">>>"
        regions = []
        source.lines.each_with_index do |line, idx|
          next unless line.start_with?(">>>")

          regions << Ast::Merge::Region.new(
            type: region_type,
            content: line.strip,
            start_line: idx + 1,
            end_line: idx + 1,
            delimiters: nil,
            metadata: {},
          )
        end
        regions
      end
    end
  end

  let(:detector) { test_detector_class.new }

  describe "#region_type" do
    it "returns the type symbol" do
      expect(detector.region_type).to eq(:test_region)
    end

    context "when not implemented" do
      let(:abstract_detector) do
        Class.new(described_class).new
      end

      it "raises NotImplementedError" do
        expect { abstract_detector.region_type }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#detect_all" do
    let(:source) do
      <<~TEXT
        normal line
        >>> test region
        another line
        >>> second region
      TEXT
    end

    it "returns an array of Region objects" do
      regions = detector.detect_all(source)
      expect(regions).to all(be_a(Ast::Merge::Region))
    end

    it "detects all matching regions" do
      regions = detector.detect_all(source)
      expect(regions.size).to eq(2)
    end

    it "returns empty array for source with no matches" do
      regions = detector.detect_all("no matches here")
      expect(regions).to eq([])
    end

    context "when not implemented" do
      let(:abstract_detector) do
        Class.new(described_class).new
      end

      it "raises NotImplementedError" do
        expect { abstract_detector.detect_all("source") }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#strip_delimiters?" do
    it "returns true by default" do
      expect(detector.strip_delimiters?).to be true
    end
  end
end
