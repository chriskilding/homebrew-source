# frozen_string_literal: true

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
    puts 'hello'
    
    args = source_args.parse
    
    something if args.force?
  end
end
