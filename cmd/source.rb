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

    puts "Sourcing the shell functions from '#{formula}' in your #{shell_profile}..."

    # TODO get this from the formula definition
    file_to_source = "#{formula.zsh_function}/#{formula}"

    unless file_to_source
      puts "...this formula does not contain shell functions, so no action is required."
      return
    end

    shell_profile_path = File.expand_path(shell_profile)

    is_sourced = false

    File.open(shell_profile_path, 'r') do |file|
      file.each do |line|
        if line["source #{file_to_source}"]
          puts "...this formula's shell functions are already sourced, so no action was taken."
          is_sourced = true
          break
        end
      end
    end

    unless is_sourced
      File.open(shell_profile_path, 'a') do |file|
        file.write("source #{file_to_source}")
        puts "...done."
      end
    end
  end
end
