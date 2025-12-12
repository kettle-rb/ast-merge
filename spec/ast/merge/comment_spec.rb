# frozen_string_literal: true

RSpec.describe Ast::Merge::Comment do
  describe Ast::Merge::Comment::Style do
    describe ".for" do
      it "returns a Style instance for :hash_comment" do
        style = described_class.for(:hash_comment)
        expect(style).to be_a(described_class)
        expect(style.name).to eq(:hash_comment)
        expect(style.line_start).to eq("#")
      end

      it "returns a Style instance for :c_style_line" do
        style = described_class.for(:c_style_line)
        expect(style.name).to eq(:c_style_line)
        expect(style.line_start).to eq("//")
      end

      it "returns a Style instance for :html_comment" do
        style = described_class.for(:html_comment)
        expect(style.name).to eq(:html_comment)
        expect(style.line_start).to eq("<!--")
        expect(style.line_end).to eq("-->")
      end

      it "returns a Style instance for :c_style_block" do
        style = described_class.for(:c_style_block)
        expect(style.name).to eq(:c_style_block)
        expect(style.block_start).to eq("/*")
        expect(style.block_end).to eq("*/")
      end

      it "raises ArgumentError for unknown style" do
        expect { described_class.for(:unknown_style) }.to raise_error(ArgumentError, /Unknown comment style/)
      end
    end

    describe "#match_line?" do
      it "matches hash comments" do
        style = described_class.for(:hash_comment)
        expect(style.match_line?("# comment")).to be true
        expect(style.match_line?("  # indented")).to be true
        expect(style.match_line?("not a comment")).to be false
      end

      it "matches C-style line comments" do
        style = described_class.for(:c_style_line)
        expect(style.match_line?("// comment")).to be true
        expect(style.match_line?("  // indented")).to be true
        expect(style.match_line?("# not this style")).to be false
      end

      it "matches HTML comments" do
        style = described_class.for(:html_comment)
        expect(style.match_line?("<!-- comment -->")).to be true
        expect(style.match_line?("  <!-- indented -->")).to be true
        expect(style.match_line?("# not this style")).to be false
      end
    end

    describe "#extract_line_content" do
      it "extracts content from hash comments" do
        style = described_class.for(:hash_comment)
        expect(style.extract_line_content("# hello world")).to eq("hello world")
        expect(style.extract_line_content("#hello")).to eq("hello")
        expect(style.extract_line_content("  # indented")).to eq("indented")
      end

      it "extracts content from C-style line comments" do
        style = described_class.for(:c_style_line)
        expect(style.extract_line_content("// hello")).to eq("hello")
        expect(style.extract_line_content("  // indented")).to eq("indented")
      end

      it "extracts content from HTML comments" do
        style = described_class.for(:html_comment)
        expect(style.extract_line_content("<!-- hello -->")).to eq("hello")
        expect(style.extract_line_content("<!-- multi word comment -->")).to eq("multi word comment")
      end
    end

    describe "#supports_line_comments?" do
      it "returns true for line-based styles" do
        expect(described_class.for(:hash_comment).supports_line_comments?).to be true
        expect(described_class.for(:c_style_line).supports_line_comments?).to be true
      end

      it "returns false for block-only styles" do
        expect(described_class.for(:c_style_block).supports_line_comments?).to be false
      end
    end

    describe "#supports_block_comments?" do
      it "returns true for block-based styles" do
        expect(described_class.for(:c_style_block).supports_block_comments?).to be true
        expect(described_class.for(:html_comment).supports_block_comments?).to be true
      end

      it "returns false for line-only styles" do
        expect(described_class.for(:hash_comment).supports_block_comments?).to be false
      end
    end
  end

  describe Ast::Merge::Comment::Line do
    describe "#content" do
      it "extracts content without the delimiter" do
        line = described_class.new(text: "# frozen_string_literal: true", line_number: 1)
        expect(line.content).to eq("frozen_string_literal: true")
      end

      it "works with different styles" do
        line = described_class.new(text: "// TODO: fix this", line_number: 1, style: :c_style_line)
        expect(line.content).to eq("TODO: fix this")
      end
    end

    describe "#signature" do
      it "returns a normalized signature" do
        line = described_class.new(text: "# Hello World", line_number: 1)
        expect(line.signature).to eq([:comment_line, "hello world"])
      end
    end

    describe "#freeze_marker?" do
      it "detects freeze markers" do
        line = described_class.new(text: "# prism-merge:freeze", line_number: 1)
        expect(line.freeze_marker?("prism-merge")).to be true
      end

      it "detects unfreeze markers" do
        line = described_class.new(text: "# prism-merge:unfreeze", line_number: 1)
        expect(line.freeze_marker?("prism-merge")).to be true
      end

      it "returns false for non-freeze comments" do
        line = described_class.new(text: "# regular comment", line_number: 1)
        expect(line.freeze_marker?("prism-merge")).to be false
      end
    end
  end

  describe Ast::Merge::Comment::Empty do
    describe "#signature" do
      it "returns a generic empty_line signature" do
        empty = described_class.new(line_number: 5)
        expect(empty.signature).to eq([:empty_line])
      end
    end

    describe "#freeze_marker?" do
      it "always returns false" do
        empty = described_class.new(line_number: 5)
        expect(empty.freeze_marker?("anything")).to be false
      end
    end
  end

  describe Ast::Merge::Comment::Block do
    describe "#signature" do
      it "uses first meaningful content for signature" do
        children = [
          Ast::Merge::Comment::Line.new(text: "# First line", line_number: 1),
          Ast::Merge::Comment::Line.new(text: "# Second line", line_number: 2),
        ]
        block = described_class.new(children: children)
        expect(block.signature).to eq([:comment_block, "first line"])
      end
    end

    describe "#normalized_content" do
      it "combines all child content" do
        children = [
          Ast::Merge::Comment::Line.new(text: "# Line one", line_number: 1),
          Ast::Merge::Comment::Line.new(text: "# Line two", line_number: 2),
        ]
        block = described_class.new(children: children)
        expect(block.normalized_content).to eq("Line one\nLine two")
      end
    end

    describe "#freeze_marker?" do
      it "returns true if any child has a freeze marker" do
        children = [
          Ast::Merge::Comment::Line.new(text: "# regular", line_number: 1),
          Ast::Merge::Comment::Line.new(text: "# prism-merge:freeze", line_number: 2),
        ]
        block = described_class.new(children: children)
        expect(block.freeze_marker?("prism-merge")).to be true
      end
    end
  end

  describe Ast::Merge::Comment::Parser do
    describe "#parse" do
      it "parses a single comment line into a Block" do
        lines = ["# frozen_string_literal: true"]
        nodes = described_class.parse(lines)

        expect(nodes.size).to eq(1)
        expect(nodes.first).to be_a(Ast::Merge::Comment::Block)
        expect(nodes.first.children.size).to eq(1)
        expect(nodes.first.children.first).to be_a(Ast::Merge::Comment::Line)
      end

      it "groups contiguous comment lines into a block" do
        lines = [
          "# First line",
          "# Second line",
          "# Third line",
        ]
        nodes = described_class.parse(lines)

        expect(nodes.size).to eq(1)
        expect(nodes.first).to be_a(Ast::Merge::Comment::Block)
        expect(nodes.first.children.size).to eq(3)
      end

      it "separates blocks by empty lines" do
        lines = [
          "# Block one",
          "",
          "# Block two",
        ]
        nodes = described_class.parse(lines)

        expect(nodes.size).to eq(3)
        expect(nodes[0]).to be_a(Ast::Merge::Comment::Block)
        expect(nodes[1]).to be_a(Ast::Merge::Comment::Empty)
        expect(nodes[2]).to be_a(Ast::Merge::Comment::Block)
      end

      it "handles multiple empty lines" do
        lines = [
          "# Comment",
          "",
          "",
          "# Another",
        ]
        nodes = described_class.parse(lines)

        expect(nodes.size).to eq(4)
        expect(nodes[0]).to be_a(Ast::Merge::Comment::Block)
        expect(nodes[1]).to be_a(Ast::Merge::Comment::Empty)
        expect(nodes[2]).to be_a(Ast::Merge::Comment::Empty)
        expect(nodes[3]).to be_a(Ast::Merge::Comment::Block)
      end

      it "returns empty array for empty input" do
        expect(described_class.parse([])).to eq([])
      end

      it "works with C-style line comments" do
        lines = ["// First", "// Second"]
        nodes = described_class.parse(lines, style: :c_style_line)

        expect(nodes.size).to eq(1)
        expect(nodes.first).to be_a(Ast::Merge::Comment::Block)
        expect(nodes.first.children.first.content).to eq("First")
      end

      it "auto-detects comment style" do
        lines = ["// JavaScript comment"]
        nodes = described_class.parse(lines, style: :auto)

        expect(nodes.first.style.name).to eq(:c_style_line)
      end
    end

    describe "block comment parsing" do
      it "parses C-style block comments" do
        lines = ["/* Block comment */"]
        nodes = described_class.parse(lines, style: :c_style_block)

        expect(nodes.size).to eq(1)
        expect(nodes.first).to be_a(Ast::Merge::Comment::Block)
        expect(nodes.first.raw_content).to eq("/* Block comment */")
      end

      it "parses multi-line block comments" do
        lines = [
          "/* Start of block",
          " * Middle line",
          " */",
        ]
        nodes = described_class.parse(lines, style: :c_style_block)

        expect(nodes.size).to eq(1)
        expect(nodes.first).to be_a(Ast::Merge::Comment::Block)
        expect(nodes.first.location.start_line).to eq(1)
        expect(nodes.first.location.end_line).to eq(3)
      end
    end
  end
end
