# frozen_string_literal: true

require "ast/merge/rspec/shared_examples"

RSpec.describe Ast::Merge::MergerConfig do
  it_behaves_like "Ast::Merge::MergerConfig" do
    let(:merger_config_class) { described_class }
    let(:build_merger_config) { ->(**opts) { described_class.new(**opts) } }
  end

  describe ".destination_wins" do
    it "creates a config with :destination preference" do
      config = described_class.destination_wins
      expect(config.signature_match_preference).to eq(:destination)
    end

    it "sets add_template_only_nodes to false" do
      config = described_class.destination_wins
      expect(config.add_template_only_nodes).to be false
    end

    it "accepts freeze_token option" do
      config = described_class.destination_wins(freeze_token: "my-merge")
      expect(config.freeze_token).to eq("my-merge")
    end

    it "accepts signature_generator option" do
      generator = ->(node) { [:custom, node] }
      config = described_class.destination_wins(signature_generator: generator)
      expect(config.signature_generator).to eq(generator)
    end
  end

  describe ".template_wins" do
    it "creates a config with :template preference" do
      config = described_class.template_wins
      expect(config.signature_match_preference).to eq(:template)
    end

    it "sets add_template_only_nodes to true" do
      config = described_class.template_wins
      expect(config.add_template_only_nodes).to be true
    end

    it "accepts freeze_token option" do
      config = described_class.template_wins(freeze_token: "my-merge")
      expect(config.freeze_token).to eq("my-merge")
    end

    it "accepts signature_generator option" do
      generator = ->(node) { [:custom, node] }
      config = described_class.template_wins(signature_generator: generator)
      expect(config.signature_generator).to eq(generator)
    end
  end
end
