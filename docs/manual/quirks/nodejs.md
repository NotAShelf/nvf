## NodeJS {#ch-quirks-nodejs}

### eslint-plugin-prettier {#sec-eslint-plugin-prettier}

[eslint-plugin-prettier]: https://github.com/prettier/eslint-plugin-prettier
[not supposed to]: https://prettier.io/docs/en/comparison.html

When working with NodeJS, which is _obviously_ known for its meticulous
standards, most things are bound to work as expected but some projects, tools
and settings may fool the default configurations of tools provided by **nvf**.

If

If [eslint-plugin-prettier] or similar is included, you might get a situation
where your Eslint configuration diagnoses your formatting according to its own
config (usually `.eslintrc.js`). The issue there is your formatting is made via
prettierd.

This results in auto-formatting relying on your prettier configuration, while
your Eslint configuration diagnoses formatting "issues" while it's
[not supposed to]. In the end, you get discrepancies between what your editor
does and what it wants.

Solutions are:

1. Don't add a formatting config to Eslint, instead separate Prettier and
   Eslint.
2. PR the repo in question to add an ESLint formatter, and configure **nvf** to
   use it.
