# frozen_string_literal: true

RSpec.describe Ast::Merge::NavigableStatement do
  # Create a simple mock node for testing
  let(:mock_node) do
    node = Object.new
    allow(node).to receive_messages(
      type: :paragraph,
      signature: [:paragraph, "test"],
      to_s: "Test content",
      source_position: {start_line: 1, end_line: 1},
    )
    node
  end

  let(:class_node) do
    node = Object.new
    allow(node).to receive_messages(
      type: :class,
      signature: [:class, "Foo"],
      to_s: "class Foo\nend",
      source_position: {start_line: 1, end_line: 2},
    )
    node
  end

  describe ".build_list" do
    let(:nodes) { [mock_node, class_node, mock_node] }
    let(:statements) { described_class.build_list(nodes) }

    it "creates NavigableStatement for each node" do
      expect(statements.size).to eq(3)
      expect(statements).to all(be_a(described_class))
    end

    it "assigns correct indices" do
      expect(statements.map(&:index)).to eq([0, 1, 2])
    end

    it "links prev_statement and next_statement" do
      expect(statements[0].prev_statement).to be_nil
      expect(statements[0].next_statement).to eq(statements[1])

      expect(statements[1].prev_statement).to eq(statements[0])
      expect(statements[1].next_statement).to eq(statements[2])

      expect(statements[2].prev_statement).to eq(statements[1])
      expect(statements[2].next_statement).to be_nil
    end
  end

  describe "flat list navigation" do
    let(:nodes) { [mock_node, class_node, mock_node] }
    let(:statements) { described_class.build_list(nodes) }

    it "#next returns next_statement" do
      expect(statements[0].next).to eq(statements[1])
    end

    it "#previous returns prev_statement" do
      expect(statements[1].previous).to eq(statements[0])
    end

    it "#first? returns true for first statement" do
      expect(statements[0].first?).to be true
      expect(statements[1].first?).to be false
    end

    it "#last? returns true for last statement" do
      expect(statements[2].last?).to be true
      expect(statements[1].last?).to be false
    end
  end

  describe "#each_following" do
    let(:nodes) { Array.new(5) { mock_node } }
    let(:statements) { described_class.build_list(nodes) }

    it "yields each following statement" do
      collected = []
      statements[1].each_following { |s|
        collected << s
        true
      }
      expect(collected).to eq([statements[2], statements[3], statements[4]])
    end

    it "returns enumerator when no block given" do
      expect(statements[0].each_following).to be_an(Enumerator)
    end
  end

  describe "#take_until" do
    let(:nodes) { [mock_node, mock_node, class_node, mock_node] }
    let(:statements) { described_class.build_list(nodes) }

    it "collects statements until condition is true" do
      result = statements[0].take_until { |s| s.type == :class }
      expect(result).to eq([statements[1]])
    end

    it "returns empty array when no statements before condition" do
      result = statements[1].take_until { |s| s.type == :class }
      expect(result).to eq([])
    end

    it "returns all following when condition never true" do
      result = statements[0].take_until { |s| s.type == :nonexistent }
      expect(result.size).to eq(3)
    end
  end

  describe "#tree_previous" do
    context "when node responds to previous" do
      let(:prev_node) do
        node = Object.new
        allow(node).to receive_messages(type: :heading)
        node
      end

      let(:tree_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :paragraph,
          previous: prev_node,
          source_position: {start_line: 2, end_line: 2},
        )
        node
      end

      let(:statement) { described_class.new(tree_node, index: 1) }

      it "returns previous sibling" do
        expect(statement.tree_previous.type).to eq(:heading)
      end
    end

    context "when node does not respond to previous" do
      let(:simple_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :simple,
          to_s: "simple",
          source_position: {start_line: 1, end_line: 1},
        )
        node
      end

      let(:statement) { described_class.new(simple_node, index: 0) }

      it "returns nil" do
        expect(statement.tree_previous).to be_nil
      end
    end
  end

  describe "#tree_children" do
    context "when node responds to each" do
      let(:children) { [mock_node, class_node] }
      let(:enumerable_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :document,
          source_position: {start_line: 1, end_line: 10},
        )
        allow(node).to receive(:each).and_yield(children[0]).and_yield(children[1])
        allow(node).to receive(:to_a).and_return(children)
        node
      end

      let(:statement) { described_class.new(enumerable_node, index: 0) }

      it "returns children array" do
        expect(statement.tree_children).to eq(children)
      end
    end

    context "when node responds to children" do
      let(:children) { [mock_node] }
      let(:node_with_children) do
        node = Object.new
        allow(node).to receive_messages(
          type: :section,
          children: children,
          source_position: {start_line: 1, end_line: 5},
        )
        node
      end

      let(:statement) { described_class.new(node_with_children, index: 0) }

      it "returns children" do
        expect(statement.tree_children).to eq(children)
      end
    end

    context "when node has neither each nor children" do
      let(:leaf_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :text,
          to_s: "text content",
          source_position: {start_line: 1, end_line: 1},
        )
        node
      end

      let(:statement) { described_class.new(leaf_node, index: 0) }

      it "returns empty array" do
        expect(statement.tree_children).to eq([])
      end
    end
  end

  describe "#tree_first_child" do
    context "when node responds to first_child" do
      let(:first) { mock_node }
      let(:parent_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :document,
          first_child: first,
          source_position: {start_line: 1, end_line: 10},
        )
        node
      end

      let(:statement) { described_class.new(parent_node, index: 0) }

      it "returns first child" do
        expect(statement.tree_first_child).to eq(first)
      end
    end
  end

  describe "#tree_last_child" do
    context "when node responds to last_child" do
      let(:last) { class_node }
      let(:parent_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :document,
          last_child: last,
          source_position: {start_line: 1, end_line: 10},
        )
        node
      end

      let(:statement) { described_class.new(parent_node, index: 0) }

      it "returns last child" do
        expect(statement.tree_last_child).to eq(last)
      end
    end
  end

  describe "#text" do
    context "when node responds to to_plaintext" do
      let(:plaintext_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :paragraph,
          to_plaintext: "Plain text content",
          source_position: {start_line: 1, end_line: 1},
        )
        node
      end

      let(:statement) { described_class.new(plaintext_node, index: 0) }

      it "uses to_plaintext" do
        expect(statement.text).to eq("Plain text content")
      end
    end

    context "when node responds to to_commonmark" do
      let(:commonmark_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :paragraph,
          to_commonmark: "# Heading",
          source_position: {start_line: 1, end_line: 1},
        )
        node
      end

      let(:statement) { described_class.new(commonmark_node, index: 0) }

      it "uses to_commonmark" do
        expect(statement.text).to eq("# Heading")
      end
    end

    context "when node responds to slice" do
      let(:slice_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :code,
          slice: "def foo; end",
          source_position: {start_line: 1, end_line: 1},
        )
        node
      end

      let(:statement) { described_class.new(slice_node, index: 0) }

      it "uses slice" do
        expect(statement.text).to eq("def foo; end")
      end
    end

    context "when node responds to text" do
      let(:text_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :inline,
          text: "inline text",
          source_position: {start_line: 1, end_line: 1},
        )
        node
      end

      let(:statement) { described_class.new(text_node, index: 0) }

      it "uses text" do
        expect(statement.text).to eq("inline text")
      end
    end

    context "when node has no text methods" do
      let(:basic_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :basic,
          source_position: {start_line: 1, end_line: 1},
        )
        allow(node).to receive(:to_s).and_return("basic string")
        node
      end

      let(:statement) { described_class.new(basic_node, index: 0) }

      it "uses to_s" do
        expect(statement.text).to eq("basic string")
      end
    end
  end

  describe "#type when node doesn't respond to type" do
    let(:untyped_node) do
      node = Object.new
      allow(node).to receive_messages(
        to_s: "content",
        source_position: {start_line: 1, end_line: 1},
      )
      node
    end

    let(:statement) { described_class.new(untyped_node, index: 0) }

    it "derives type from class name" do
      expect(statement.type).to eq("Object")
    end
  end

  describe "#signature when node doesn't respond to signature" do
    let(:unsigned_node) do
      node = Object.new
      allow(node).to receive_messages(
        type: :simple,
        to_s: "content",
        source_position: {start_line: 1, end_line: 1},
      )
      node
    end

    let(:statement) { described_class.new(unsigned_node, index: 0) }

    it "returns nil" do
      expect(statement.signature).to be_nil
    end
  end

  describe "#source_position when node doesn't respond to source_position" do
    let(:unpositioned_node) do
      node = Object.new
      allow(node).to receive_messages(
        type: :orphan,
        to_s: "orphan content",
      )
      node
    end

    let(:statement) { described_class.new(unpositioned_node, index: 0) }

    it "returns nil" do
      expect(statement.source_position).to be_nil
    end

    it "#start_line returns nil" do
      expect(statement.start_line).to be_nil
    end

    it "#end_line returns nil" do
      expect(statement.end_line).to be_nil
    end
  end

  describe "#unwrapped_node" do
    context "with wrapper node" do
      let(:inner) { mock_node }
      let(:wrapper) do
        node = Object.new
        allow(node).to receive_messages(
          type: :wrapper,
          inner_node: inner,
          source_position: {start_line: 1, end_line: 1},
        )
        node
      end

      let(:statement) { described_class.new(wrapper, index: 0) }

      it "returns inner node" do
        expect(statement.unwrapped_node).to eq(inner)
      end
    end

    context "with self-referencing inner_node" do
      let(:self_ref_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :self_ref,
          source_position: {start_line: 1, end_line: 1},
        )
        allow(node).to receive(:inner_node).and_return(node)
        node
      end

      let(:statement) { described_class.new(self_ref_node, index: 0) }

      it "returns the node itself" do
        expect(statement.unwrapped_node).to eq(self_ref_node)
      end
    end
  end

  describe "#inspect" do
    let(:statement) { described_class.new(mock_node, index: 5) }

    it "returns human-readable representation" do
      expect(statement.inspect).to match(/#<NavigableStatement\[5\] type=paragraph tree=false>/)
    end
  end

  describe "#to_s" do
    let(:long_node) do
      node = Object.new
      allow(node).to receive_messages(
        type: :paragraph,
        to_s: "This is a very long text that exceeds fifty characters and should be truncated",
        source_position: {start_line: 1, end_line: 1},
      )
      node
    end

    let(:statement) { described_class.new(long_node, index: 0) }

    it "returns truncated text" do
      expect(statement.to_s.length).to be <= 50
    end
  end

  describe "#method_missing" do
    let(:node_with_custom_method) do
      node = Object.new
      allow(node).to receive_messages(
        type: :custom,
        custom_method: "custom_value",
        source_position: {start_line: 1, end_line: 1},
      )
      node
    end

    let(:statement) { described_class.new(node_with_custom_method, index: 0) }

    it "delegates to node" do
      expect(statement.custom_method).to eq("custom_value")
    end

    it "raises NoMethodError for unknown methods" do
      expect { statement.nonexistent_method }.to raise_error(NoMethodError)
    end
  end

  describe "#respond_to_missing?" do
    let(:node_with_method) do
      node = Object.new
      allow(node).to receive_messages(
        type: :custom,
        special_method: true,
        source_position: {start_line: 1, end_line: 1},
      )
      node
    end

    let(:statement) { described_class.new(node_with_method, index: 0) }

    it "returns true for methods node responds to" do
      expect(statement.respond_to?(:special_method)).to be true
    end

    it "returns false for methods node doesn't respond to" do
      expect(statement.respond_to?(:unknown_method)).to be false
    end
  end

  describe "tree navigation" do
    context "with parser-backed node that has tree methods" do
      let(:tree_node) do
        parent = Object.new
        allow(parent).to receive_messages(type: :document)

        next_node = Object.new
        allow(next_node).to receive_messages(type: :paragraph)

        node = Object.new
        allow(node).to receive_messages(
          type: :class,
          parent: parent,
          next: next_node,
          previous: nil,
          source_position: {start_line: 1, end_line: 1},
        )
        node
      end

      let(:statement) { described_class.new(tree_node, index: 0) }

      it "#tree_parent returns parent" do
        expect(statement.tree_parent.type).to eq(:document)
      end

      it "#tree_next returns next sibling" do
        expect(statement.tree_next.type).to eq(:paragraph)
      end

      it "#has_tree_navigation? returns true" do
        expect(statement.has_tree_navigation?).to be true
      end

      it "#synthetic? returns false" do
        expect(statement.synthetic?).to be false
      end
    end

    context "with synthetic node (no tree methods)" do
      let(:synthetic_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :gap_line,
          to_s: "",
          source_position: {start_line: 1, end_line: 1},
        )
        node
      end

      let(:statement) { described_class.new(synthetic_node, index: 0) }

      it "#tree_parent returns nil" do
        expect(statement.tree_parent).to be_nil
      end

      it "#has_tree_navigation? returns false" do
        expect(statement.has_tree_navigation?).to be false
      end

      it "#synthetic? returns true" do
        expect(statement.synthetic?).to be true
      end
    end

    context "with nested tree structure" do
      let(:grandparent) do
        node = Object.new
        allow(node).to receive_messages(type: :document, parent: nil)
        node
      end

      let(:parent) do
        node = Object.new
        allow(node).to receive_messages(type: :section, parent: grandparent)
        node
      end

      let(:child_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :paragraph,
          parent: parent,
          source_position: {start_line: 1, end_line: 1},
        )
        node
      end

      let(:sibling_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :heading,
          parent: parent,
          source_position: {start_line: 2, end_line: 2},
        )
        node
      end

      let(:root_level_node) do
        node = Object.new
        allow(node).to receive_messages(
          type: :heading,
          parent: grandparent,
          source_position: {start_line: 3, end_line: 3},
        )
        node
      end

      let(:child_stmt) { described_class.new(child_node, index: 0) }
      let(:sibling_stmt) { described_class.new(sibling_node, index: 1) }
      let(:root_stmt) { described_class.new(root_level_node, index: 2) }

      describe "#tree_depth" do
        it "returns 0 for root level nodes" do
          root_node = Object.new
          allow(root_node).to receive_messages(
            type: :document,
            parent: nil,
            source_position: {start_line: 1, end_line: 1},
          )
          stmt = described_class.new(root_node, index: 0)
          expect(stmt.tree_depth).to eq(0)
        end

        it "returns 1 for grandparent's children" do
          expect(root_stmt.tree_depth).to eq(1)
        end

        it "returns 2 for parent's children" do
          expect(child_stmt.tree_depth).to eq(2)
          expect(sibling_stmt.tree_depth).to eq(2)
        end
      end

      describe "#same_or_shallower_than?" do
        it "returns true for same depth" do
          expect(sibling_stmt.same_or_shallower_than?(child_stmt)).to be true
        end

        it "returns true for shallower depth" do
          expect(root_stmt.same_or_shallower_than?(child_stmt)).to be true
        end

        it "returns false for deeper depth" do
          expect(child_stmt.same_or_shallower_than?(root_stmt)).to be false
        end

        it "accepts integer depth value" do
          expect(child_stmt.same_or_shallower_than?(2)).to be true
          expect(child_stmt.same_or_shallower_than?(3)).to be true
          expect(child_stmt.same_or_shallower_than?(1)).to be false
        end
      end
    end
  end

  describe "node attribute helpers" do
    let(:statement) { described_class.new(class_node, index: 0) }

    describe "#type?" do
      it "returns true for matching type" do
        expect(statement.type?(:class)).to be true
        expect(statement.type?("class")).to be true
      end

      it "returns false for non-matching type" do
        expect(statement.type?(:method)).to be false
      end
    end

    describe "#text_matches?" do
      it "matches substring" do
        expect(statement.text_matches?("class Foo")).to be true
        expect(statement.text_matches?("class Bar")).to be false
      end

      it "matches regex" do
        expect(statement.text_matches?(/class \w+/)).to be true
        expect(statement.text_matches?(/module \w+/)).to be false
      end
    end

    describe "#node_attribute" do
      let(:node_with_attr) do
        node = Object.new
        allow(node).to receive_messages(
          type: :method,
          name: "foo",
          to_s: "def foo; end",
        )
        node
      end

      let(:statement) { described_class.new(node_with_attr, index: 0) }

      it "returns attribute value" do
        expect(statement.node_attribute(:name)).to eq("foo")
      end

      it "returns nil for missing attribute" do
        expect(statement.node_attribute(:nonexistent)).to be_nil
      end

      it "tries aliases" do
        expect(statement.node_attribute(:method_name, :name)).to eq("foo")
      end
    end
  end

  describe ".find_matching" do
    let(:nodes) { [mock_node, class_node, mock_node] }
    let(:statements) { described_class.build_list(nodes) }

    it "finds by type" do
      result = described_class.find_matching(statements, type: :class)
      expect(result.size).to eq(1)
      expect(result.first.type).to eq(:class)
    end

    it "finds by text" do
      result = described_class.find_matching(statements, text: "Foo")
      expect(result.size).to eq(1)
    end

    it "finds by regex" do
      result = described_class.find_matching(statements, text: /class/)
      expect(result.size).to eq(1)
    end

    it "finds by block" do
      result = described_class.find_matching(statements) { |s| s.index > 1 }
      expect(result.size).to eq(1)
      expect(result.first.index).to eq(2)
    end
  end

  describe ".find_first" do
    let(:nodes) { [mock_node, class_node, mock_node] }
    let(:statements) { described_class.build_list(nodes) }

    it "returns first match" do
      result = described_class.find_first(statements, type: :paragraph)
      expect(result).to eq(statements[0])
    end

    it "returns nil when no match" do
      result = described_class.find_first(statements, type: :module)
      expect(result).to be_nil
    end
  end
end

RSpec.describe Ast::Merge::InjectionPoint do
  let(:mock_node) do
    node = Object.new
    allow(node).to receive_messages(
      type: :paragraph,
      to_s: "Content",
      source_position: {start_line: 1, end_line: 1},
    )
    node
  end

  let(:anchor) { Ast::Merge::NavigableStatement.new(mock_node, index: 0) }

  describe "#initialize" do
    it "creates with valid position" do
      point = described_class.new(anchor: anchor, position: :before)
      expect(point.anchor).to eq(anchor)
      expect(point.position).to eq(:before)
    end

    it "raises for invalid position" do
      expect {
        described_class.new(anchor: anchor, position: :invalid)
      }.to raise_error(ArgumentError, /Invalid position/)
    end

    it "raises for boundary with non-replace position" do
      boundary = Ast::Merge::NavigableStatement.new(mock_node, index: 1)
      expect {
        described_class.new(anchor: anchor, position: :before, boundary: boundary)
      }.to raise_error(ArgumentError, /boundary is only valid/)
    end

    it "allows boundary with replace position" do
      boundary = Ast::Merge::NavigableStatement.new(mock_node, index: 1)
      point = described_class.new(anchor: anchor, position: :replace, boundary: boundary)
      expect(point.boundary).to eq(boundary)
    end
  end

  describe "#replacement?" do
    it "returns true for :replace" do
      point = described_class.new(anchor: anchor, position: :replace)
      expect(point.replacement?).to be true
    end

    it "returns false for other positions" do
      point = described_class.new(anchor: anchor, position: :before)
      expect(point.replacement?).to be false
    end
  end

  describe "#child_injection?" do
    it "returns true for :first_child and :last_child" do
      expect(described_class.new(anchor: anchor, position: :first_child).child_injection?).to be true
      expect(described_class.new(anchor: anchor, position: :last_child).child_injection?).to be true
    end

    it "returns false for other positions" do
      expect(described_class.new(anchor: anchor, position: :before).child_injection?).to be false
    end
  end

  describe "#sibling_injection?" do
    it "returns true for :before and :after" do
      expect(described_class.new(anchor: anchor, position: :before).sibling_injection?).to be true
      expect(described_class.new(anchor: anchor, position: :after).sibling_injection?).to be true
    end

    it "returns false for other positions" do
      expect(described_class.new(anchor: anchor, position: :first_child).sibling_injection?).to be false
    end
  end

  describe "#replaced_statements" do
    let(:nodes) do
      (0..4).map do |i|
        node = Object.new
        allow(node).to receive_messages(
          type: :paragraph,
          to_s: "Content #{i}",
          source_position: {start_line: i + 1, end_line: i + 1},
        )
        node
      end
    end

    let(:statements) { Ast::Merge::NavigableStatement.build_list(nodes) }

    it "returns empty for non-replacement" do
      point = described_class.new(anchor: statements[0], position: :before)
      expect(point.replaced_statements).to eq([])
    end

    it "returns single anchor for replacement without boundary" do
      point = described_class.new(anchor: statements[1], position: :replace)
      expect(point.replaced_statements).to eq([statements[1]])
    end

    it "returns range for replacement with boundary" do
      point = described_class.new(
        anchor: statements[1],
        position: :replace,
        boundary: statements[3],
      )
      expect(point.replaced_statements).to eq([statements[1], statements[2], statements[3]])
    end
  end

  describe "#start_line" do
    let(:nodes) do
      (0..2).map do |i|
        node = Object.new
        allow(node).to receive_messages(
          type: :paragraph,
          to_s: "Content #{i}",
          source_position: {start_line: (i + 1) * 10, end_line: (i + 1) * 10 + 5},
        )
        node
      end
    end

    let(:statements) { Ast::Merge::NavigableStatement.build_list(nodes) }

    it "returns anchor start line" do
      point = described_class.new(anchor: statements[1], position: :replace)
      expect(point.start_line).to eq(20)
    end
  end

  describe "#end_line" do
    let(:nodes) do
      (0..2).map do |i|
        node = Object.new
        allow(node).to receive_messages(
          type: :paragraph,
          to_s: "Content #{i}",
          source_position: {start_line: (i + 1) * 10, end_line: (i + 1) * 10 + 5},
        )
        node
      end
    end

    let(:statements) { Ast::Merge::NavigableStatement.build_list(nodes) }

    it "returns anchor end line when no boundary" do
      point = described_class.new(anchor: statements[1], position: :replace)
      expect(point.end_line).to eq(25)
    end

    it "returns boundary end line when boundary present" do
      point = described_class.new(
        anchor: statements[0],
        position: :replace,
        boundary: statements[2],
      )
      expect(point.end_line).to eq(35)
    end
  end

  describe "#inspect" do
    let(:nodes) do
      2.times.map do |i|
        node = Object.new
        allow(node).to receive_messages(
          type: :paragraph,
          to_s: "Content #{i}",
          source_position: {start_line: i + 1, end_line: i + 1},
        )
        node
      end
    end

    let(:statements) { Ast::Merge::NavigableStatement.build_list(nodes) }

    it "returns readable representation without boundary" do
      point = described_class.new(anchor: statements[0], position: :before)
      expect(point.inspect).to eq("#<InjectionPoint position=before anchor=0>")
    end

    it "returns readable representation with boundary" do
      point = described_class.new(
        anchor: statements[0],
        position: :replace,
        boundary: statements[1],
      )
      expect(point.inspect).to eq("#<InjectionPoint position=replace anchor=0 to 1>")
    end
  end
end

RSpec.describe Ast::Merge::InjectionPointFinder do
  let(:nodes) do
    class_node = Object.new
    allow(class_node).to receive_messages(
      type: :class,
      to_s: "class Foo\nend",
      source_position: {start_line: 1, end_line: 2},
    )

    const_node = Object.new
    allow(const_node).to receive_messages(
      type: :constant,
      to_s: "BAR = 1",
      source_position: {start_line: 3, end_line: 3},
    )

    method_node = Object.new
    allow(method_node).to receive_messages(
      type: :method,
      to_s: "def baz; end",
      source_position: {start_line: 4, end_line: 4},
    )

    [class_node, const_node, method_node]
  end

  let(:statements) { Ast::Merge::NavigableStatement.build_list(nodes) }
  let(:finder) { described_class.new(statements) }

  describe "#find" do
    it "finds injection point by type" do
      point = finder.find(type: :class, position: :first_child)
      expect(point).to be_a(Ast::Merge::InjectionPoint)
      expect(point.anchor.type).to eq(:class)
      expect(point.position).to eq(:first_child)
    end

    it "finds injection point by text" do
      point = finder.find(text: "BAR", position: :replace)
      expect(point.anchor.type).to eq(:constant)
    end

    it "returns nil when no match" do
      point = finder.find(type: :module, position: :after)
      expect(point).to be_nil
    end

    it "includes metadata about the match" do
      point = finder.find(type: :method, position: :before)
      expect(point.metadata[:match]).to include(type: :method)
    end

    context "with boundary_type" do
      it "finds boundary by type" do
        point = finder.find(type: :class, position: :replace, boundary_type: :method)
        expect(point.boundary).not_to be_nil
        expect(point.boundary.type).to eq(:method)
      end
    end

    context "with boundary_text" do
      it "finds boundary by text pattern" do
        point = finder.find(type: :class, position: :replace, boundary_text: /baz/)
        expect(point.boundary).not_to be_nil
        expect(point.boundary.text).to include("baz")
      end
    end

    context "with boundary_matcher proc" do
      it "uses custom matcher for boundary" do
        matcher = ->(stmt) { stmt.type == :method }
        point = finder.find(type: :class, position: :replace, boundary_matcher: matcher)
        expect(point.boundary).not_to be_nil
        expect(point.boundary.type).to eq(:method)
      end
    end

    context "with boundary_same_or_shallower" do
      let(:grandparent) do
        node = Object.new
        allow(node).to receive_messages(type: :document, parent: nil)
        node
      end

      let(:parent) do
        node = Object.new
        allow(node).to receive_messages(type: :section, parent: grandparent)
        node
      end

      let(:nested_nodes) do
        child = Object.new
        allow(child).to receive_messages(
          type: :heading,
          to_s: "# Child",
          source_position: {start_line: 1, end_line: 1},
          parent: parent,
        )

        deeper = Object.new
        deeper_parent = Object.new
        allow(deeper_parent).to receive_messages(type: :subsection, parent: parent)
        allow(deeper).to receive_messages(
          type: :paragraph,
          to_s: "Content",
          source_position: {start_line: 2, end_line: 2},
          parent: deeper_parent,
        )

        sibling = Object.new
        allow(sibling).to receive_messages(
          type: :heading,
          to_s: "# Sibling",
          source_position: {start_line: 3, end_line: 3},
          parent: parent,
        )

        [child, deeper, sibling]
      end

      let(:statements) { Ast::Merge::NavigableStatement.build_list(nested_nodes) }
      let(:finder) { described_class.new(statements) }

      it "finds boundary at same or shallower depth" do
        point = finder.find(type: :heading, position: :replace, boundary_same_or_shallower: true)
        expect(point).not_to be_nil
        # The boundary should be the sibling heading (same depth), not the deeper paragraph
        expect(point.boundary&.type).to eq(:heading)
        expect(point.boundary&.index).to eq(2)
      end

      it "can filter boundary by type with depth check" do
        point = finder.find(
          type: :heading,
          position: :replace,
          boundary_type: :heading,
          boundary_same_or_shallower: true,
        )
        expect(point.boundary).not_to be_nil
        expect(point.boundary.type).to eq(:heading)
      end
    end
  end

  describe "#find_all" do
    let(:nodes_with_duplicates) do
      3.times.map do |i|
        node = Object.new
        allow(node).to receive_messages(
          type: :constant,
          to_s: "CONST_#{i} = #{i}",
          source_position: {start_line: i + 1, end_line: i + 1},
        )
        node
      end
    end

    let(:statements) { Ast::Merge::NavigableStatement.build_list(nodes_with_duplicates) }
    let(:finder) { described_class.new(statements) }

    it "finds all matching injection points" do
      points = finder.find_all(type: :constant, position: :replace)
      expect(points.size).to eq(3)
      expect(points).to all(be_a(Ast::Merge::InjectionPoint))
    end
  end
end
