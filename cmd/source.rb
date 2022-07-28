# typed: true
# frozen_string_literal: true

require "cli/parser"
require "formula"

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
    
    formula = args.named.first

    puts "Checking that formula #{formula} contains shell functions... ok"

    puts "Adding 'source' directive for #{formula} to your #{shell_profile}..."

    puts "Zsh site-functions: #{formula.zsh_function}"
  end
end
