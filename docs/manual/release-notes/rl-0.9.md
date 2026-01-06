# Release 0.9 {#sec-release-0-9}

## Changelog {#sec-release-0-9-changelog}

## Breaking changes

- Nixpkgs merged a full and incompatible rewrite of vimPlugins.nvim-treesitter.
  The changes affected how grammars are built and it caused issues when neovim
  attempted to load languages and could not find files in expected locations.

## Changelog {#sec-release-0-9-changelog}

[suimong](https://github.com/suimong):

- Fix `vim.tabline.nvimBufferline` where `setupOpts.options.hover` requires
  `vim.opt.mousemoveevent` to be set.

[thamenato](https://github.com/thamenato):

- Attempt to adapt nvim-treesitter to (breaking) Nixpkgs changes. Some treesitte grammars
  were changed to prefer `grammarPlugins` over `builtGrammars`.

[jfeo](https://github.com/jfeo):

[ccc.nvim]: https://github.com/uga-rosa/ccc.nvim

- Added [ccc.nvim] option {option}`vim.utility.ccc.setupOpts` with the existing
  hard-coded options as default values.

[Ring-A-Ding-Ding-Baby](https://github.com/Ring-A-Ding-Ding-Baby):


- Aligned `codelldb` adapter setup with [rustaceanvim]’s built-in logic.
- Added `languages.rust.dap.backend` option to choose between `codelldb` and
  `lldb-dap` adapters.

[Libadoxon](https://github.com/Libadoxon):

- `toggleterm` open map now also works when in terminal mode


