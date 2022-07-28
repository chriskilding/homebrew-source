# `brew source <formula>`

Automatic management of `source <formula>.sh` directives for shell function formulae.

## Example

You have a Brew formula `<foo>` that installs a shell function script to:

```
/usr/local/share/zsh/site-functions/<foo>
```

### Without `brew source`

Without this Brew extension, you'd have to read the caveats section after installing the formula. The caveats might tell you to add a `source` directive to your shell profile by hand:

```bash
source /usr/local/share/zsh/site-functions/<foo>
```

And if formula author forgot to note this in the caveats, you'd have to rely on guesswork.

### With `brew source`

Now to install and link a formula with shell functions, you need simply run:

```bash
brew install <foo>
brew source <foo>
```

And Brew will take care of adding the `source` directive to your shell profile automatically.
