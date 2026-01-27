# Release 0.1 {#sec-release-0-1}

This is the current master branch and information here is not final. These are
changes from the v0.1 tag.

Special thanks to [home-manager](https://github.com/nix-community/home-manager/)
for this release. Docs/manual generation, the new module evaluation system, and
DAG implementation are from them.

## Changelog {#sec-release-0-1-changelog}

[jordanisaacs](https://github.com/jordanisaacs):

- Removed hare language support (lsp/tree-sitter/etc). `vim.lsp.hare` is no
  longer defined. If you use hare and would like it added back, please file an
  issue.

- {option}`vim.startPlugins` & {option} `vim-optPlugins` are now an enum of
  `string` for options sourced from the flake inputs. Users can still provide
  vim plugin packages.

  - If you are contributing and adding a new plugin, add the plugin name to
    `availablePlugins` in [types-plugin.nix].

- `neovimBuilder` has been removed for configuration. Using an overlay is no
  longer required. See the manual for the new way to configuration.

[relevant discourse post]: https://discourse.nixos.org/t/psa-if-you-are-on-unstable-try-out-nvim-treesitter-withallgrammars/23321?u=snowytrees

- Treesitter grammars are now configurable with
  {option}`vim.treesitter.grammars`. Utilizes the nixpkgs `nvim-treesitter`
  plugin rather than a custom input in order to take advantage of build support
  of pinned versions. See the [relevant discourse post] for more information.
  Packages can be found under the `vimPlugins.nvim-treesitter.builtGrammars`
  namespace.

- `vim.configRC` and {option}`vim.luaConfigRC` are now of type DAG lines. This
  allows for ordering of the config. Usage is the same is in home-manager's
  `home.activation` option.

```nix
vim.luaConfigRC = lib.nvim.dag.entryAnywhere "config here"
```

[MoritzBoehme](https://github.com/MoritzBoehme):

- `catppuccin` theme is now available as a neovim theme
  {option}`vim.theme.style` and Lualine theme
  {option}`vim.statusline.lualine.theme`.
