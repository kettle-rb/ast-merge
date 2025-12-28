# frozen_string_literal: true

RSpec.describe Ast::Merge::Recipe::Config do
  let(:minimal_config) do
    {
      "name" => "test_recipe",
      "template" => "template.md",
    }
  end

  let(:full_config) do
    {
      "name" => "gem_family_section",
      "description" => "Update gem family section",
      "template" => "GEM_FAMILY_SECTION.md",
      "targets" => ["README.md", "vendor/*/README.md"],
      "injection" => {
        "anchor" => {
          "type" => "heading",
          "text" => "/Gem Family/",
        },
        "position" => "replace",
        "boundary" => {
          "type" => "heading",
        },
      },
      "merge" => {
        "preference" => "template",
        "add_missing" => true,
      },
      "when_missing" => "skip",
    }
  end

  describe ".load" do
    let(:recipe_path) { "/tmp/test_recipe.yml" }

    before do
      File.write(recipe_path, YAML.dump(full_config))
    end

    after do
      File.delete(recipe_path) if File.exist?(recipe_path)
    end

    it "loads a recipe from YAML file" do
      recipe = described_class.load(recipe_path)
      expect(recipe.name).to eq("gem_family_section")
      expect(recipe.template_path).to eq("GEM_FAMILY_SECTION.md")
    end

    it "raises for missing file" do
      expect {
        described_class.load("/nonexistent/file.yml")
      }.to raise_error(ArgumentError, /not found/)
    end
  end

  describe "#initialize" do
    it "creates recipe from minimal config" do
      recipe = described_class.new(minimal_config)
      expect(recipe.name).to eq("test_recipe")
      expect(recipe.template_path).to eq("template.md")
    end

    it "sets defaults for optional fields" do
      recipe = described_class.new(minimal_config)
      expect(recipe.targets).to eq(["*.md"])
      expect(recipe.when_missing).to eq(:skip)
    end

    it "parses full config" do
      recipe = described_class.new(full_config)
      expect(recipe.name).to eq("gem_family_section")
      expect(recipe.description).to eq("Update gem family section")
      expect(recipe.targets).to eq(["README.md", "vendor/*/README.md"])
      expect(recipe.when_missing).to eq(:skip)
    end

    it "raises without template" do
      expect {
        described_class.new({"name" => "test"})
      }.to raise_error(ArgumentError, /template/)
    end
  end

  describe "#injection" do
    let(:recipe) { described_class.new(full_config) }

    it "parses anchor config" do
      expect(recipe.injection[:anchor][:type]).to eq(:heading)
    end

    it "converts text pattern to Regexp" do
      expect(recipe.injection[:anchor][:text]).to be_a(Regexp)
      expect(recipe.injection[:anchor][:text]).to eq(/Gem Family/)
    end

    it "parses position" do
      expect(recipe.injection[:position]).to eq(:replace)
    end

    it "parses boundary config" do
      expect(recipe.injection[:boundary][:type]).to eq(:heading)
    end
  end

  describe "#finder_query" do
    let(:recipe) { described_class.new(full_config) }

    it "returns query hash for InjectionPointFinder" do
      query = recipe.finder_query
      expect(query[:type]).to eq(:heading)
      expect(query[:text]).to be_a(Regexp)
      expect(query[:position]).to eq(:replace)
    end
  end

  describe "#template_absolute_path" do
    it "returns absolute path unchanged" do
      config = minimal_config.merge("template" => "/absolute/path/template.md")
      recipe = described_class.new(config)
      expect(recipe.template_absolute_path).to eq("/absolute/path/template.md")
    end

    it "resolves relative path from base_dir" do
      recipe = described_class.new(minimal_config)
      path = recipe.template_absolute_path(base_dir: "/project")
      expect(path).to eq("/project/template.md")
    end

    it "resolves relative path from recipe location" do
      recipe = described_class.new(minimal_config, recipe_path: "/project/.recipes/test.yml")
      path = recipe.template_absolute_path
      expect(path).to eq("/project/.recipes/template.md")
    end
  end

  describe "#expand_targets" do
    let(:base_dir) { Dir.mktmpdir }

    before do
      FileUtils.mkdir_p(File.join(base_dir, "vendor", "gem1"))
      FileUtils.mkdir_p(File.join(base_dir, "vendor", "gem2"))
      File.write(File.join(base_dir, "README.md"), "# Main")
      File.write(File.join(base_dir, "vendor", "gem1", "README.md"), "# Gem1")
      File.write(File.join(base_dir, "vendor", "gem2", "README.md"), "# Gem2")
    end

    after do
      FileUtils.rm_rf(base_dir)
    end

    it "expands glob patterns" do
      recipe = described_class.new(full_config)
      paths = recipe.expand_targets(base_dir: base_dir)
      expect(paths.size).to eq(3)
      expect(paths).to include(File.join(base_dir, "README.md"))
      expect(paths).to include(File.join(base_dir, "vendor", "gem1", "README.md"))
    end
  end

  describe "#preference" do
    it "returns :template by default" do
      recipe = described_class.new(minimal_config)
      expect(recipe.preference).to eq(:template)
    end

    it "returns configured preference" do
      config = full_config.merge("merge" => {"preference" => "destination"})
      recipe = described_class.new(config)
      expect(recipe.preference).to eq(:destination)
    end
  end

  describe "#add_missing?" do
    it "returns true by default" do
      recipe = described_class.new(minimal_config)
      expect(recipe.add_missing?).to be true
    end

    it "returns false when configured" do
      config = full_config.merge("merge" => {"add_missing" => false})
      recipe = described_class.new(config)
      expect(recipe.add_missing?).to be false
    end
  end
end

