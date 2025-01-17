# Release 0.8 {#sec-release-0.8}

[NotAShelf](https://github.com/notashelf):

[typst-preview.nvim]: https://github.com/chomosuke/typst-preview.nvim
[render-markdown.nvim]: https://github.com/MeanderingProgrammer/render-markdown.nvim

- Add [typst-preview.nvim] under
  `languages.typst.extensions.typst-preview-nvim`.

- Add a search widget to the options page in the nvf manual.

- Add [render-markdown.nvim] under
  `languages.markdown.extensions.render-markdown-nvim`

- Implement [](#opt-vim.git.gitsigns.setupOpts) for user-specified setup table
  in gitsigns configuration.

- [](#opt-vim.options.mouse) no longer compares values to an enum of available
  mouse modes. This means you can provide any string without the module system
  warning you that it is invalid. Do keep in mind that this value is no longer
  checked, so you will be responsible for ensuring its validity.

- Deprecate `vim.enableEditorconfig` in favor of
  [](#opt-vim.globals.editorconfig).

- Deprecate rnix-lsp as it has been abandoned and archived upstream.

[amadaluzia](https://github.com/amadaluzia):

[haskell-tools.nvim]: https://github.com/MrcJkb/haskell-tools.nvim

- Add Haskell support under `vim.languages.haskell` using [haskell-tools.nvim].

[diniamo](https://github.com/diniamo):

- Add Odin support under `vim.languages.odin`.

- Disable the built-in format-on-save feature of zls. Use `vim.lsp.formatOnSave`
  instead.

[horriblename](https://github.com/horriblename):

[aerial.nvim]: (https://github.com/stevearc/aerial.nvim)
[nvim-ufo]: (https://github.com/kevinhwang91/nvim-ufo)

- Add [aerial.nvim]
- Add [nvim-ufo]

[LilleAila](https://github.com/LilleAila):

- Remove `vim.notes.obsidian.setupOpts.dir`, which was set by default. Fixes
  issue with setting the workspace directory.
- Add `vim.snippets.luasnip.setupOpts`, which was previously missing.
- Add `"prettierd"` as a formatter option in
  `vim.languages.markdown.format.type`.

[kaktu5](https://github.com/kaktu5):

- Add WGSL support under `vim.languages.wgsl`.

[tomasguinzburg](https://github.com/tomasguinzburg):

[solargraph]: https://github.com/castwide/solargraph
[gbprod/nord.nvim]: https://github.com/gbprod/nord.nvim

- Add Ruby support under `vim.languages.ruby` using [solargraph].
- Add `nord` theme from [gbprod/nord.nvim].

[thamenato](https://github.com/thamenato):

[ruff]: (https://github.com/astral-sh/ruff)

- Add [ruff] as a formatter option in `vim.languages.python.format.type`.
