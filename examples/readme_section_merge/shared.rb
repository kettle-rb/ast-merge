# frozen_string_literal: true

# Shared helpers for README section merge examples.
#
# This module provides common functionality used by the section merge examples:
# - Color output for terminal display
# - Node text extraction
# - Gem family section detection
# - Path configuration

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "ast-merge", path: File.expand_path("../..", __dir__)
  gem "tree_haver", path: File.expand_path("../../vendor/tree_haver", __dir__)
  gem "markdown-merge", path: File.expand_path("../../vendor/markdown-merge", __dir__)
  gem "markly-merge", path: File.expand_path("../../vendor/markly-merge", __dir__)
end

require "tree_haver"
require "ast-merge"
require "markdown/merge"
require "markly/merge"
require "fileutils"
require "digest"

module ReadmeSectionMerge
  # ANSI color helpers for terminal output
  module Colors
    def self.green(str) = "\e[32m#{str}\e[0m"
    def self.red(str) = "\e[31m#{str}\e[0m"
    def self.yellow(str) = "\e[33m#{str}\e[0m"
    def self.cyan(str) = "\e[36m#{str}\e[0m"
    def self.bold(str) = "\e[1m#{str}\e[0m"
  end

  # Path configuration
  module Paths
    EXAMPLES_DIR = File.expand_path("..", __dir__)
    FIXTURES_DIR = File.join(EXAMPLES_DIR, "fixtures", "readme_merge_test")
    TEMPLATE_SECTION = File.join(File.dirname(EXAMPLES_DIR), "GEM_FAMILY_SECTION.md")
    OUTPUT_DIR = File.join(FIXTURES_DIR, "output")

    def self.ensure_output_dir!
      FileUtils.mkdir_p(OUTPUT_DIR)
    end

    def self.fixture_path(filename)
      File.join(FIXTURES_DIR, filename)
    end

    def self.output_path(prefix, filename)
      File.join(OUTPUT_DIR, "#{prefix}_#{filename}")
    end
  end

  # Default test files to process
  TEST_FILES = {
    "destination_toml.md" => "toml-merge README (fixture)",
    "destination_kettle_dev.md" => "kettle-dev README (fixture)",
  }.freeze

  # Gem family heading text
  GEM_FAMILY_HEADING = "The `*-merge` Gem Family"

  module_function

  # Extract text content from a markdown node.
  #
  # Uses to_plaintext which doesn't escape underscores (unlike to_commonmark).
  #
  # @param node [Object] Markdown node (possibly wrapped)
  # @return [String] Plain text content
  def extract_node_text(node)
    raw = Ast::Merge::NodeTyping.unwrap(node)
    if raw.respond_to?(:to_plaintext)
      raw.to_plaintext.strip
    elsif raw.respond_to?(:string_content)
      raw.string_content.to_s.strip
    else
      ""
    end
  end

  # Check if a node is the gem family H3 heading.
  #
  # @param node [Object] Markdown node
  # @return [Boolean]
  def gem_family_heading?(node)
    canonical_type = Ast::Merge::NodeTyping.merge_type_for(node) ||
      (node.respond_to?(:type) ? node.type : nil)

    return false unless canonical_type.to_s == "heading"

    raw = Ast::Merge::NodeTyping.unwrap(node)
    level = raw.respond_to?(:header_level) ? raw.header_level : nil
    return false unless level == 3

    text = extract_node_text(node)
    text.include?("*-merge") && text.include?("Gem Family")
  end

  # Run a merge experiment and report results.
  #
  # @param description [String] Description of the file being processed
  # @param merger [Markly::Merge::SmartMerger] Configured merger instance
  # @param output_file [String] Path to write output
  # @yield [result] Block to run additional checks
  # @yieldparam result [Markdown::Merge::MergeResult] Merge result
  def run_merge(description:, merger:, output_file:)
    puts Colors.cyan("Processing: #{description}")

    result = merger.merge_result
    File.write(output_file, result.content)

    puts "   #{Colors.green("✓")} Merge completed"
    puts "   Stats: #{result.stats.inspect}"

    # Standard checks
    if result.content.include?("[ts-jsonc]")
      puts "   #{Colors.green("✓")} Contains [ts-jsonc] reference"
    else
      puts "   #{Colors.red("✗")} Missing [ts-jsonc] reference"
    end

    link_ref_count = result.content.scan("[tree_haver]:").count
    if link_ref_count > 1
      puts "   #{Colors.red("✗")} Duplicate link references (#{link_ref_count}x)"
    else
      puts "   #{Colors.green("✓")} No duplicate link references"
    end

    yield result if block_given?

    result
  rescue => e
    puts "   #{Colors.red("✗")} Merge failed: #{e.message}"
    puts "      #{e.class}"
    puts "      #{e.backtrace.first(3).join("\n      ")}" if e.backtrace
    nil
  end

  # Print a section header.
  #
  # @param title [String] Section title
  def print_header(title)
    puts
    puts Colors.bold("━" * 80)
    puts Colors.bold(title)
    puts Colors.bold("━" * 80)
    puts
  end

  # Load the template content.
  #
  # @return [String] Template content
  def load_template
    File.read(Paths::TEMPLATE_SECTION)
  end
end
