# typed: true
# frozen_string_literal: true

require "cli/parser"
require "formula"

module Homebrew
    extend T::Sig

    # Patch what we want onto the brew Formula API
    class Formula
        def foo
            "abc"
        end
    end

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

        puts "interactive shell: #{interactive_shell}"
        puts "preferred shell: #{preferred_shell}"

        puts formula.path
        puts formula.methods

        puts "Sourcing the shell functions from '#{formula}' in your #{shell_profile}..."

        # FIXME read from the formula
        something = formula.foo
        files_to_source = [
            "/usr/local/share/zsh/site-functions/#{formula.name}",
            "/usr/local/share/zsh/site-functions/#{formula.name}-foo"
        ]

        if files_to_source.empty?
            puts "...this formula does not contain shell functions, so no action was taken."
            return
        end

        shell_profile_path = File.expand_path(shell_profile)

        unsourced_files = []

        File.open(shell_profile_path, 'r') do |file|
            rc = Source::ShellProfile.new(file)
            unsourced_files = rc.unsourced_files(*files_to_source)
        end

        if unsourced_files.empty?
            puts "...this formula's shell functions are already sourced, so no action was taken."
            return
        end

        File.open(shell_profile_path, 'a') do |file|
            unsourced_files.each do |file_to_source|
                file.write(". #{file_to_source}\n")
            end
        end

        puts "...done."
    end
end
