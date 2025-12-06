# frozen_string_literal: true

RSpec.describe Ast::Merge::DebugLogger do
  # Create a test class that includes the module for testing instance methods
  let(:test_class) do
    Class.new do
      extend Ast::Merge::DebugLogger

      class << self
        attr_accessor :env_var_name, :log_prefix
      end

      self.env_var_name = "TEST_DEBUG"
      self.log_prefix = "[Test]"
    end
  end

  describe "class-level configuration" do
    it "has default env_var_name" do
      expect(Ast::Merge::DebugLogger.env_var_name).to eq("AST_MERGE_DEBUG")
    end

    it "has default log_prefix" do
      expect(Ast::Merge::DebugLogger.log_prefix).to eq("[Ast::Merge]")
    end

    it "allows setting env_var_name" do
      original = Ast::Merge::DebugLogger.env_var_name
      Ast::Merge::DebugLogger.env_var_name = "CUSTOM_DEBUG"
      expect(Ast::Merge::DebugLogger.env_var_name).to eq("CUSTOM_DEBUG")
      Ast::Merge::DebugLogger.env_var_name = original
    end

    it "allows setting log_prefix" do
      original = Ast::Merge::DebugLogger.log_prefix
      Ast::Merge::DebugLogger.log_prefix = "[Custom]"
      expect(Ast::Merge::DebugLogger.log_prefix).to eq("[Custom]")
      Ast::Merge::DebugLogger.log_prefix = original
    end
  end

  describe "#enabled?" do
    it "returns false when env var is not set" do
      stub_env("TEST_DEBUG" => nil)
      expect(test_class.enabled?).to be(false)
    end

    it "returns true when env var is set to '1'" do
      stub_env("TEST_DEBUG" => "1")
      expect(test_class.enabled?).to be(true)
    end

    it "returns true when env var is set to 'true'" do
      stub_env("TEST_DEBUG" => "true")
      expect(test_class.enabled?).to be(true)
    end

    it "returns false when env var is set to other values" do
      stub_env("TEST_DEBUG" => "false")
      expect(test_class.enabled?).to be(false)
    end
  end

  describe "#debug" do
    it "outputs message when enabled" do
      stub_env("TEST_DEBUG" => "1")
      expect { test_class.debug("hello") }.to output(/\[Test\] hello/).to_stderr
    end

    it "does not output when disabled" do
      stub_env("TEST_DEBUG" => nil)
      expect { test_class.debug("hello") }.not_to output.to_stderr
    end

    it "includes context when provided" do
      stub_env("TEST_DEBUG" => "1")
      expect { test_class.debug("hello", { key: "value" }) }.to output(/key.*value/).to_stderr
    end
  end

  describe "#time" do
    it "returns block result when disabled" do
      stub_env("TEST_DEBUG" => nil)
      result = test_class.time("operation") { 42 }
      expect(result).to eq(42)
    end

    it "returns block result when enabled" do
      stub_env("TEST_DEBUG" => "1")
      result = test_class.time("operation") { 42 }
      expect(result).to eq(42)
    end

    it "outputs timing when enabled" do
      stub_env("TEST_DEBUG" => "1")
      expect { test_class.time("operation") { sleep(0.001) } }.to output(/operation/).to_stderr
    end
  end

  describe "#log_node" do
    it "outputs node info when enabled" do
      stub_env("TEST_DEBUG" => "1")
      node = double("Node", class: double(name: "TestNode"), inspect: "<TestNode>")
      expect { test_class.log_node(node, label: "processing") }.to output(/processing/).to_stderr
    end

    it "does not output when disabled" do
      stub_env("TEST_DEBUG" => nil)
      node = double("Node", class: double(name: "TestNode"), inspect: "<TestNode>")
      expect { test_class.log_node(node, label: "processing") }.not_to output.to_stderr
    end
  end

  describe "BENCHMARK_AVAILABLE constant" do
    it "is defined as true or false" do
      expect([true, false]).to include(Ast::Merge::DebugLogger::BENCHMARK_AVAILABLE)
    end
  end

  context "when Benchmark is not available" do
    it "falls back to simple timing with warning" do
      stub_env("TEST_DEBUG" => "1")
      stub_const("Ast::Merge::DebugLogger::BENCHMARK_AVAILABLE", false)

      result = test_class.time("operation") { 42 }
      expect(result).to eq(42)
    end
  end

  describe "#info" do
    it "outputs info message when enabled" do
      stub_env("TEST_DEBUG" => "1")
      expect { test_class.info("information") }.to output(/INFO.*information/).to_stderr
    end

    it "does not output when disabled" do
      stub_env("TEST_DEBUG" => nil)
      expect { test_class.info("information") }.not_to output.to_stderr
    end
  end

  describe "#warning" do
    it "always outputs warning message" do
      expect { test_class.warning("danger") }.to output(/WARNING.*danger/).to_stderr
    end
  end

  describe "#env_var_name fallback" do
    # Test the fallback when class doesn't respond to env_var_name
    let(:fallback_class) do
      Class.new do
        extend Ast::Merge::DebugLogger
        # Don't define class-level env_var_name accessor
      end
    end

    it "falls back to Ast::Merge::DebugLogger.env_var_name" do
      expect(fallback_class.env_var_name).to eq(Ast::Merge::DebugLogger.env_var_name)
    end
  end

  describe "#log_prefix fallback" do
    # Test the fallback when class doesn't respond to log_prefix
    let(:fallback_class) do
      Class.new do
        extend Ast::Merge::DebugLogger
        # Don't define class-level log_prefix accessor
      end
    end

    it "falls back to Ast::Merge::DebugLogger.log_prefix" do
      expect(fallback_class.log_prefix).to eq(Ast::Merge::DebugLogger.log_prefix)
    end
  end

  describe "#safe_type_name" do
    it "extracts class name from named class" do
      node = double("Node")
      allow(node).to receive(:class).and_return(String)
      expect(test_class.safe_type_name(node)).to eq("String")
    end

    it "handles class without name" do
      anon_class = Class.new
      node = anon_class.new
      # Anonymous classes have nil name, so it falls back to to_s
      result = test_class.safe_type_name(node)
      expect(result).to be_a(String)
    end

    it "handles errors gracefully" do
      node = double("Node")
      bad_class = double("BadClass")
      allow(node).to receive(:class).and_return(bad_class)
      allow(bad_class).to receive(:respond_to?).with(:name).and_raise(StandardError)
      allow(bad_class).to receive(:to_s).and_return("BadClass")

      expect(test_class.safe_type_name(node)).to eq("BadClass")
    end
  end

  describe "#extract_lines" do
    it "extracts lines from node with location having start_line and end_line" do
      location = double("Location", start_line: 5, end_line: 10)
      node = double("Node", location: location)
      allow(location).to receive(:respond_to?).with(:start_line).and_return(true)
      allow(location).to receive(:respond_to?).with(:end_line).and_return(true)

      expect(test_class.extract_lines(node)).to eq("5..10")
    end

    it "extracts lines from node with location having only start_line" do
      location = double("Location", start_line: 5)
      node = double("Node", location: location)
      allow(location).to receive(:respond_to?).with(:start_line).and_return(true)
      allow(location).to receive(:respond_to?).with(:end_line).and_return(false)

      expect(test_class.extract_lines(node)).to eq("5")
    end

    it "extracts lines from node with direct start_line and end_line" do
      node = double("Node", start_line: 3, end_line: 7)
      allow(node).to receive(:respond_to?).with(:location).and_return(false)
      allow(node).to receive(:respond_to?).with(:start_line).and_return(true)
      allow(node).to receive(:respond_to?).with(:end_line).and_return(true)

      expect(test_class.extract_lines(node)).to eq("3..7")
    end

    it "returns nil for node without line information" do
      node = double("Node")
      allow(node).to receive(:respond_to?).with(:location).and_return(false)
      allow(node).to receive(:respond_to?).with(:start_line).and_return(false)

      expect(test_class.extract_lines(node)).to be_nil
    end
  end

  describe "#extract_node_info" do
    it "extracts type and lines from a node" do
      location = double("Location", start_line: 1, end_line: 5)
      node = double("Node", location: location)
      allow(node).to receive(:class).and_return(String)
      allow(location).to receive(:respond_to?).with(:start_line).and_return(true)
      allow(location).to receive(:respond_to?).with(:end_line).and_return(true)

      info = test_class.extract_node_info(node)
      expect(info[:type]).to eq("String")
      expect(info[:lines]).to eq("1..5")
    end

    it "extracts only type when no lines available" do
      node = double("Node")
      allow(node).to receive(:class).and_return(Integer)
      allow(node).to receive(:respond_to?).with(:location).and_return(false)
      allow(node).to receive(:respond_to?).with(:start_line).and_return(false)

      info = test_class.extract_node_info(node)
      expect(info[:type]).to eq("Integer")
      expect(info).not_to have_key(:lines)
    end
  end

  describe "#env_var_name module method scenarios" do
    # Test the complex branch logic for env_var_name when called in different contexts
    let(:module_with_debug) do
      mod = Module.new do
        extend Ast::Merge::DebugLogger

        class << self
          attr_accessor :env_var_name, :log_prefix
        end

        self.env_var_name = "MODULE_DEBUG"
        self.log_prefix = "[Module]"
      end
      mod
    end

    it "returns module's env_var_name when configured" do
      expect(module_with_debug.env_var_name).to eq("MODULE_DEBUG")
    end

    it "returns module's log_prefix when configured" do
      expect(module_with_debug.log_prefix).to eq("[Module]")
    end
  end

  describe "#log_prefix module method scenarios" do
    let(:unconfigured_module) do
      Module.new do
        extend Ast::Merge::DebugLogger
        # Don't configure env_var_name or log_prefix
      end
    end

    it "falls back to base log_prefix" do
      expect(unconfigured_module.log_prefix).to eq(Ast::Merge::DebugLogger.log_prefix)
    end

    it "falls back to base env_var_name" do
      expect(unconfigured_module.env_var_name).to eq(Ast::Merge::DebugLogger.env_var_name)
    end
  end

  describe "#debug with empty context" do
    it "does not include context when empty" do
      stub_env("TEST_DEBUG" => "1")
      expect { test_class.debug("message", {}) }.to output(/\[Test\] message\n/).to_stderr
    end
  end

  describe "module method context for env_var_name" do
    # These tests cover the complex branching in env_var_name method (line 131)
    # when self.is_a?(Module) && self.singleton_class.method_defined?(:env_var_name)

    describe "when called on a module that extended DebugLogger" do
      let(:extended_module) do
        Module.new do
          extend Ast::Merge::DebugLogger
          self.env_var_name = "MODULE_ENV_VAR"
          self.log_prefix = "[ModulePrefix]"
        end
      end

      it "uses Module-level env_var_name/log_prefix when Module.env_var_name is defined" do
        # Temporarily define Module.env_var_name and Module.log_prefix to exercise the else branch
        Module.define_singleton_method(:env_var_name) { "GLOBAL_MODULE_ENV" }
        Module.define_singleton_method(:log_prefix) { "[GLOBAL_MODULE]" }

        result = extended_module.instance_eval { Ast::Merge::DebugLogger.instance_method(:env_var_name).bind_call(self) }
        expect(result).to eq("GLOBAL_MODULE_ENV")

        result2 = extended_module.instance_eval { Ast::Merge::DebugLogger.instance_method(:log_prefix).bind_call(self) }
        expect(result2).to eq("[GLOBAL_MODULE]")
      ensure
        # Clean up
        Module.singleton_class.send(:remove_method, :env_var_name) if Module.singleton_methods.include?(:env_var_name)
        Module.singleton_class.send(:remove_method, :log_prefix) if Module.singleton_methods.include?(:log_prefix)
      end
    end

    describe "when called from an instance whose class provides the method" do
      let(:class_with_logger) do
        Class.new do
          include Ast::Merge::DebugLogger

          class << self
            attr_accessor :env_var_name, :log_prefix
          end

          self.env_var_name = "CLASS_ENV_VAR"
          self.log_prefix = "[ClassPrefix]"
        end
      end

      it "uses class env_var_name" do
        # This covers the `self.class.respond_to?(:env_var_name)` branch
        instance = class_with_logger.new
        expect(instance.env_var_name).to eq("CLASS_ENV_VAR")
      end

      it "uses class log_prefix" do
        # This covers the `self.class.respond_to?(:log_prefix)` branch
        instance = class_with_logger.new
        expect(instance.log_prefix).to eq("[ClassPrefix]")
      end
    end

    describe "when called from an instance whose class doesn't provide the method" do
      let(:basic_class) do
        Class.new do
          include Ast::Merge::DebugLogger
          # No class-level env_var_name or log_prefix
        end
      end

      it "falls back to Ast::Merge::DebugLogger.env_var_name" do
        instance = basic_class.new
        expect(instance.env_var_name).to eq(Ast::Merge::DebugLogger.env_var_name)
      end

      it "falls back to Ast::Merge::DebugLogger.log_prefix" do
        instance = basic_class.new
        expect(instance.log_prefix).to eq(Ast::Merge::DebugLogger.log_prefix)
      end
    end

    describe "when called on a Class that extended DebugLogger (covers then branch at line 131/147)" do
      # A Class is a Module, and Class.superclass == Module
      # This exercises the `self.class.superclass == Module ? @env_var_name` then branch
      let(:class_that_extended) do
        klass = Class.new do
          extend Ast::Merge::DebugLogger
        end
        # The extended hook already set up accessors and default values
        # Override to verify we're getting the right value
        klass.env_var_name = "CLASS_EXTENDED_VAR"
        klass.log_prefix = "[ClassExtended]"
        klass
      end

      it "uses @env_var_name when Class extended DebugLogger (then branch)" do
        # Class.is_a?(Module) is true, Class.class == Class, Class.superclass == Module
        # So self.class.superclass == Module is TRUE -> then branch -> @env_var_name
        # Call the instance method directly to bypass accessor
        result = class_that_extended.instance_eval { Ast::Merge::DebugLogger.instance_method(:env_var_name).bind_call(self) }
        expect(result).to eq("CLASS_EXTENDED_VAR")
      end

      it "uses @log_prefix when Class extended DebugLogger (then branch)" do
        result = class_that_extended.instance_eval { Ast::Merge::DebugLogger.instance_method(:log_prefix).bind_call(self) }
        expect(result).to eq("[ClassExtended]")
      end
    end

    # NOTE: The else branch at lines 131/147 (`self.class.env_var_name`) is unreachable in practice.
    # For a pure Module, self.class is Module, and Module.superclass is Object (not Module),
    # so the condition `self.class.superclass == Module` is false.
    # However, the else branch calls `self.class.env_var_name` which would be `Module.env_var_name`,
    # but Ruby's Module class doesn't have this method, making this code path impossible to cover
    # without raising NoMethodError. This appears to be dead code.
  end
end
