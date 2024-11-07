# NodeJS {#ch-quirks-nodejs}

## eslint-plugin-prettier {#sec-eslint-plugin-prettier}

When working with NodeJS, everything works as expected, but some projects have
settings that can fool nvf.

If [this plugin](https://github.com/prettier/eslint-plugin-prettier) or similar
is included, you might get a situation where your eslint configuration diagnoses
your formatting according to its own config (usually `.eslintrc.js`).

The issue there is your formatting is made via prettierd.

This results in auto-formating relying on your prettier config, while your
eslint config diagnoses formatting
[which it's not supposed to](https://prettier.io/docs/en/comparison.html))

In the end, you get discrepancies between what your editor does and what it
wants.

Solutions are:

1. Don't add a formatting config to eslint, and separate prettier and eslint.
2. PR this repo to add an ESLint formatter and configure nvf to use it.
