# Release 0.8 {#sec-release-0.8}

[NotAShelf](https://github.com/notashelf):

[typst-preview.nvim]: https://github.com/chomosuke/typst-preview.nvim
[render-markdown.nvim]: https://github.com/MeanderingProgrammer/render-markdown.nvim
[yanky.nvim]: https://github.com/gbprod/yanky.nvim

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

- Hardcoded indentation values for the Nix language module have been removed. To
  replicate previous behaviour, you must either consolidate Nix indentation in
  your Editorconfig configuration, or use an autocommand to set indentation
  values for buffers with the Nix filetype.

- Add [](#opt-vim.lsp.lightbulb.autocmd.enable) for manually managing the
  previously managed lightbulb autocommand.

  - A warning will occur if [](#opt-vim.lsp.lightbulb.autocmd.enable) and
    `vim.lsp.lightbulb.setupOpts.autocmd.enabled` are both set at the same time.
    Pick only one.

- Add [yanky.nvim] to available plugins, under `vim.utility.yanky-nvim`.

[amadaluzia](https://github.com/amadaluzia):

[haskell-tools.nvim]: https://github.com/MrcJkb/haskell-tools.nvim

- Add Haskell support under `vim.languages.haskell` using [haskell-tools.nvim].

[horriblename](https://github.com/horriblename):

[blink.cmp]: https://github.com/saghen/blink.cmp

- Add [blink.cmp] support

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
- Add the following plugins from
  [mini.nvim](https://github.com/echasnovski/mini.nvim)
  - `mini.ai`
  - `mini.align`
  - `mini.animate`
  - `mini.base16`
  - `mini.basics`
  - `mini.bracketed`
  - `mini.bufremove`
  - `mini.clue`
  - `mini.colors`
  - `mini.comment`
  - `mini.completion`
  - `mini.deps`
  - `mini.diff`
  - `mini.doc`
  - `mini.extra`
  - `mini.files`
  - `mini.fuzzy`
  - `mini.git`
  - `mini.hipatterns`
  - `mini.hues`
  - `mini.icons`
  - `mini.indentscope`
  - `mini.jump`
  - `mini.jump2d`
  - `mini.map`
  - `mini.misc`
  - `mini.move`
  - `mini.notify`
  - `mini.operators`
  - `mini.pairs`
  - `mini.pick`
  - `mini.sessions`
  - `mini.snippets`
  - `mini.splitjoin`
  - `mini.starter`
  - `mini.statusline`
  - `mini.surround`
  - `mini.tabline`
  - `mini.test`
  - `mini.trailspace`
  - `mini.visits`
- Add [fzf-lua](https://github.com/ibhagwan/fzf-lua) in `vim.fzf-lua`
- Add [rainbow-delimiters](https://github.com/HiPhish/rainbow-delimiters.nvim)
  in `vim.visuals.rainbow-delimiters`
- Add options to define highlights under [](#opt-vim.highlight)

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

[ARCIII](https://github.com/ArmandoCIII):

- Add `vim.languages.zig.dap` support through pkgs.lldb dap adapter. Code
  Inspiration from `vim.languages.clang.dap` implementation.

[nezia1](https://github.com/nezia1)

- Add support for [nixd](https://github.com/nix-community/nixd) language server.

[folospior](https://github.com/folospior)

- Fix plugin name for lsp/lspkind.
[iynaix](https://github.com/iynaix)

- Add lsp options support for [nixd](https://github.com/nix-community/nixd)
  language server.
