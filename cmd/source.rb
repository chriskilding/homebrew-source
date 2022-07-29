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

    # TODO read from the formula
    files_to_source = [
      "/usr/local/share/zsh/site-functions/#{formula.name}",
      "/usr/local/share/zsh/site-functions/#{formula.name}-foo"
    ]

    if files_to_source.empty?
      puts "...this formula does not contain shell functions, so no action was taken."
      return
    end

    shell_profile_path = File.expand_path(shell_profile)

    File.open(shell_profile_path, 'r') do |file|
      file.each do |line|
        # TODO make this logic more robust
        files_to_source.each do |file_to_source|
          if line["source #{file_to_source}"]
            files_to_source.delete file_to_source
          end
        end
      end
    end

    if files_to_source.empty?
      puts "...this formula's shell functions are already sourced, so no action was taken."
      return
    end

    File.open(shell_profile_path, 'a') do |file|
      files_to_source.each do |file_to_source|
        file.write("\nsource #{file_to_source}")
      end

      puts "...done."
    end
  end
end
