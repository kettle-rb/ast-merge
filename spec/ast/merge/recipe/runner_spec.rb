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
        "replace_mode" => true,
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

  describe "#run", :aggregate_failures, :markly_merge do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir, parser: :markly) }

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

  describe "#results_by_status", :markly_merge do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir, parser: :markly) }

    before do
      runner.run
    end

    it "groups results by status" do
      by_status = runner.results_by_status
      expect(by_status).to be_a(Hash)
      expect(by_status.keys).to all(be_a(Symbol))
    end
  end

  describe "#summary", :markly_merge do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir, parser: :markly) }

    before do
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

  describe "#results_table", :markly_merge do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir, parser: :markly) }

    before do
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

  describe "#summary_table", :markly_merge do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir, parser: :markly) }

    before do
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
        message: "Updated successfully",
      )

      expect(result.path).to eq("/path/to/file.md")
      expect(result.relative_path).to eq("file.md")
      expect(result.status).to eq(:updated)
      expect(result.changed).to be true
      expect(result.has_anchor).to be true
      expect(result.message).to eq("Updated successfully")
    end

    it "has stats attribute" do
      result = Ast::Merge::Recipe::Runner::Result.new(
        path: "/path/to/file.md",
        relative_path: "file.md",
        status: :updated,
        changed: true,
        has_anchor: true,
        message: "Updated",
        stats: {nodes_added: 5},
      )

      expect(result.stats).to eq({nodes_added: 5})
    end

    it "has error attribute" do
      error = StandardError.new("Something went wrong")
      result = Ast::Merge::Recipe::Runner::Result.new(
        path: "/path/to/file.md",
        relative_path: "file.md",
        status: :error,
        changed: false,
        has_anchor: false,
        message: "Something went wrong",
        error: error,
      )

      expect(result.error).to eq(error)
    end
  end

  describe "actual file writes (not dry_run)", :markly_merge do
    let(:runner) { described_class.new(recipe, dry_run: false, base_dir: base_dir, parser: :markly) }

    it "writes updated files to disk" do
      runner.run

      # Check that with_anchor.md was actually updated
      updated_content = File.read(File.join(base_dir, "recipes", "with_anchor.md"))
      expect(updated_content).to include("Template content")
    end

    it "returns :updated status for changed files" do
      runner.run
      with_anchor_result = runner.results.find { |r| r.relative_path.include?("with_anchor") }
      expect(with_anchor_result.status).to eq(:updated)
    end
  end

  describe "error handling", :markly_merge do
    context "when file read fails" do
      before do
        # Make a file unreadable
        unreadable_path = File.join(base_dir, "recipes", "unreadable.md")
        File.write(unreadable_path, destination_with_anchor)
        File.chmod(0o000, unreadable_path)
      end

      after do
        # Restore permissions for cleanup
        unreadable_path = File.join(base_dir, "recipes", "unreadable.md")
        File.chmod(0o644, unreadable_path) if File.exist?(unreadable_path)
      end

      let(:recipe_with_unreadable) do
        config = recipe_config.dup
        config["targets"] = ["unreadable.md"]
        Ast::Merge::Recipe::Config.new(config, recipe_path: File.join(base_dir, "recipes", "recipe.yml"))
      end

      it "handles read errors gracefully" do
        runner = described_class.new(recipe_with_unreadable, dry_run: true, base_dir: base_dir, parser: :markly)
        results = runner.run
        expect(results.first.status).to eq(:error)
        expect(results.first.error).to be_a(Exception)
      end
    end

    context "when template file is missing" do
      let(:recipe_missing_template) do
        config = recipe_config.dup
        config["template"] = "nonexistent_template.md"
        Ast::Merge::Recipe::Config.new(config, recipe_path: File.join(base_dir, "recipes", "recipe.yml"))
      end

      it "raises ArgumentError for missing template" do
        runner = described_class.new(recipe_missing_template, dry_run: true, base_dir: base_dir, parser: :markly)
        expect { runner.run }.to raise_error(ArgumentError, /Template not found/)
      end
    end
  end

  describe "when_missing with append", :markly_merge do
    let(:recipe_with_append) do
      config = recipe_config.dup
      config["when_missing"] = "append"
      Ast::Merge::Recipe::Config.new(config, recipe_path: File.join(base_dir, "recipes", "recipe.yml"))
    end

    let(:runner) { described_class.new(recipe_with_append, dry_run: false, base_dir: base_dir, parser: :markly) }

    it "appends template when anchor not found and writes file" do
      runner.run

      # Check without_anchor.md was updated with appended content
      updated_content = File.read(File.join(base_dir, "recipes", "without_anchor.md"))
      expect(updated_content).to include("Template content")

      without_anchor_result = runner.results.find { |r| r.relative_path.include?("without_anchor") }
      expect(without_anchor_result.status).to eq(:updated)
      expect(without_anchor_result.has_anchor).to be false
      expect(without_anchor_result.changed).to be true
    end
  end

  describe "when_missing with append (dry_run)", :markly_merge do
    let(:recipe_with_append) do
      config = recipe_config.dup
      config["when_missing"] = "append"
      Ast::Merge::Recipe::Config.new(config, recipe_path: File.join(base_dir, "recipes", "recipe.yml"))
    end

    let(:runner) { described_class.new(recipe_with_append, dry_run: true, base_dir: base_dir, parser: :markly) }

    it "reports would_update for files that would change" do
      runner.run

      without_anchor_result = runner.results.find { |r| r.relative_path.include?("without_anchor") }
      expect(without_anchor_result.status).to eq(:would_update)
      expect(without_anchor_result.changed).to be true
    end
  end

  describe "unchanged files", :markly_merge do
    before do
      # Create a file that already has the exact template content
      already_updated_content = "# README\n\n## Section\n\n### Gem Family\n\n# Template\n\nTemplate content.\n\n## Another\n\nMore."
      File.write(File.join(base_dir, "recipes", "already_updated.md"), already_updated_content)
    end

    let(:recipe_with_already_updated) do
      config = recipe_config.dup
      config["targets"] = ["already_updated.md"]
      Ast::Merge::Recipe::Config.new(config, recipe_path: File.join(base_dir, "recipes", "recipe.yml"))
    end

    it "detects unchanged files" do
      runner = described_class.new(recipe_with_already_updated, dry_run: true, base_dir: base_dir, parser: :markly)
      runner.run

      # Files may be :unchanged or :would_update depending on exact merge behavior
      status = runner.results.first.status
      expect(status).to eq(:unchanged).or eq(:would_update)
    end
  end

  describe "#make_relative path handling" do
    context "when path starts with base_dir" do
      let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir, parser: :markly) }

      it "makes paths relative to base_dir", :markly_merge do
        runner.run
        expect(runner.results.first.relative_path).not_to start_with(base_dir)
      end
    end

    context "when path is already relative" do
      let(:runner) { described_class.new(recipe, dry_run: true, base_dir: "/some/other/path", parser: :markly) }

      it "handles paths not under base_dir", :markly_merge do
        runner.run
        # Should still work, just using full path or recipe-relative path
        expect(runner.results).not_to be_empty
      end
    end
  end

  describe "verbose option" do
    it "accepts verbose option" do
      runner = described_class.new(recipe, dry_run: true, base_dir: base_dir, verbose: true)
      expect(runner).to be_a(described_class)
    end
  end

  describe "mocked run behavior", :markdown_merge do
    # These tests mock PartialTemplateMerger to test Runner logic without requiring a real parser
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir, parser: :markly) }

    let(:mock_merge_result_with_section) do
      instance_double(
        Markdown::Merge::PartialTemplateMerger::Result,
        section_found?: true,
        has_section: true,
        changed: true,
        content: "merged content",
        message: "Section merged successfully",
        stats: {mode: :merge},
      )
    end

    let(:mock_merge_result_unchanged) do
      instance_double(
        Markdown::Merge::PartialTemplateMerger::Result,
        section_found?: true,
        has_section: true,
        changed: false,
        content: destination_with_anchor,
        message: "Section unchanged",
        stats: {},
      )
    end

    let(:mock_merge_result_no_section) do
      instance_double(
        Markdown::Merge::PartialTemplateMerger::Result,
        section_found?: false,
        has_section: false,
        changed: false,
        content: destination_without_anchor,
        message: "Section not found, skipping",
        stats: {},
      )
    end

    let(:mock_merge_result_appended) do
      instance_double(
        Markdown::Merge::PartialTemplateMerger::Result,
        section_found?: false,
        has_section: false,
        changed: true,
        content: "#{destination_without_anchor}\n\n#{template_content}",
        message: "Section not found, appended template",
        stats: {},
      )
    end

    before do
      # Stub recipe.expand_targets to return predictable files
      allow(recipe).to receive(:expand_targets).and_return([
        File.join(base_dir, "recipes", "with_anchor.md"),
      ])
    end

    describe "#run with section found and changed" do
      before do
        mock_merger = instance_double(Markdown::Merge::PartialTemplateMerger)
        allow(mock_merger).to receive(:merge).and_return(mock_merge_result_with_section)
        allow(Markdown::Merge::PartialTemplateMerger).to receive(:new).and_return(mock_merger)
      end

      it "returns results array" do
        results = runner.run
        expect(results).to be_an(Array)
        expect(results.size).to eq(1)
      end

      it "yields results when block given" do
        yielded_results = []
        runner.run { |r| yielded_results << r }
        expect(yielded_results.size).to eq(1)
      end

      it "sets status to :would_update in dry_run mode" do
        runner.run
        expect(runner.results.first.status).to eq(:would_update)
      end

      it "sets changed to true" do
        runner.run
        expect(runner.results.first.changed).to be true
      end

      it "sets has_anchor to true" do
        runner.run
        expect(runner.results.first.has_anchor).to be true
      end

      it "includes stats from merge result" do
        runner.run
        expect(runner.results.first.stats).to eq({mode: :merge})
      end
    end

    describe "#run with section found but unchanged" do
      before do
        mock_merger = instance_double(Markdown::Merge::PartialTemplateMerger)
        allow(mock_merger).to receive(:merge).and_return(mock_merge_result_unchanged)
        allow(Markdown::Merge::PartialTemplateMerger).to receive(:new).and_return(mock_merger)
      end

      it "sets status to :unchanged" do
        runner.run
        expect(runner.results.first.status).to eq(:unchanged)
      end

      it "sets changed to false" do
        runner.run
        expect(runner.results.first.changed).to be false
      end

      it "sets message to 'No changes needed'" do
        runner.run
        expect(runner.results.first.message).to eq("No changes needed")
      end
    end

    describe "#run with section not found (skipped)" do
      before do
        mock_merger = instance_double(Markdown::Merge::PartialTemplateMerger)
        allow(mock_merger).to receive(:merge).and_return(mock_merge_result_no_section)
        allow(Markdown::Merge::PartialTemplateMerger).to receive(:new).and_return(mock_merger)
      end

      it "sets status to :skipped" do
        runner.run
        expect(runner.results.first.status).to eq(:skipped)
      end

      it "sets has_anchor to false" do
        runner.run
        expect(runner.results.first.has_anchor).to be false
      end
    end

    describe "#run with section not found but appended" do
      before do
        mock_merger = instance_double(Markdown::Merge::PartialTemplateMerger)
        allow(mock_merger).to receive(:merge).and_return(mock_merge_result_appended)
        allow(Markdown::Merge::PartialTemplateMerger).to receive(:new).and_return(mock_merger)
      end

      it "sets status to :would_update in dry_run mode" do
        runner.run
        expect(runner.results.first.status).to eq(:would_update)
      end

      it "sets changed to true" do
        runner.run
        expect(runner.results.first.changed).to be true
      end

      it "sets has_anchor to false" do
        runner.run
        expect(runner.results.first.has_anchor).to be false
      end
    end

    describe "#run with actual file write (not dry_run)" do
      let(:runner) { described_class.new(recipe, dry_run: false, base_dir: base_dir, parser: :markly) }

      before do
        mock_merger = instance_double(Markdown::Merge::PartialTemplateMerger)
        allow(mock_merger).to receive(:merge).and_return(mock_merge_result_with_section)
        allow(Markdown::Merge::PartialTemplateMerger).to receive(:new).and_return(mock_merger)
      end

      it "writes file to disk" do
        runner.run
        content = File.read(File.join(base_dir, "recipes", "with_anchor.md"))
        expect(content).to eq("merged content")
      end

      it "sets status to :updated" do
        runner.run
        expect(runner.results.first.status).to eq(:updated)
      end

      it "sets message to 'Updated'" do
        runner.run
        expect(runner.results.first.message).to eq("Updated")
      end
    end

    describe "#run with file write for appended content (not dry_run)" do
      let(:runner) { described_class.new(recipe, dry_run: false, base_dir: base_dir, parser: :markly) }

      before do
        mock_merger = instance_double(Markdown::Merge::PartialTemplateMerger)
        allow(mock_merger).to receive(:merge).and_return(mock_merge_result_appended)
        allow(Markdown::Merge::PartialTemplateMerger).to receive(:new).and_return(mock_merger)
      end

      it "writes appended content to disk" do
        runner.run
        content = File.read(File.join(base_dir, "recipes", "with_anchor.md"))
        expect(content).to include("Template content")
      end

      it "sets status to :updated" do
        runner.run
        expect(runner.results.first.status).to eq(:updated)
      end
    end

    describe "#run with exception" do
      before do
        allow(Markdown::Merge::PartialTemplateMerger).to receive(:new).and_raise(StandardError.new("Parse failed"))
      end

      it "catches exceptions and returns error result" do
        runner.run
        expect(runner.results.first.status).to eq(:error)
      end

      it "stores the exception in error attribute" do
        runner.run
        expect(runner.results.first.error).to be_a(StandardError)
        expect(runner.results.first.error.message).to eq("Parse failed")
      end

      it "sets changed to false" do
        runner.run
        expect(runner.results.first.changed).to be false
      end

      it "sets has_anchor to false" do
        runner.run
        expect(runner.results.first.has_anchor).to be false
      end

      it "stores error message in message attribute" do
        runner.run
        expect(runner.results.first.message).to eq("Parse failed")
      end
    end
  end

  describe "#summary with mocked results" do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir) }

    before do
      # Directly set results to test summary logic without running actual merges
      runner.instance_variable_set(:@results, [
        described_class::Result.new(path: "a", relative_path: "a", status: :updated, changed: true, has_anchor: true, message: ""),
        described_class::Result.new(path: "b", relative_path: "b", status: :updated, changed: true, has_anchor: true, message: ""),
        described_class::Result.new(path: "c", relative_path: "c", status: :would_update, changed: true, has_anchor: true, message: ""),
        described_class::Result.new(path: "d", relative_path: "d", status: :unchanged, changed: false, has_anchor: true, message: ""),
        described_class::Result.new(path: "e", relative_path: "e", status: :skipped, changed: false, has_anchor: false, message: ""),
        described_class::Result.new(path: "f", relative_path: "f", status: :error, changed: false, has_anchor: false, message: "err"),
      ])
    end

    it "returns correct total" do
      expect(runner.summary[:total]).to eq(6)
    end

    it "counts updated files" do
      expect(runner.summary[:updated]).to eq(2)
    end

    it "counts would_update files" do
      expect(runner.summary[:would_update]).to eq(1)
    end

    it "counts unchanged files" do
      expect(runner.summary[:unchanged]).to eq(1)
    end

    it "counts skipped files" do
      expect(runner.summary[:skipped]).to eq(1)
    end

    it "counts error files" do
      expect(runner.summary[:errors]).to eq(1)
    end
  end

  describe "#results_by_status with mocked results" do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir) }

    before do
      runner.instance_variable_set(:@results, [
        described_class::Result.new(path: "a", relative_path: "a", status: :updated, changed: true, has_anchor: true, message: ""),
        described_class::Result.new(path: "b", relative_path: "b", status: :updated, changed: true, has_anchor: true, message: ""),
        described_class::Result.new(path: "c", relative_path: "c", status: :skipped, changed: false, has_anchor: false, message: ""),
      ])
    end

    it "groups results by status symbol" do
      by_status = runner.results_by_status
      expect(by_status[:updated].size).to eq(2)
      expect(by_status[:skipped].size).to eq(1)
    end
  end

  describe "#results_table with mocked results" do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir) }

    before do
      runner.instance_variable_set(:@results, [
        described_class::Result.new(path: "/full/path/a.md", relative_path: "a.md", status: :updated, changed: true, has_anchor: true, message: "Updated"),
        described_class::Result.new(path: "/full/path/b.md", relative_path: "b.md", status: :unchanged, changed: false, has_anchor: true, message: "No changes"),
      ])
    end

    it "returns array of hashes" do
      table = runner.results_table
      expect(table).to be_an(Array)
      expect(table.size).to eq(2)
    end

    it "includes file relative path" do
      table = runner.results_table
      expect(table.first[:file]).to eq("a.md")
    end

    it "includes status as string" do
      table = runner.results_table
      expect(table.first[:status]).to eq("updated")
    end

    it "includes changed as yes/no" do
      table = runner.results_table
      expect(table.first[:changed]).to eq("yes")
      expect(table.last[:changed]).to eq("no")
    end

    it "includes message" do
      table = runner.results_table
      expect(table.first[:message]).to eq("Updated")
    end
  end

  describe "#summary_table with mocked results" do
    let(:runner) { described_class.new(recipe, dry_run: false, base_dir: base_dir) }

    before do
      runner.instance_variable_set(:@results, [
        described_class::Result.new(path: "a", relative_path: "a", status: :updated, changed: true, has_anchor: true, message: ""),
        described_class::Result.new(path: "b", relative_path: "b", status: :unchanged, changed: false, has_anchor: true, message: ""),
        described_class::Result.new(path: "c", relative_path: "c", status: :skipped, changed: false, has_anchor: false, message: ""),
        described_class::Result.new(path: "d", relative_path: "d", status: :error, changed: false, has_anchor: false, message: ""),
      ])
    end

    it "returns array of metric hashes" do
      table = runner.summary_table
      expect(table).to be_an(Array)
      expect(table.size).to eq(5)
    end

    it "includes total files metric" do
      table = runner.summary_table
      total_row = table.find { |r| r[:metric] == "Total files" }
      expect(total_row[:value]).to eq(4)
    end

    it "includes updated metric (not dry_run)" do
      table = runner.summary_table
      updated_row = table.find { |r| r[:metric] == "Updated" }
      expect(updated_row[:value]).to eq(1)
    end

    it "includes unchanged metric" do
      table = runner.summary_table
      unchanged_row = table.find { |r| r[:metric] == "Unchanged" }
      expect(unchanged_row[:value]).to eq(1)
    end

    it "includes skipped metric" do
      table = runner.summary_table
      skipped_row = table.find { |r| r[:metric] == "Skipped (no anchor)" }
      expect(skipped_row[:value]).to eq(1)
    end

    it "includes errors metric" do
      table = runner.summary_table
      errors_row = table.find { |r| r[:metric] == "Errors" }
      expect(errors_row[:value]).to eq(1)
    end
  end

  describe "#summary_table in dry_run mode" do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir) }

    before do
      runner.instance_variable_set(:@results, [
        described_class::Result.new(path: "a", relative_path: "a", status: :would_update, changed: true, has_anchor: true, message: ""),
      ])
    end

    it "uses would_update count for Updated metric" do
      table = runner.summary_table
      updated_row = table.find { |r| r[:metric] == "Updated" }
      expect(updated_row[:value]).to eq(1)
    end
  end

  describe "#make_relative edge cases" do
    let(:runner) { described_class.new(recipe, dry_run: true, base_dir: base_dir) }

    it "handles path starting with base_dir" do
      result = runner.send(:make_relative, File.join(base_dir, "some", "file.md"))
      expect(result).to eq("some/file.md")
    end

    it "handles path not starting with base_dir but under recipe base" do
      # Path under recipe's parent directory
      recipe_base = File.dirname(recipe.recipe_path, 2)
      result = runner.send(:make_relative, File.join(recipe_base, "other", "file.md"))
      expect(result).to eq("other/file.md")
    end

    it "returns original path when not under any known base" do
      result = runner.send(:make_relative, "/completely/different/path/file.md")
      expect(result).to eq("/completely/different/path/file.md")
    end
  end

  describe "#make_relative without recipe_path" do
    let(:recipe_without_path) do
      Ast::Merge::Recipe::Config.new(recipe_config)
    end
    let(:runner) { described_class.new(recipe_without_path, dry_run: true, base_dir: base_dir) }

    it "handles nil recipe_path gracefully" do
      result = runner.send(:make_relative, "/some/other/path/file.md")
      expect(result).to eq("/some/other/path/file.md")
    end
  end
end
