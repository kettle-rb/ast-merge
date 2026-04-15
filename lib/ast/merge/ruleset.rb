# frozen_string_literal: true

module Ast
  module Merge
    # Namespace for compact merge-ruleset parsing and validation.
    module Ruleset
      autoload :Config, "ast/merge/ruleset/config"
      autoload :FeatureProfile, "ast/merge/ruleset/feature_profile"
      autoload :Parser, "ast/merge/ruleset/parser"
      autoload :SupportStyleResolver, "ast/merge/ruleset/support_style_resolver"
    end
  end
end
