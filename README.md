# `brew source <formula>`

Automatic management of `source <formula>.sh` directives for shell function formulae.

## Installation

```
brew tap chriskilding/source
```

## Usage

Say you have a Brew formula `<foo>` that installs shell functions to `/usr/local/share/zsh/site-functions/<foo>`. You want to install it, and ensure its functions are `source`d in your shell profile.

To install and source the formula, you need simply run:

```
$ brew install <foo>
```

```
$ brew source <foo>
Sourcing the shell functions from '<foo>' in your ~/.zshrc...
...done.
```

And Brew will take care of adding the `source` directive to your shell profile automatically.

If you've already `source`d the functions, Brew won't touch your configuration:

```
$ brew source <foo>
Sourcing the shell functions from '<foo>' in your ~/.zshrc...
...this formula's shell functions are already sourced, so no action was taken.
```

### Without `brew source`

Without this Brew extension, you'd have to read the caveats section after installing the formula. The caveats might tell you to add a `source` directive to your shell profile by hand:

```bash
source /usr/local/share/zsh/site-functions/<foo>
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
