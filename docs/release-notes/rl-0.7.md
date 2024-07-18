# Release 0.7 {#sec-release-0.7}

Release notes for release 0.7

## Breaking Changes and Migration Guide {#sec-breaking-changes-and-migration-guide-0-7}

In v0.7 we are removing `vim.configRC` in favor of making `vim.luaConfigRC` the top-level DAG, and thereby making the entire configuration lua based.

_Why?_ because Neovim is supposed to be mainly lua based. Also, vimscript is slow.

This comes with a few breaking changes:
- `vim.configRC` has been removed, which means that you have to convert all of your custom vimscript-based configuration to lua. As for how to do that, you will have to consult the Neovim documentation and your search engine.
- After doing that, you might not be able to use the same entry names in `vim.luaConfigRC`, because those have also slightly changed. See the new [DAG entries in nvf](/index.xhtml#ch-dag-entries) manual page for more details.

## Changelog {#sec-release-0.7-changelog}

[ItsSorae](https://github.com/ItsSorae):

- Add support for [typst](https://typst.app/) under `vim.languages.typst` This
  will enable the `typst-lsp` language server, and the `typstfmt` formatter

[frothymarrow](https://github.com/frothymarrow):

- Modified type for
  [vim.visuals.fidget-nvim.setupOpts.progress.display.overrides](#opt-vim.visuals.fidget-nvim.setupOpts.progress.display.overrides)
  from `anything` to a `submodule` for better type checking.

- Fix null `vim.lsp.mappings` generating an error and not being filtered out.

- Add basic transparency support for `oxocarbon` theme by setting the highlight
  group for `Normal`, `NormalFloat`, `LineNr`, `SignColumn` and optionally
  `NvimTreeNormal` to `none`.

- Fix
  [vim.ui.smartcolumn.setupOpts.custom_colorcolumn](#opt-vim.ui.smartcolumn.setupOpts.custom_colorcolumn)
  using the wrong type `int` instead of the expected type `string`.

- Fix unused src and version attributes in `buildPlug`.

[horriblename](https://github.com/horriblename):

- Fix broken treesitter-context keybinds in visual mode
- Deprecate use of `__empty` to define empty tables in lua. Empty attrset are no
  longer filtered and thus should be used instead.
- Add dap-go for better dap configurations
- Make noice.nvim customizable
- Switch from [rust-tools.nvim](https://github.com/simrat39/rust-tools.nvim)
  to the more feature-packed [rustacean.nvim](https://github.com/mrcjkb/rustaceanvim.
  This switch entails a whole bunch of new features and options, so you are
  recommended to go through rustacean.nvim's README to take a closer look at
  its features and usage.

[jacekpoz](https://github.com/jacekpoz):

- Add [ocaml-lsp](https://github.com/ocaml/ocaml-lsp) support.

- Fix Emac typo

[diniamo](https://github.com/diniamo):

- Move the `theme` dag entry to before `luaScript`.

- Add rustfmt as the default formatter for Rust.

- Enabled the terminal integration of catppuccin for theming Neovim's built-in
  terminal (this also affects toggleterm).

- Migrate bufferline to setupOpts for more customizability

- Use `clangd` as the default language server for C languages

- Expose `lib.nvim.types.pluginType`, which for example allows the user to
  create abstractions for adding plugins

- Migrate indent-blankline to setupOpts for more customizability. While the
  plugin's options can now be found under `indentBlankline.setupOpts`, the
  previous iteration of the module also included out of place/broken options,
  which have been removed for the time being. These are:
  - `listChar` - this was already unused
  - `fillChar` - this had nothing to do with the plugin, please configure it
    yourself by adding `vim.opt.listchars:append({ space = '<char>' })` to your
    lua configuration
  - `eolChar` - this also had nothing to do with the plugin, please configure it
    yourself by adding `vim.opt.listchars:append({ eol = '<char>' })` to your
    lua configuration

- Make the entire configuration lua based. This comes with a few breaking changes:
  - `vim.configRC` has been removed, migrate your entries to lua code, and add them to `vim.luaConfigRC` instead
  - `vim.luaScriptRC` is now the top-level DAG, and the internal `vim.pluginRC` has been introduced for setting up internal plugins. See the "DAG entries in nvf" manual page for more information.

[NotAShelf](https://github.com/notashelf):

[ts-error-translator.nvim]: https://github.com/dmmulroy/ts-error-translator.nvim

- Add `deno fmt` as the default Markdown formatter. This will be enabled
  automatically if you have autoformatting enabled, but can be disabled manually
  if you choose to.

- Add `vim.extraLuaFiles` for optionally sourcing additional lua files in your
  configuration.

- Refactor `programs.languages.elixir` to use lspconfig and none-ls for LSP and
  formatter setups respectively. Diagnostics support is considered, and may be
  added once the [credo](https://github.com/rrrene/credo) linter has been added
  to nixpkgs. A pull request is currently open.

- Remove vim-tidal and friends.

- Clean up Lualine module to reduce theme dependency on Catppuccin, and fixed
  blending issues in component separators.

- Add [ts-ereror-translator.nvim] extension of the TS language module, under
  `vim.languages.ts.extensions.ts-error-translator` to aid with Typescript
  development.

- Add [neo-tree.nvim] as an alternative file-tree plugin. It will be available
  under `vim.filetree.neo-tree`, similar to nvimtree.
