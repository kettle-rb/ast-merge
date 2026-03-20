# frozen_string_literal: true

module Ast
  module Merge
    # Shared structural editing primitives for replace/remove/rehome workflows.
    #
    # `Ast::Merge::StructuralEdit` is intentionally passive: it models edit
    # boundaries and splice plans without taking ownership of parser-specific
    # traversal or post-processing behavior.
    module StructuralEdit
      autoload :Boundary, "ast/merge/structural_edit/boundary"
      autoload :SplicePlan, "ast/merge/structural_edit/splice_plan"
    end
  end
end
