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
        formula = Formulary.resolve(formula_name)

        puts "Sourcing the shell functions from '#{formula}' in your #{shell_profile}..."

        files_to_source = formula.shell.sourceable_files

        if files_to_source.empty?
            puts "...this formula does not contain shell functions, so no action was taken."
            return
        end

        shell_profile_path = File.expand_path(shell_profile)

        converger = Source::ShellProfileConverger.new shell_profile_path
        converger.ensure_source_directives_for *files_to_source

        puts "...done."
    end
end
