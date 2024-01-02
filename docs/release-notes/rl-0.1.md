# Release 0.1 {#sec-release-0.1}

This is the current master branch and information here is not final. These are changes from the v0.01 tag.

Special thanks to [home-manager](https://github.com/nix-community/home-manager/) for this release.
Docs/manual generation, the new module evaluation system, and DAG implementation are from them.

## Changelog {#sec-release-0.1-changelog}

[jordanisaacs](https://github.com/jordanisaacs):

- Removed hare language support (lsp/tree-sitter/etc). `vim.lsp.hare` is no longer defined.
  If you use hare and would like it added back, please file an issue.

- [vim.stratPlugins](opt-vim.startPlugins) & [vim.optPlugins](opt-vim.optPlugins) are now
  an enum of `string` for options sourced from the flake inputs. Users can still provide vim
  plugin packages.

  - If you are contributing and adding a new plugin, add the plugin name to `availablePlugins` in
    [types-plugin.nix](https://github.com/jordanisaacs/neovim-flake/blob/20cec032bd74bc3d20ac17ce36cd84786a04fd3e/modules/lib/types-plugin.nix).

- `neovimBuilder` has been removed for configuration. Using an overlay is no longer required.
  See the manual for the new way to configuration.

- Treesitter grammars are now configurable with [vim.treesitter.grammars](opt-vim.treesitter.grammars).
  Utilizes the nixpkgs `nvim-treesitter` plugin rather than a custom input in order to take advantage of build support of pinned versions.
  See [relevant discourse post](https://discourse.nixos.org/t/psa-if-you-are-on-unstable-try-out-nvim-treesitter-withallgrammars/23321?u=snowytrees)
  for more information. Packages can be found under the `vimPlugins.nvim-treesitter.builtGrammars` namespace.

- [vim.configRC](opt-vim.configRC) and [vim.luaConfigRC](opt-vim.luaConfigRC) are now of type DAG lines.
  This allows for ordering of the config. Usage is the same is in home-manager's `home.activation` option.

```nix
vim.luaConfigRC = lib.nvim.dag.entryAnywhere "config here"
```

[MoritzBoehme](https://github.com/MoritzBoehme):

- `catppuccin` theme is now available as a neovim theme [vim.theme.style](opt-vim.theme.style) and lualine theme
  [vim.statusline.lualine.theme](opt-vim.statusline.lualine.theme).
