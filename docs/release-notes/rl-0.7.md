# Release 0.7 {#sec-release-0.7}

Release notes for release 0.7

## Changelog {#sec-release-0.7-changelog}

[ItsSorae](https://github.com/ItsSorae):

- Add support for [typst](https://typst.app/) under `vim.languages.typst` This
  will enable the `typst-lsp` language server, and the `typstfmt` formatter

[frothymarrow](https://github.com/frothymarrow):

- Modified type for
  [](#opt-vim.visuals.fidget-nvim.setupOpts.progress.display.overrides) from
  `anything` to a `submodule` for better type checking.
- Fix null `vim.lsp.mappings` generating an error and not being filtered out.
- Add basic transparency support for `oxocarbon` theme by setting the
  highlight group for `Normal`, `NormalFloat`, `LineNr`, `SignColumn` and
  optionally `NvimTreeNormal` to `none`.

[horriblename](https://github.com/horriblename):

- Fix broken treesitter-context keybinds in visual mode
- Depcrecate use of `__empty` to define empty tables in lua. Empty attrset are
  no longer filtered and thus should be used instead.

[NotAShelf](https://github.com/notashelf)

- Add `deno fmt` as the default Markdown formatter. This will be enabled
  automatically if you have autoformatting enabled, but can be disabled manually
  if you choose to.

- Add `vim.extraLuaFiles` for optionally sourcing additional lua files in your
  configuration.

- Refactor `programs.languages.elixir` to use lspconfig and none-ls for LSP and
  formatter setups respectively. Diagnostics support is considered, and may be
  added once the [credo](https://github.com/rrrene/credo) linter has been added
  to nixpkgs. A pull request is currently open.

- Remove vim-tidal and friends

- Clean up Lualine module to reduce theme dependency on Catppuccin, and fixed
  blending issues in component separators.

[jacekpoz](https://github.com/jacekpoz):

- Add [ocaml-lsp](https://github.com/ocaml/ocaml-lsp) support.
