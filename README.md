# `brew source <formula>`

Automatic management of `source <formula>` or `. <formula>` directives for shell function formulae.

## Installation

```
brew tap chriskilding/source
```

## Usage

Say you have a Brew formula `<foo>` that installs sourceable shell functions:

```ruby
class Foo < Formula
    desc "An example formula"

    def install
        libexec.install "foo"
        zsh_function.install "bar"
        fish_function.install "baz"
    end

    shell do
        source libexec("foo")
    end

    test do
        system "foo", "-h"
    end
end
```

To install the formula, and ensure its functions are `source`d in your shell profile, you need simply run:

```
$ brew install <foo>
```

```
$ brew source <foo>
Sourcing the shell functions from '<foo>' in your ~/.zshrc...
...done.
```

And Brew will take care of adding the `source` directive(s) to your shell profile automatically.

If you've already `source`d the functions, Brew won't touch your configuration.

### Without `brew source`

Without this Brew extension, you'd have to read the caveats section after installing the formula. The caveats might tell you to add a `source` directive to your shell profile by hand:

```bash
. /usr/local/share/zsh/site-functions/<foo>
```

And if the formula author forgot to note this in the caveats, you'd have to guess the steps that you needed to take.

## Development

To work on `brew source` itself, follow these instructions.

Setup:

```bash
bundle install
```

Run tests:

```bash
bundle exec rspec
```

## Brew extras

These are the DSL extensions we will need to add to Homebrew (work in progress).

Create `shell_.rb` (this is to get round the fact that Ruby core has a module called `shell`):

```ruby
# typed: true
# frozen_string_literal: true

module Homebrew

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
            @files_to_source = []
        end

        sig { params(path: T.any(String, Pathname)).returns(T.nilable(Array)) }
        def source(path)
            case T.unsafe(path)
            when nil
                @files_to_source
            when String, Pathname
                @files_to_source.append path
            else
                raise TypeError, "Shell#source expects a String"
            end
        end

        def sourceable_files
            instance_eval(&@shell_block)

            @files_to_source
        end
    end
end
```

Append to `formula.rb`:

```ruby
require "shell_"




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
```

Append to `formula.rbi`:

```ruby
def shell?; end
```