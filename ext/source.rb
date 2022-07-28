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
      flag   "--file=",
             description: "Specify a file to do something with in the command."
      comma_array "--names",
                  description: "Add a list of names to the command."

      named_args [:formula, :cask], min: 1
    end
  end

  def source
    args = source_args.parse

    something if args.force?
    something_else if args.file == "file.txt"
  end
end
