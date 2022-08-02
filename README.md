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
