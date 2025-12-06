# frozen_string_literal: true

# This gem
require_relative "merge/version"

module Ast
  module Merge
    class Error < StandardError; end
    # Your code goes here...
  end
end

Ast::Merge::Version.class_eval do
  extend VersionGem::Basic
end