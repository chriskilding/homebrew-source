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

      # TODO support multiple formulae in one go
      named_args [:formula], min: 1, max: 1
    end
  end

  sig { void }
  def source
    args = source_args.parse
    
    formula_name = args.named.first
    formula = Formulary.factory(formula_name)

    puts "Sourcing the shell functions from '#{formula}' in your #{shell_profile}..."

    # TODO get this from the formula definition
    file_to_source = "#{formula.zsh_function}/#{formula}"

    unless file_to_source
      puts "...this formula does not contain shell functions, so no action was taken."
      return
    end

    shell_profile_path = File.expand_path(shell_profile)

    is_sourced = false

    File.open(shell_profile_path, 'r') do |file|
      file.each do |line|
        # TODO make this logic more robust
        if line["source #{file_to_source}"]
          is_sourced = true
          break
        end
      end
    end

    if is_sourced
      puts "...this formula's shell functions are already sourced, so no action was taken."
      return
    end

    File.open(shell_profile_path, 'a') do |file|
      file.write("source #{file_to_source}\n")
      puts "...done."
    end
  end
end
