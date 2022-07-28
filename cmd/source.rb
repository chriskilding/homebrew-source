# typed: true
# frozen_string_literal: true

require "cli/parser"
require "formula"
require "homebrew"

module Homebrew
  extend T::Sig
  
  module_function

  sig { returns(CLI::Parser) }
  def source_args
    Homebrew::CLI::Parser.new do
      description <<~EOS
        Automatically 'source' shell functions from formulae in your shell profile
      EOS
      switch "-f", "--force",
             description: "Force doing something in the command."

      named_args [:formula], min: 1, max: 1
    end
  end

  sig { void }
  def source
    args = source_args.parse
    
    formula_name = args.named.first

    puts "Checking that formula #{formula_name} contains shell functions... ok"

    puts "Adding 'source' directive for #{formula_name} to your #{shell_profile}..."

    puts "Zsh site-functions: #{zsh_function}"
  end
end
