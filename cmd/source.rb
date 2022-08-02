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

        puts "files to source: #{files_to_source}"
        if files_to_source.empty?
            puts "...this formula does not contain shell functions, so no action was taken."
            return
        end

        shell_profile_path = File.expand_path(shell_profile)

        converger = Source::ShellProfileConverger.new shell_profile_path
        converger.ensure_source_directives_for *files_to_source

        puts "...done."
    end

    # The {Shell} class implements the DSL methods used in a formula's
    # `shell` block and stores related instance variables. Most of these methods
    # also return the related instance variable when no argument is provided.
    class Shell
        extend T::Sig
        extend Forwardable

        # sig { params(formula: Formula).void }
        def initialize(formula, &block)
            @formula = formula
            @shell_block = block
            @sourceable_files = []
        end

        sig { params(path: T.any(String, Pathname)).returns(T.nilable(Array)) }
        def source(path)
            case T.unsafe(path)
            when nil
                @sourceable_files
            when String, Pathname
                @sourceable_files.append path
            else
                raise TypeError, "Shell#source expects a String"
            end
        end
    end
end

# Patch the API we'd like to have onto Formula
class Formula
    
    # @!attribute [w] shell
    # Shell can be used to define shell profile settings.
    # This method evaluates the DSL specified in the shell block of the
    # {Formula} (if it exists) and sets the instance variables of a Shell
    # object accordingly. This is used by `brew source` to generate shell profile settings.
    #
    # <pre>shell do
    #   source libexec("foo")
    # end</pre>
    def shell(&block)
        return @shell_block unless block

        @shell_block = block
    end

    # Is a shell specification defined for the software?
    # @!method shell?
    # @see .shell?
    delegate shell?: :"self.class"

    # The shell specification of the software.
    def shell
        return unless shell?

        Homebrew::Shell.new(self, &self.class.shell)
    end

    # Whether a shell specification is defined or not.
    # It returns true when a shell block is present in the {Formula} and
    # false otherwise, and is used by shell.
    def shell?
        @shell_block.present?
    end
end