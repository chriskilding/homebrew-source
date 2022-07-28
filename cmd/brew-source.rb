# frozen_string_literal: true

module Homebrew
  module_function

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

  def source
    args = source_args.parse

    puts 'hello'
    
    something if args.force?
  end
end
