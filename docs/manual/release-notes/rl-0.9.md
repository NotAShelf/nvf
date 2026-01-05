# Release 0.9 {#sec-release-0-9}

## Breaking changes

- Nixpkgs merged a full and incompatible rewrite of vimPlugins.nvim-treesitter.
  The changes affected how grammars are built and it caused issues when neovim
  attempted to load languages and could not find files in expected locations.

## Changelog {#sec-release-0-9-changelog}

[suimong](https://github.com/suimong):

- Fix `vim.tabline.nvimBufferline` where `setupOpts.options.hover` requires
  `vim.opt.mousemoveevent` to be set.

[thamenato](https://github.com/thamenato):

- Attempt to adapt nvim-treesitter to (breaking) Nixpkgs changes
