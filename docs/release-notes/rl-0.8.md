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

[amadaluzia](https://github.com/amadaluzia):

[haskell-tools.nvim]: https://github.com/MrcJkb/haskell-tools.nvim

- Add Haskell support under `vim.languages.haskell` using [haskell-tools.nvim].

[diniamo](https://github.com/diniamo):

- Add Odin support under `vim.languages.odin`.

- Disable the built-in format-on-save feature of zls. Use `vim.lsp.formatOnSave`
  instead.

[horriblename](https://github.com/horriblename):

[aerial.nvim](https://github.com/stevearc/aerial.nvim)
[nvim-ufo](https://github.com/kevinhwang91/nvim-ufo)

- Add [aerial.nvim]
- Add [nvim-ufo]

[LilleAila](https://github.com/LilleAila):

- Remove `vim.notes.obsidian.setupOpts.dir`, which was set by default. 
  Fixes issue with setting the workspace directory.
