# frozen_string_literal: true

RSpec.describe Ast::Merge::EmitterBase do
  let(:emitter_class) do
    Class.new(described_class) do
      def emit_tracked_comment(comment)
        indent = " " * (comment[:indent] || 0)
        @lines << "#{indent}# #{comment[:text]}"
      end

      def emit_comment(text, inline: false)
        if inline
          return if @lines.empty?

          @lines[-1] = "#{@lines[-1]} # #{text}"
        else
          @lines << "#{current_indent}# #{text}"
        end
      end
    end
  end

  let(:emitter) { emitter_class.new }

  describe "#emit_comment_region" do
    it "emits full-line regions and preserves blank gaps from source lines" do
      region = Ast::Merge::Comment::TrackedHashAdapter.region(
        kind: :leading,
        comments: [
          {line: 1, indent: 0, text: "Header", full_line: true, raw: "# Header"},
          {line: 3, indent: 0, text: "More docs", full_line: true, raw: "# More docs"},
        ],
      )

      emitter.emit_comment_region(region, source_lines: ["# Header", "", "# More docs"])

      expect(emitter.lines).to eq(["# Header", "", "# More docs"])
    end

    it "appends inline regions to the current line" do
      region = Ast::Merge::Comment::TrackedHashAdapter.region(
        kind: :inline,
        comments: [
          {line: 2, indent: 11, text: "inline note", full_line: false, raw: "key: value # inline note"},
        ],
      )

      emitter.emit_raw_lines(["key: value"])
      emitter.emit_comment_region(region)

      expect(emitter.lines).to eq(["key: value # inline note"])
    end
  end

  describe "#emit_comment_attachment" do
    it "emits selected leading and inline regions from a shared attachment" do
      attachment = Ast::Merge::Comment::Attachment.new(
        leading_region: Ast::Merge::Comment::TrackedHashAdapter.region(
          kind: :leading,
          comments: [{line: 1, indent: 0, text: "Header", full_line: true, raw: "# Header"}],
        ),
        inline_region: Ast::Merge::Comment::TrackedHashAdapter.region(
          kind: :inline,
          comments: [{line: 2, indent: 11, text: "inline", full_line: false, raw: "key: value # inline"}],
        ),
      )

      emitter.emit_comment_attachment(attachment, leading: true, source_lines: ["# Header"])
      emitter.emit_raw_lines(["key: value"])
      emitter.emit_comment_attachment(attachment, leading: false, inline: true)

      expect(emitter.lines).to eq(["# Header", "key: value # inline"])
    end

    it "can also emit trailing and orphan regions in order" do
      attachment = Ast::Merge::Comment::Attachment.new(
        trailing_region: Ast::Merge::Comment::TrackedHashAdapter.region(
          kind: :trailing,
          comments: [{line: 3, indent: 0, text: "Trailing", full_line: true, raw: "# Trailing"}],
        ),
        orphan_regions: [
          Ast::Merge::Comment::TrackedHashAdapter.region(
            kind: :orphan,
            comments: [{line: 5, indent: 0, text: "Orphan", full_line: true, raw: "# Orphan"}],
          ),
        ],
      )

      emitter.emit_raw_lines(["key: value"])
      emitter.emit_comment_attachment(
        attachment,
        leading: false,
        trailing: true,
        orphan: true,
        source_lines: ["key: value", "", "# Trailing", "", "# Orphan"],
      )

      expect(emitter.lines).to eq(["key: value", "# Trailing", "", "# Orphan"])
    end
  end
end
