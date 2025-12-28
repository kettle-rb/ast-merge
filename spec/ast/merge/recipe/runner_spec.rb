# frozen_string_literal: true

RSpec.describe Ast::Merge::Recipe::Runner do
  let(:base_dir) { Dir.mktmpdir }
  let(:template_content) { "# Template\n\nTemplate content." }
  let(:destination_with_anchor) { "# README\n\n## Section\n\n### Gem Family\n\nOld content.\n\n## Another\n\nMore." }
  let(:destination_without_anchor) { "# README\n\n## Section\n\nNo gem family here.\n\n## Another\n\nMore." }

  let(:recipe_config) do
    {
      "name" => "test_recipe",
      "template" => "template.md",
      "targets" => ["with_anchor.md", "without_anchor.md", "sub/*.md"],
      "injection" => {
        "anchor" => {
          "type" => "heading",
          "text" => "/Gem Family/",
        },
        "position" => "replace",
      },
      "merge" => {
        "preference" => "template",
      },
      "when_missing" => "skip",
    }
  end

  let(:recipe) { Ast::Merge::Recipe::Config.new(recipe_config, recipe_path: File.join(base_dir, "recipes", "recipe.yml")) }

  before do
    # Create recipes dir and template
    FileUtils.mkdir_p(File.join(base_dir, "recipes"))
    File.write(File.join(base_dir, "recipes", "template.md"), template_content)

    # Create target files
    File.write(File.join(base_dir, "recipes", "with_anchor.md"), destination_with_anchor)
    File.write(File.join(base_dir, "recipes", "without_anchor.md"), destination_without_anchor)

    FileUtils.mkdir_p(File.join(base_dir, "recipes", "sub"))
    File.write(File.join(base_dir, "recipes", "sub", "nested.md"), destination_with_anchor)
  end

  after do
    FileUtils.rm_rf(base_dir)
  end

  describe "#initialize" do
    it "creates runner with recipe" do
      runner = described_class.new(recipe, base_dir: base_dir)
      expect(runner.recipe).to eq(recipe)
      expect(runner.dry_run).to be false
    end

    it "accepts dry_run option" do
      runner = described_class.new(recipe, dry_run: true, base_dir: base_dir)
      expect(runner.dry_run).to be true
    end
  end

  describe "#run", :aggregate_failures do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir, parser: :markly) }

    before do
      # Load markly-merge for testing
      require "markly/merge"
    end

    it "processes all target files" do
      results = runner.run
      expect(results.size).to eq(3)
    end

    it "yields each result when block given" do
      yielded = []
      runner.run { |r| yielded << r }
      expect(yielded.size).to eq(3)
    end

    it "stores results" do
      runner.run
      expect(runner.results.size).to eq(3)
    end

    it "skips files without anchor" do
      runner.run
      without_anchor_result = runner.results.find { |r| r.relative_path.include?("without_anchor") }
      expect(without_anchor_result.status).to eq(:skipped)
      expect(without_anchor_result.has_anchor).to be false
    end
  end

  describe "#results_by_status" do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir, parser: :markly) }

    before do
      require "markly/merge"
      runner.run
    end

    it "groups results by status" do
      by_status = runner.results_by_status
      expect(by_status).to be_a(Hash)
      expect(by_status.keys).to all(be_a(Symbol))
    end
  end

  describe "#summary" do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir, parser: :markly) }

    before do
      require "markly/merge"
      runner.run
    end

    it "returns summary hash" do
      summary = runner.summary
      expect(summary[:total]).to eq(3)
      expect(summary).to have_key(:updated)
      expect(summary).to have_key(:would_update)
      expect(summary).to have_key(:unchanged)
      expect(summary).to have_key(:skipped)
      expect(summary).to have_key(:errors)
    end
  end

  describe "#results_table" do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir, parser: :markly) }

    before do
      require "markly/merge"
      runner.run
    end

    it "returns array of hashes for TableTennis" do
      table = runner.results_table
      expect(table).to be_an(Array)
      expect(table.first).to be_a(Hash)
      expect(table.first).to have_key(:file)
      expect(table.first).to have_key(:status)
    end
  end

  describe "#summary_table" do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir, parser: :markly) }

    before do
      require "markly/merge"
      runner.run
    end

    it "returns array of hashes for TableTennis" do
      table = runner.summary_table
      expect(table).to be_an(Array)
      expect(table.first).to be_a(Hash)
      expect(table.first).to have_key(:metric)
      expect(table.first).to have_key(:value)
    end
  end

  describe "Result struct" do
    it "has expected attributes" do
      result = Ast::Merge::Recipe::Runner::Result.new(
        path: "/path/to/file.md",
        relative_path: "file.md",
        status: :updated,
        changed: true,
        has_anchor: true,
        message: "Updated successfully"
      )

      expect(result.path).to eq("/path/to/file.md")
      expect(result.relative_path).to eq("file.md")
      expect(result.status).to eq(:updated)
      expect(result.changed).to be true
      expect(result.has_anchor).to be true
      expect(result.message).to eq("Updated successfully")
    end
  end
end

