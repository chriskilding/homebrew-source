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

            named_args [:formula], min: 1, max: 1
        end
    end

    sig { void }
    def source
        args = source_args.parse
        
        # Keep this after the .parse to keep --help fast.
        require_relative "../lib/source"

        formula_name = args.named.first
        formula = Formulary.factory(formula_name)

        puts "Sourcing the shell functions from '#{formula}' in your #{shell_profile}..."

        # FIXME read from the formula
        files_to_source = [
            "/usr/local/share/zsh/site-functions/#{formula.name}",
            "/usr/local/share/zsh/site-functions/#{formula.name}-foo"
        ]

        if files_to_source.empty?
            puts "...this formula does not contain shell functions, so no action was taken."
            return
        end

        shell_profile_path = File.expand_path(shell_profile)
        missing_directives = []
        File.open(shell_profile_path, 'r') do |file|
            missing_directives = Source::ShellProfile.missing_source_directives(file, files_to_source)
        end

        if missing_directives.empty?
            puts "...this formula's shell functions are already sourced, so no action was taken."
            return
        end

        File.open(shell_profile_path, 'a') do |file|
            missing_directives.each do |file_to_source|
                file.write("source #{file_to_source}\n")
            end
        end
        
        puts "...done."
    end
end
