# frozen_string_literal: true

RSpec.describe Ast::Merge::RegionMergeable do
  # Create a minimal merger class that includes the module
  let(:merger_class) do
    Class.new do
      include Ast::Merge::RegionMergeable

      attr_reader :template_content, :dest_content

      def initialize(template, dest, regions: [], region_placeholder: nil)
        @template_content = template
        @dest_content = dest
        setup_regions(regions: regions, region_placeholder: region_placeholder)
      end

      def merge
        # Simple passthrough merge for testing
        @dest_content
      end
    end
  end

  # Create a mock merger class for region merging
  let(:mock_region_merger_class) do
    Class.new do
      def initialize(template, dest, **options)
        @template = template
        @dest = dest
        @options = options
      end

      def merge
        # Simple merge: prefer dest, or template if dest empty
        @dest.empty? ? @template : @dest
      end
    end
  end

  describe "#setup_regions" do
    let(:detector) { Ast::Merge::YamlFrontmatterDetector.new }

    it "configures region detection" do
      merger = merger_class.new("t", "d", regions: [{detector: detector}])
      expect(merger.regions_configured?).to be true
    end

    it "handles empty regions array" do
      merger = merger_class.new("t", "d", regions: [])
      expect(merger.regions_configured?).to be false
    end

    it "handles nil regions" do
      merger = merger_class.new("t", "d", regions: nil)
      expect(merger.regions_configured?).to be false
    end

    it "accepts custom placeholder" do
      merger = merger_class.new("t", "d", regions: [{detector: detector}], region_placeholder: "###CUSTOM_")
      expect(merger.instance_variable_get(:@region_placeholder_prefix)).to eq("###CUSTOM_")
    end
  end

  describe "#regions_configured?" do
    it "returns false when no regions configured" do
      merger = merger_class.new("t", "d")
      expect(merger.regions_configured?).to be false
    end

    it "returns true when regions configured" do
      detector = Ast::Merge::YamlFrontmatterDetector.new
      merger = merger_class.new("t", "d", regions: [{detector: detector}])
      expect(merger.regions_configured?).to be true
    end
  end

  describe "#extract_template_regions" do
    let(:detector) { Ast::Merge::YamlFrontmatterDetector.new }

    context "with no regions configured" do
      it "returns content unchanged" do
        merger = merger_class.new("template", "dest")
        result = merger.extract_template_regions("template")
        expect(result).to eq("template")
      end
    end

    context "with regions configured" do
      let(:source) do
        <<~MD
          ---
          title: Test
          ---
          # Body
        MD
      end

      it "extracts regions and replaces with placeholders" do
        merger = merger_class.new("t", "d", regions: [{detector: detector}])
        result = merger.extract_template_regions(source)

        expect(result).to include("<<<AST_MERGE_REGION_")
        expect(result).not_to include("---")
        expect(result).to include("# Body")
      end

      it "stores extracted regions" do
        merger = merger_class.new("t", "d", regions: [{detector: detector}])
        merger.extract_template_regions(source)

        extracted = merger.instance_variable_get(:@extracted_template_regions)
        expect(extracted.size).to eq(1)
        expect(extracted.first.region.content).to eq("title: Test\n")
      end
    end

    context "with placeholder collision" do
      let(:source) do
        "Content with <<<AST_MERGE_REGION_0>>> in it"
      end

      it "raises PlaceholderCollisionError" do
        merger = merger_class.new("t", "d", regions: [{detector: Ast::Merge::YamlFrontmatterDetector.new}])

        expect {
          merger.extract_template_regions(source)
        }.to raise_error(Ast::Merge::PlaceholderCollisionError)
      end

      it "can be avoided with custom placeholder" do
        merger = merger_class.new(
          "t", "d",
          regions: [{detector: Ast::Merge::YamlFrontmatterDetector.new}],
          region_placeholder: "###MY_PLACEHOLDER_",
        )

        expect {
          merger.extract_template_regions(source)
        }.not_to raise_error
      end
    end
  end

  describe "#extract_dest_regions" do
    let(:detector) { Ast::Merge::YamlFrontmatterDetector.new }
    let(:source) do
      <<~MD
        ---
        title: Dest
        ---
        Content
      MD
    end

    it "extracts regions and replaces with placeholders" do
      merger = merger_class.new("t", "d", regions: [{detector: detector}])
      result = merger.extract_dest_regions(source)

      expect(result).to include("<<<AST_MERGE_REGION_")
      expect(result).not_to include("---")
    end

    it "stores extracted regions separately from template" do
      merger = merger_class.new("t", "d", regions: [{detector: detector}])
      merger.extract_template_regions("---\ntitle: T\n---\nT")
      merger.extract_dest_regions(source)

      template_extracted = merger.instance_variable_get(:@extracted_template_regions)
      dest_extracted = merger.instance_variable_get(:@extracted_dest_regions)

      expect(template_extracted.first.region.content).to include("title: T")
      expect(dest_extracted.first.region.content).to include("title: Dest")
    end
  end

  describe "#substitute_merged_regions" do
    let(:detector) { Ast::Merge::YamlFrontmatterDetector.new }

    context "with no regions configured" do
      it "returns content unchanged" do
        merger = merger_class.new("t", "d")
        result = merger.substitute_merged_regions("content")
        expect(result).to eq("content")
      end
    end

    context "with regions but no merger_class" do
      let(:template) do
        <<~MD
          ---
          title: Template
          ---
          Body
        MD
      end

      let(:dest) do
        <<~MD
          ---
          title: Destination
          author: Jane
          ---
          Body
        MD
      end

      it "prefers destination content (preserves customizations)" do
        merger = merger_class.new(template, dest, regions: [{detector: detector}])

        template_processed = merger.extract_template_regions(template)
        dest_processed = merger.extract_dest_regions(dest)

        # Simulate merge - in real use, this would be the merged body
        merged = dest_processed

        result = merger.substitute_merged_regions(merged)

        expect(result).to include("title: Destination")
        expect(result).to include("author: Jane")
      end
    end

    context "with regions and merger_class" do
      let(:template) do
        <<~MD
          ---
          title: Template
          ---
          Body
        MD
      end

      let(:dest) do
        <<~MD
          ---
          author: Jane
          ---
          Body
        MD
      end

      it "uses the merger_class to merge region content" do
        merger = merger_class.new(
          template,
          dest,
          regions: [{
            detector: detector,
            merger_class: mock_region_merger_class,
          }],
        )

        merger.extract_template_regions(template)
        dest_processed = merger.extract_dest_regions(dest)

        result = merger.substitute_merged_regions(dest_processed)

        # Mock merger prefers dest content
        expect(result).to include("author: Jane")
        expect(result).not_to include("title: Template")
      end
    end
  end

  describe "RegionConfig struct" do
    let(:config_class) { Ast::Merge::RegionMergeable::RegionConfig }
    let(:detector) { Ast::Merge::YamlFrontmatterDetector.new }

    it "creates with required detector" do
      config = config_class.new(detector: detector)
      expect(config.detector).to eq(detector)
    end

    it "defaults merger_class to nil" do
      config = config_class.new(detector: detector)
      expect(config.merger_class).to be_nil
    end

    it "defaults merger_options to empty hash" do
      config = config_class.new(detector: detector)
      expect(config.merger_options).to eq({})
    end

    it "defaults regions to empty array" do
      config = config_class.new(detector: detector)
      expect(config.regions).to eq([])
    end

    it "accepts all options" do
      config = config_class.new(
        detector: detector,
        merger_class: mock_region_merger_class,
        merger_options: {foo: :bar},
        regions: [{detector: detector}],
      )

      expect(config.merger_class).to eq(mock_region_merger_class)
      expect(config.merger_options).to eq({foo: :bar})
      expect(config.regions.size).to eq(1)
    end
  end

  describe "ExtractedRegion struct" do
    let(:struct_class) { Ast::Merge::RegionMergeable::ExtractedRegion }
    let(:region) do
      Ast::Merge::Region.new(
        type: :yaml_frontmatter,
        content: "title: Test",
        start_line: 1,
        end_line: 3,
        delimiters: ["---", "---"],
        metadata: {},
      )
    end
    let(:config) do
      Ast::Merge::RegionMergeable::RegionConfig.new(
        detector: Ast::Merge::YamlFrontmatterDetector.new,
      )
    end

    it "stores region, config, and placeholder" do
      extracted = struct_class.new(
        region: region,
        config: config,
        placeholder: "<<<TEST>>>",
        merged_content: nil,
      )

      expect(extracted.region).to eq(region)
      expect(extracted.config).to eq(config)
      expect(extracted.placeholder).to eq("<<<TEST>>>")
      expect(extracted.merged_content).to be_nil
    end
  end

  describe "multiple region types" do
    let(:yaml_detector) { Ast::Merge::YamlFrontmatterDetector.new }
    let(:ruby_detector) { Ast::Merge::FencedCodeBlockDetector.ruby }

    let(:source) do
      <<~MD
        ---
        title: Test
        ---

        # Header

        ```ruby
        def hello
          puts "world"
        end
        ```
      MD
    end

    it "extracts multiple region types" do
      merger = merger_class.new(
        "t", "d",
        regions: [
          {detector: yaml_detector},
          {detector: ruby_detector},
        ],
      )

      result = merger.extract_template_regions(source)
      extracted = merger.instance_variable_get(:@extracted_template_regions)

      expect(extracted.size).to eq(2)
      expect(extracted.map { |e| e.region.type }).to contain_exactly(:yaml_frontmatter, :ruby_code_block)
    end
  end
end
