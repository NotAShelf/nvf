# Known Issues and Quirks {#ch-known-issues-quirks}

At times, certain plugins and modules may refuse to play nicely with your setup,
be it a result of generating Lua from Nix, or the state of packaging. This page,
in turn, will list any known modules or plugins that are known to misbehave, and
possible workarounds that you may apply.

## NodeJS {#ch-quirks-nodejs}

### eslint-plugin-prettier {#sec-eslint-plugin-prettier}

When working with NodeJS, everything works as expected, but some projects have
settings that can fool nvf.

If [this plugin](https://github.com/prettier/eslint-plugin-prettier) or similar
is included, you might get a situation where your eslint configuration diagnoses
your formatting according to its own config (usually `.eslintrc.js`).

The issue there is your formatting is made via prettierd.

This results in auto-formatting relying on your prettier config, while your
eslint config diagnoses formatting
[which it's not supposed to](https://prettier.io/docs/en/comparison.html))

In the end, you get discrepancies between what your editor does and what it
wants.

Solutions are:

1. Don't add a formatting config to eslint, and separate prettier and eslint.
2. PR this repo to add an ESLint formatter and configure nvf to use it.

## Bugs & Suggestions {#ch-bugs-suggestions}

[issue tracker]: https://github.com/notashelf/nvf/issues
[discussions tab]: https://github.com/notashelf/nvf/discussions
[pull requests tab]: https://github.com/notashelf/nvf/pulls

Some quirks are not exactly quirks, but bugs in the module systeme. If you
notice any issues with nvf, or this documentation, then please consider
reporting them over at the [issue tracker]. Issues tab, in addition to the
[discussions tab] is a good place as any to request new features.

You may also consider submitting bugfixes, feature additions and upstreamed
changes that you think are critical over at the [pull requests tab].
