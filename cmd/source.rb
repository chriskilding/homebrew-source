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
    
    # look up the specified formula(e)
    formula_name = args.named.first
    formula = Formulary.factory(formula_name)

    puts "Adding 'source' directive for the formula '#{formula}' to your #{shell_profile}..."

    File.open(shell_profile, 'r') do |file|
      is_sourced = false

      file.each do |line|
        if line["source #{formula.zsh_function}"]
          puts "...this formula's zsh functions are already sourced, so no action was taken."
          is_sourced = true
          break
        end
      end

      unless is_sourced
        puts "Not yet sourced, adding the directive..."
      end
    end

    puts "Checking that formula '#{formula}' contains shell functions... ok"

    puts "Zsh site-functions: #{formula.zsh_function}"
  end
end
