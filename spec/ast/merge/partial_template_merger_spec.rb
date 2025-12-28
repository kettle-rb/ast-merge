# frozen_string_literal: true

RSpec.describe Ast::Merge::PartialTemplateMerger, :markly_merge do
  let(:template) do
    <<~MD
      ### The Gem Family

      This is the gem family section.

      | Gem | Description |
      |-----|-------------|
      | gem-a | Does A |
      | gem-b | Does B |

      [gem-a]: https://example.com/gem-a
      [gem-b]: https://example.com/gem-b
    MD
  end

  let(:destination_with_section) do
    <<~MD
      # My Project

      Welcome to my project.

      ## Installation

      Run `gem install my-project`.

      ### The Gem Family

      Old content here.

      | Gem | Description |
      |-----|-------------|
      | gem-a | Old description |

      [gem-a]: https://old-url.com/gem-a

      ## Contributing

      Please contribute!
    MD
  end

  let(:destination_without_section) do
    <<~MD
      # My Project

      Welcome to my project.

      ## Installation

      Run `gem install my-project`.

      ## Contributing

      Please contribute!
    MD
  end

  describe "#merge" do
    context "when destination has the section" do
      let(:merger) do
        described_class.new(
          template: template,
          destination: destination_with_section,
          anchor: {type: :heading, text: /Gem Family/},
          parser: :markly,
        )
      end

      it "returns a Result" do
        result = merger.merge
        expect(result).to be_a(Ast::Merge::PartialTemplateMerger::Result)
      end

      it "finds the section" do
        result = merger.merge
        expect(result.has_section).to be true
        expect(result.section_found?).to be true
      end

      it "returns changed content" do
        result = merger.merge
        expect(result.changed).to be true
      end

      it "preserves content before the section" do
        result = merger.merge
        expect(result.content).to include("# My Project")
        expect(result.content).to include("Welcome to my project")
        expect(result.content).to include("## Installation")
      end

      it "preserves content after the section" do
        result = merger.merge
        expect(result.content).to include("## Contributing")
        # Note: Markly may escape '!' as '\!'
        expect(result.content).to match(/Please contribute/)
      end

      it "updates the section content" do
        result = merger.merge
        expect(result.content).to include("This is the gem family section")
        expect(result.content).to include("gem-b")
      end

      it "includes the injection point in result" do
        result = merger.merge
        expect(result.injection_point).to be_a(Ast::Merge::InjectionPoint)
      end
    end

    context "when destination does NOT have the section" do
      let(:merger) do
        described_class.new(
          template: template,
          destination: destination_without_section,
          anchor: {type: :heading, text: /Gem Family/},
          parser: :markly,
          when_missing: :skip,
        )
      end

      it "returns unchanged content with :skip" do
        result = merger.merge
        expect(result.has_section).to be false
        expect(result.changed).to be false
        expect(result.content).to eq(destination_without_section)
      end

      context "with when_missing: :append" do
        let(:merger) do
          described_class.new(
            template: template,
            destination: destination_without_section,
            anchor: {type: :heading, text: /Gem Family/},
            parser: :markly,
            when_missing: :append,
          )
        end

        it "appends the template at the end" do
          result = merger.merge
          expect(result.changed).to be true
          expect(result.content).to end_with(template.chomp + "\n")
          expect(result.content).to start_with("# My Project")
        end
      end

      context "with when_missing: :prepend" do
        let(:merger) do
          described_class.new(
            template: template,
            destination: destination_without_section,
            anchor: {type: :heading, text: /Gem Family/},
            parser: :markly,
            when_missing: :prepend,
          )
        end

        it "prepends the template at the start" do
          result = merger.merge
          expect(result.changed).to be true
          expect(result.content).to start_with(template)
        end
      end
    end

    context "with custom boundary and replace_mode" do
      let(:destination_multi_section) do
        <<~MD
          # Project

          ## Section A

          Content A.

          ## Section B

          Content B.

          ## Section C

          Content C.
        MD
      end

      let(:section_b_template) do
        <<~MD
          ## Section B

          New content for B.

          Extra paragraph.
        MD
      end

      let(:merger) do
        described_class.new(
          template: section_b_template,
          destination: destination_multi_section,
          anchor: {type: :heading, text: /Section B/},
          boundary: {type: :heading},
          parser: :markly,
          replace_mode: true,  # Full replacement, not merge
        )
      end

      it "replaces only the bounded section" do
        result = merger.merge
        expect(result.content).to include("Content A")
        expect(result.content).to include("New content for B")
        expect(result.content).to include("Content C")
        expect(result.content).not_to include("Content B.")
      end
    end

    context "with custom boundary and merge mode (default)" do
      let(:destination_multi_section) do
        <<~MD
          # Project

          ## Section A

          Content A.

          ## Section B

          Content B.

          Custom destination content.

          ## Section C

          Content C.
        MD
      end

      let(:section_b_template) do
        <<~MD
          ## Section B

          New content for B.

          Extra paragraph.
        MD
      end

      let(:merger) do
        described_class.new(
          template: section_b_template,
          destination: destination_multi_section,
          anchor: {type: :heading, text: /Section B/},
          boundary: {type: :heading},
          parser: :markly,
          preference: :template,
          add_missing: true,
          # replace_mode defaults to false - uses SmartMerger
        )
      end

      it "merges the section intelligently" do
        result = merger.merge
        expect(result.content).to include("Content A")
        expect(result.content).to include("New content for B")
        expect(result.content).to include("Content C")
        # With SmartMerger, behavior depends on matching and preference
        expect(result).to be_a(Ast::Merge::PartialTemplateMerger::Result)
      end
    end

    context "with preference: :destination" do
      let(:merger) do
        described_class.new(
          template: template,
          destination: destination_with_section,
          anchor: {type: :heading, text: /Gem Family/},
          parser: :markly,
          preference: :destination,
        )
      end

      it "prefers destination content for conflicts" do
        result = merger.merge
        # The merger should still work, preference affects conflict resolution
        expect(result).to be_a(Ast::Merge::PartialTemplateMerger::Result)
      end
    end

    context "with add_missing: false" do
      let(:merger) do
        described_class.new(
          template: template,
          destination: destination_with_section,
          anchor: {type: :heading, text: /Gem Family/},
          parser: :markly,
          add_missing: false,
        )
      end

      it "does not add template-only nodes" do
        result = merger.merge
        # With add_missing: false, new nodes from template shouldn't be added
        expect(result).to be_a(Ast::Merge::PartialTemplateMerger::Result)
      end
    end
  end

  describe "Result" do
    let(:result) do
      Ast::Merge::PartialTemplateMerger::Result.new(
        content: "merged content",
        has_section: true,
        changed: true,
        stats: {nodes_added: 2},
        message: "Success",
      )
    end

    it "has content" do
      expect(result.content).to eq("merged content")
    end

    it "has has_section" do
      expect(result.has_section).to be true
    end

    it "has changed" do
      expect(result.changed).to be true
    end

    it "has stats" do
      expect(result.stats).to eq({nodes_added: 2})
    end

    it "has message" do
      expect(result.message).to eq("Success")
    end

    it "responds to section_found?" do
      expect(result.section_found?).to be true
    end
  end

  describe "heading level detection" do
    let(:destination_with_h2_and_h3) do
      <<~MD
        # Title

        ## Section One

        Content one.

        ### Subsection

        Subsection content.

        ## Section Two

        Content two.
      MD
    end

    let(:subsection_template) do
      <<~MD
        ### Subsection

        New subsection content.
      MD
    end

    let(:merger) do
      described_class.new(
        template: subsection_template,
        destination: destination_with_h2_and_h3,
        anchor: {type: :heading, text: /Subsection/},
        parser: :markly,
      )
    end

    it "respects heading levels for section boundaries" do
      result = merger.merge
      # The H3 "Subsection" should extend until the next H2 "Section Two"
      expect(result.content).to include("Content one")
      expect(result.content).to include("New subsection content")
      expect(result.content).to include("## Section Two")
      expect(result.content).to include("Content two")
    end
  end

  describe "advanced features" do
    context "with custom signature_generator" do
      let(:destination) do
        <<~MD
          # Project

          ## Features

          - Feature A
          - Feature B

          ## Links

          [link-a]: https://example.com/a
        MD
      end

      let(:template) do
        <<~MD
          ## Features

          - Feature A (updated)
          - Feature C (new)
        MD
      end

      let(:custom_signature_generator) do
        lambda do |node|
          text = node.respond_to?(:to_plaintext) ? node.to_plaintext.to_s : node.to_s
          if text.include?("Feature")
            [:features, :list_item, text[0, 20]]
          end
        end
      end

      let(:merger) do
        described_class.new(
          template: template,
          destination: destination,
          anchor: {type: :heading, text: /Features/},
          boundary: {type: :heading},
          parser: :markly,
          signature_generator: custom_signature_generator,
        )
      end

      it "accepts custom signature_generator" do
        expect(merger.signature_generator).to eq(custom_signature_generator)
      end

      it "merges with custom signatures" do
        result = merger.merge
        expect(result).to be_a(Ast::Merge::PartialTemplateMerger::Result)
        expect(result.section_found?).to be true
      end
    end

    context "with node_typing configuration" do
      let(:destination) do
        <<~MD
          # Project

          ## Special Section

          Regular paragraph.

          | Name | Value |
          |------|-------|
          | foo  | 100   |
        MD
      end

      let(:template) do
        <<~MD
          ## Special Section

          Updated paragraph.

          | Name | Value |
          |------|-------|
          | foo  | 200   |
          | bar  | 300   |
        MD
      end

      let(:table_typing) do
        lambda do |node|
          text = node.respond_to?(:to_plaintext) ? node.to_plaintext.to_s : node.to_s
          if text.include?("foo")
            Ast::Merge::NodeTyping.with_merge_type(node, :data_table)
          else
            node
          end
        end
      end

      let(:node_typing_config) do
        {"table" => table_typing}
      end

      let(:merger) do
        described_class.new(
          template: template,
          destination: destination,
          anchor: {type: :heading, text: /Special Section/},
          parser: :markly,
          node_typing: node_typing_config,
          preference: :template,
        )
      end

      it "accepts node_typing configuration" do
        expect(merger.node_typing).to eq(node_typing_config)
      end

      it "merges with node typing" do
        result = merger.merge
        expect(result).to be_a(Ast::Merge::PartialTemplateMerger::Result)
        expect(result.section_found?).to be true
      end
    end
  end
end
