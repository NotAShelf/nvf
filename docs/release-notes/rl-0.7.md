# Release 0.7 {#sec-release-0.7}

Release notes for release 0.7

## Breaking Changes and Migration Guide {#sec-breaking-changes-and-migration-guide-0-7}

### `vim.configRC` removed {#sec-vim-configrc-removed}

In v0.7 we are removing `vim.configRC` in favor of making `vim.luaConfigRC` the
top-level DAG, and thereby making the entire configuration Lua based. This
change introduces a few breaking changes:

[DAG entries in nvf manual]: /index.xhtml#ch-dag-entries

- `vim.configRC` has been removed, which means that you have to convert all of
  your custom vimscript-based configuration to Lua. As for how to do that, you
  will have to consult the Neovim documentation and your search engine.
- After migrating your Vimscript-based configuration to Lua, you might not be
  able to use the same entry names in `vim.luaConfigRC`, because those have also
  slightly changed. See the new [DAG entries in nvf manual] for more details.

**Why?**

Neovim being an aggressive refactor of Vim, is designed to be mainly Lua based;
making good use of its extensive Lua API. Additionally, Vimscript is slow and
brings unnecessary performance overhead while working with different
configuration formats.

### `vim.lsp.nvimCodeActionMenu` removed in favor of `vim.ui.fastaction` {#sec-nvim-code-action-menu-deprecation}

The nvim-code-action-menu plugin has been archived and broken for a long time,
so it's being replaced with a young, but better alternative called
fastaction.nvim. Simply remove everything set under
`vim.lsp.nvimCodeActionMenu`, and set `vim.ui.fastaction.enable` to `true`.

Note that we are looking to add more alternatives in the future like
dressing.nvim and actions-preview.nvim, in case fastaction doesn't work for
everyone.

## Changelog {#sec-release-0.7-changelog}

[ItsSorae](https://github.com/ItsSorae):

- Add support for [typst](https://typst.app/) under `vim.languages.typst` This
  will enable the `typst-lsp` language server, and the `typstfmt` formatter

[frothymarrow](https://github.com/frothymarrow):

- Modified type for
  [](#opt-vim.visuals.fidget-nvim.setupOpts.progress.display.overrides) from
  `anything` to a `submodule` for better type checking.

- Fix null `vim.lsp.mappings` generating an error and not being filtered out.

- Add basic transparency support for `oxocarbon` theme by setting the highlight
  group for `Normal`, `NormalFloat`, `LineNr`, `SignColumn` and optionally
  `NvimTreeNormal` to `none`.

- Fix [](#opt-vim.ui.smartcolumn.setupOpts.custom_colorcolumn) using the wrong
  type `int` instead of the expected type `string`.

[horriblename](https://github.com/horriblename):

- Fix broken treesitter-context keybinds in visual mode
- Deprecate use of `__empty` to define empty tables in Lua. Empty attrset are no
  longer filtered and thus should be used instead.
- Add dap-go for better dap configurations
- Make noice.nvim customizable
- Standardize border style options and add custom borders

[rust-tools.nvim]: https://github.com/simrat39/rust-tools.nvim
[rustaceanvim]: https://github.com/mrcjkb/rustaceanvim

- Switch from [rust-tools.nvim] to the more feature-packed [rustaceanvim]. This
  switch entails a whole bunch of new features and options, so you are
  recommended to go through rustacean.nvim's README to take a closer look at its
  features and usage

[jacekpoz](https://jacekpoz.pl):

[ocaml-lsp]: https://github.com/ocaml/ocaml-lsp
[new-file-template.nvim]: https://github.com/otavioschwanck/new-file-template.nvim
[neo-tree.nvim]: https://github.com/nvim-neo-tree/neo-tree.nvim

- Add [ocaml-lsp] support

- Fix "Emac" typo

- Add [new-file-template.nvim] to automatically fill new file contents using
  templates

- Make [neo-tree.nvim] display file icons properly by enabling
  `visuals.nvimWebDevicons`

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

- Replace `vim.lsp.nvimCodeActionMenu` with `vim.ui.fastaction`, see the
  breaking changes section above for more details

[Neovim documentation on `vim.cmd`]: https://neovim.io/doc/user/lua.html#vim.cmd()

- Make Neovim's configuration file entirely Lua based. This comes with a few
  breaking changes:
  - `vim.configRC` has been removed. You will need to migrate your entries to
    Neovim-compliant Lua code, and add them to `vim.luaConfigRC` instead.
    Existing vimscript configurations may be preserved in `vim.cmd` functions.
    Please see [Neovim documentation on `vim.cmd`]
  - `vim.luaScriptRC` is now the top-level DAG, and the internal `vim.pluginRC`
    has been introduced for setting up internal plugins. See the "DAG entries in
    nvf" manual page for more information.

[NotAShelf](https://github.com/notashelf):

[ts-error-translator.nvim]: https://github.com/dmmulroy/ts-error-translator.nvim
[credo]: https://github.com/rrrene/credo

- Add `deno fmt` as the default Markdown formatter. This will be enabled
  automatically if you have autoformatting enabled, but can be disabled manually
  if you choose to.

- Add `vim.extraLuaFiles` for optionally sourcing additional lua files in your
  configuration.

- Refactor `programs.languages.elixir` to use lspconfig and none-ls for LSP and
  formatter setups respectively. Diagnostics support is considered, and may be
  added once the [credo] linter has been added to nixpkgs. A pull request is
  currently open.

- Remove vim-tidal and friends.

- Clean up Lualine module to reduce theme dependency on Catppuccin, and fixed
  blending issues in component separators.

- Add [ts-ereror-translator.nvim] extension of the TS language module, under
  `vim.languages.ts.extensions.ts-error-translator` to aid with Typescript
  development.

- Add [neo-tree.nvim] as an alternative file-tree plugin. It will be available
  under `vim.filetree.neo-tree`, similar to nvimtree.

- Add `nvf-print-config` & `nvf-print-config-path` helper scripts to Neovim
  closure. Both of those scripts have been automatically added to your PATH upon
  using neovimConfig or `programs.nvf.enable`.

  - `nvf-print-config` will display your `init.lua`, in full.
  - `nvf-print-config-path` will display the path to _a clone_ of your
    `init.lua`. This is not the path used by the Neovim wrapper, but an
    identical clone.

- Add `vim.ui.breadcrumbs.lualine` to allow fine-tuning breadcrumbs behaviour on
  Lualine. Only `vim.ui.breadcrumbs.lualine.winbar` is supported for the time
  being.

  - [](#opt-vim.ui.breadcrumbs.lualine.winbar.enable) has been added to allow
    controlling the default behaviour of the `nvim-navic` component on Lualine,
    which used to occupy `winbar.lualine_c` as long as breadcrumbs are enabled.
  - `vim.ui.breadcrumbs.alwaysRender` has been renamed to
    [](#opt-vim.ui.breadcrumbs.lualine.winbar.alwaysRender) to be conform to the
    new format.

- Add [basedpyright](https://github.com/detachhead/basedpyright) as a Python LSP
  server and make it default.

- Add [python-lsp-server](https://github.com/python-lsp/python-lsp-server) as an
  additional Python LSP server.

- Add [](#opt-vim.options) to set `vim.o` values in in your nvf configuration
  without using additional Lua. See option documentation for more details.

- Add [](#opt-vim.dashboard.dashboard-nvim.setupOpts) to allow user
  configuration for [dashboard.nvim](https://github.com/nvimdev/dashboard-nvim)

- Update `lualine.nvim` input and add missing themes:
  - Adds `ayu`, `gruvbox_dark`, `iceberg`, `moonfly`, `onedark`,
    `powerline_dark` and `solarized_light` themes.

[ppenguin](https://github.com/ppenguin):

- Telescope:
  - Fixed `project-nvim` command and keybinding
  - Added default ikeybind/command for `Telescope resume` (`<leader>fr`)

[Soliprem](https://github.com/Soliprem):

- Add LSP and Treesitter support for R under `vim.languages.R`.
- Add Otter support under `vim.lsp.otter` and an assert to prevent conflict with
  ccc

[Bloxx12](https://github.com/Bloxx12):

- Fix internal breakage in `elixir-tools` setup.
