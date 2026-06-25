# Language Support {#ch-languages}

Language specific support means there is a combination of language specific
plugins, `treesitter` support, `nvim-lspconfig` language servers, `conform-nvim`
formatters, and `nvim-lint` linter integration. This gets you capabilities
ranging from autocompletion to formatting to diagnostics. The following
languages have sections under the `vim.languages` attribute.

@NVF_LANGUAGES_ENABLE@

Adding support for more languages, and improving support for existing ones are
great places where you can contribute with a PR.

```{=include=} sections
languages/lsp.md
```
