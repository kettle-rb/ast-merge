# frozen_string_literal: true

require "spec_helper"

RSpec.describe Ast::Merge::Runtime do
  describe Ast::Merge::Runtime::Surface do
    it "normalizes languages and reports embedded surfaces" do
      surface = described_class.new(
        surface_kind: :yard_example_block,
        declared_language: "Ruby",
        effective_language: "ruby",
        address: "document[0] > yard_example[0]",
        parent_address: "document[0] > ruby_doc_comment[Foo#bar]",
        span: 10..14,
        reconstruction_strategy: :rewrite_with_prefix_preservation,
        metadata: {comment_prefix: "#"},
      )

      expect(surface.embedded?).to be(true)
      expect(surface.declared_language).to eq(:ruby)
      expect(surface.effective_language).to eq(:ruby)
      expect(surface.to_h).to include(
        surface_kind: :yard_example_block,
        address: "document[0] > yard_example[0]",
        parent_address: "document[0] > ruby_doc_comment[Foo#bar]",
        reconstruction_strategy: :rewrite_with_prefix_preservation,
      )
    end
  end

  describe Ast::Merge::Runtime::Frame do
    it "tracks root and nested frame state" do
      root = described_class.new(
        operation_id: "root-op",
        depth: 0,
        surface_path: "document[0]",
        language_chain: %i[markdown],
      )
      child = described_class.new(
        parent_operation_id: "root-op",
        operation_id: "child-op",
        depth: 1,
        surface_path: "document[0] > fence[lang=ruby,index=0]",
        language_chain: %i[markdown ruby],
      )

      expect(root.root?).to be(true)
      expect(child.root?).to be(false)
      expect(child.language_chain).to eq(%i[markdown ruby])
    end
  end

  describe Ast::Merge::Runtime::Diagnostic do
    it "reports warning and error states" do
      warning = described_class.new(
        severity: :warn,
        kind: :unsupported_capability,
        operation_id: "op-1",
        surface_path: "document[0]",
        message: "Capability unavailable",
      )
      error = described_class.new(
        severity: :error,
        kind: :delegation_failed,
        operation_id: "op-2",
        surface_path: "document[0] > fence[0]",
        message: "Child delegate failed",
      )

      expect(warning.warning?).to be(true)
      expect(warning.error?).to be(false)
      expect(error.error?).to be(true)
    end
  end

  describe Ast::Merge::Runtime::ChildResult do
    it "captures replacement text, boundaries, and capabilities" do
      diagnostic = Ast::Merge::Runtime::Diagnostic.new(
        severity: :info,
        kind: :child_completed,
        operation_id: "child-op",
        surface_path: "document[0] > yard_example[0]",
        message: "Child merge completed",
      )

      result = described_class.new(
        replacement_text: "puts :ok\n",
        preserved_boundaries: {tag_header: "@example"},
        diagnostics: [diagnostic],
        capabilities_used: %i[nested_surfaces source_spans],
        capabilities_missing: %i[yard_language_hint],
      )

      expect(result.capabilities_used).to eq(%i[nested_surfaces source_spans])
      expect(result.capabilities_missing).to eq(%i[yard_language_hint])
      expect(result.to_h[:diagnostics].first[:kind]).to eq(:child_completed)
    end
  end

  describe Ast::Merge::Runtime::Operation do
    let(:surface) do
      Ast::Merge::Runtime::Surface.new(
        surface_kind: :ruby_doc_comment,
        effective_language: :yard,
        address: "document[0] > ruby_doc_comment[Foo#bar]",
      )
    end

    it "tracks children, diagnostics, and completion state" do
      operation = described_class.new(
        operation_id: "op-1",
        surface: surface,
        template_fragment: "# docs\n",
        destination_fragment: "# docs\n",
      )
      child = Ast::Merge::Runtime::Operation.new(
        operation_id: "op-2",
        surface: surface,
        template_fragment: "",
        destination_fragment: "",
      )
      diagnostic = Ast::Merge::Runtime::Diagnostic.new(
        severity: :warn,
        kind: :unsupported_capability,
        operation_id: "op-1",
        surface_path: surface.address,
        message: "Unsupported capability",
      )

      operation.running!
      operation.add_child(child)
      operation.add_diagnostic(diagnostic)
      operation.complete!(result: Ast::Merge::Runtime::ChildResult.new(replacement_text: "# docs\n"))

      expect(operation.completed?).to be(true)
      expect(operation.children.map(&:operation_id)).to eq(["op-2"])
      expect(operation.diagnostics.map(&:kind)).to eq([:unsupported_capability])
    end

    it "records an assigned delegate" do
      operation = described_class.new(
        operation_id: "op-1",
        surface: surface,
        template_fragment: "# docs\n",
        destination_fragment: "# docs\n",
      )
      delegate = Ast::Merge::Runtime::Delegate.new(name: "ruby-docs")

      operation.assign_delegate!(delegate)

      expect(operation.delegate_name).to eq("ruby-docs")
      expect(operation.delegate_assigned?).to be(true)
    end
  end

  describe Ast::Merge::Runtime::Delegate do
    let(:feature_profile) do
      Ast::Merge::Ruleset::FeatureProfile.new(
        owner_selector: :prism_statement_sequence,
        match_key: :signature,
        read_strategy: :native_read_portable_write,
        attachment_strategy: :prism_native,
        comment_style: :hash_comment,
        render_family: :prism_ruby_source,
      )
    end

    it "matches supported surfaces and capabilities" do
      delegate = described_class.new(
        name: "prism-ruby",
        priority: 20,
        surface_kinds: %i[ruby_document ruby_doc_comment yard_example_block],
        languages: %i[ruby yard],
        feature_profile: feature_profile,
        capabilities: {
          merge: [:ruby_document],
          discover_child_surfaces: %i[ruby_document ruby_doc_comment],
        },
      )
      document_surface = Ast::Merge::Runtime::Surface.new(
        surface_kind: :ruby_document,
        effective_language: :ruby,
        address: "document[0]",
      )
      example_surface = Ast::Merge::Runtime::Surface.new(
        surface_kind: :yard_example_block,
        declared_language: :ruby,
        effective_language: :ruby,
        address: "document[0] > yard_example[0]",
      )

      expect(delegate.supports?(document_surface)).to be(true)
      expect(delegate.capability_supported?(:merge, document_surface)).to be(true)
      expect(delegate.capability_supported?(:merge, example_surface)).to be(false)
      expect(delegate.capability_supported?(:discover_child_surfaces, document_surface)).to be(true)
      expect(delegate.to_h[:feature_profile][:render_family]).to eq(:prism_ruby_source)
    end
  end

  describe Ast::Merge::Runtime::DelegationRegistry do
    it "resolves the highest-priority matching delegate" do
      surface = Ast::Merge::Runtime::Surface.new(
        surface_kind: :ruby_document,
        effective_language: :ruby,
        address: "document[0]",
      )
      generic_delegate = Ast::Merge::Runtime::Delegate.new(
        name: "generic-ruby",
        priority: 5,
        surface_kinds: [:ruby_document],
        languages: [:ruby],
        capabilities: {merge: true},
      )
      specific_delegate = Ast::Merge::Runtime::Delegate.new(
        name: "specific-ruby",
        priority: 10,
        surface_kinds: [:ruby_document],
        languages: [:ruby],
        capabilities: {merge: true},
      )

      registry = described_class.new(delegates: [generic_delegate, specific_delegate])

      expect(registry.resolve(surface)&.name).to eq("specific-ruby")
      expect(registry.resolve(surface, capability: :merge)&.name).to eq("specific-ruby")
      expect(registry.matching_delegates(surface).map(&:name)).to eq(%w[specific-ruby generic-ruby])
    end
  end

  describe Ast::Merge::Runtime::Session do
    it "registers operations, delegates, and aggregates diagnostics" do
      surface = Ast::Merge::Runtime::Surface.new(
        surface_kind: :document,
        effective_language: :markdown,
        address: "document[0]",
      )
      operation = Ast::Merge::Runtime::Operation.new(
        operation_id: "root-op",
        surface: surface,
        template_fragment: "template",
        destination_fragment: "destination",
      )
      diagnostic = Ast::Merge::Runtime::Diagnostic.new(
        severity: :info,
        kind: :started,
        operation_id: "root-op",
        surface_path: surface.address,
        message: "Started merge",
      )
      operation.add_diagnostic(diagnostic)
      delegate = Ast::Merge::Runtime::Delegate.new(
        name: "markdown-runtime",
        priority: 10,
        surface_kinds: [:document],
        languages: [:markdown],
        capabilities: {merge: true},
      )

      session = described_class.new(
        policy_context: {corruption_handling: :warn},
        delegation_registry: Ast::Merge::Runtime::DelegationRegistry.new(delegates: [delegate]),
      )
      session.register(
        operation,
        frame: Ast::Merge::Runtime::Frame.new(
          operation_id: "root-op",
          depth: 0,
          surface_path: "document[0]",
          language_chain: %i[markdown],
        ),
        delegate: session.resolve_delegate_for(surface, capability: :merge),
      )

      expect(session.operation("root-op")).to eq(operation)
      expect(session.root_operations).to eq([operation])
      expect(session.resolve_delegate_for(surface, capability: :merge)).to eq(delegate)
      expect(session.diagnostics.map(&:kind)).to eq([:started])
      expect(session.to_h[:policy_context]).to eq({corruption_handling: :warn})
      expect(session.to_h[:operations].first[:delegate_name]).to eq("markdown-runtime")
    end

    it "builds a consumable session summary" do
      root_surface = Ast::Merge::Runtime::Surface.new(
        surface_kind: :markdown_document,
        effective_language: :markdown,
        address: "document[0]",
      )
      child_surface = Ast::Merge::Runtime::Surface.new(
        surface_kind: :markdown_fenced_code_block,
        declared_language: :ruby,
        effective_language: :ruby,
        address: "document[0] > fence[lang=ruby,index=0]",
        parent_address: "document[0]",
      )
      root_operation = Ast::Merge::Runtime::Operation.new(
        operation_id: "root-op",
        surface: root_surface,
        template_fragment: "template",
        destination_fragment: "destination",
      )
      child_operation = Ast::Merge::Runtime::Operation.new(
        operation_id: "child-op",
        surface: child_surface,
        template_fragment: "puts :template\n",
        destination_fragment: "puts :dest\n",
      )
      started = Ast::Merge::Runtime::Diagnostic.new(
        severity: :info,
        kind: :started,
        operation_id: "root-op",
        surface_path: root_surface.address,
        message: "Started merge",
      )
      unsupported = Ast::Merge::Runtime::Diagnostic.new(
        severity: :warn,
        kind: :unsupported_capability,
        operation_id: "child-op",
        surface_path: child_surface.address,
        message: "Missing capability",
      )
      root_operation.add_diagnostic(started)
      child_operation.add_diagnostic(unsupported)
      root_operation.complete!(
        result: Ast::Merge::Runtime::ChildResult.new(
          replacement_text: "destination",
          capabilities_used: [:source_spans],
        ),
      )
      child_operation.complete!(
        result: Ast::Merge::Runtime::ChildResult.new(
          replacement_text: "puts :dest\n",
          capabilities_used: %i[nested_surfaces source_spans],
          capabilities_missing: [:reintegrate_into_parent],
        ),
      )
      markdown_delegate = Ast::Merge::Runtime::Delegate.new(
        name: "markdown-runtime",
        priority: 10,
        surface_kinds: [:markdown_document],
        languages: [:markdown],
        capabilities: {merge: true},
      )
      ruby_delegate = Ast::Merge::Runtime::Delegate.new(
        name: "ruby-runtime",
        priority: 10,
        surface_kinds: [:markdown_fenced_code_block],
        languages: [:ruby],
        capabilities: {merge: true},
      )
      session = described_class.new(
        delegation_registry: Ast::Merge::Runtime::DelegationRegistry.new(
          delegates: [markdown_delegate, ruby_delegate],
        ),
      )

      session.register(
        root_operation,
        frame: Ast::Merge::Runtime::Frame.new(
          operation_id: "root-op",
          depth: 0,
          surface_path: "document[0]",
          language_chain: %i[markdown],
        ),
        delegate: markdown_delegate,
      )
      session.register(
        child_operation,
        frame: Ast::Merge::Runtime::Frame.new(
          parent_operation_id: "root-op",
          operation_id: "child-op",
          depth: 1,
          surface_path: "document[0] > fence[lang=ruby,index=0]",
          language_chain: %i[markdown ruby],
        ),
        delegate: ruby_delegate,
      )

      expect(session.summary).to eq(
        operation_count: 2,
        root_operation_count: 1,
        status_counts: {completed: 2},
        diagnostic_count: 2,
        diagnostic_severity_counts: {info: 1, warn: 1},
        delegate_names: %w[markdown-runtime ruby-runtime],
        surface_kinds: %i[markdown_document markdown_fenced_code_block],
        effective_languages: %i[markdown ruby],
        capabilities_used: %i[nested_surfaces source_spans],
        capabilities_missing: [:reintegrate_into_parent],
      )
      expect(session.to_h[:summary]).to eq(session.summary)
    end
  end
end
