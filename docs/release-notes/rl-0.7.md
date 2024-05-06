# Release 0.7 {#sec-release-0.7}

Release notes for release 0.7

## Changelog {#sec-release-0.7-changelog}

[ItsSorae](https://github.com/ItsSorae):

- Added support for [typst](https://typst.app/) under `vim.languages.typst`
  This will enable the `typst-lsp` language server, and the `typstfmt` formatter

[frothymarrow](https://github.com/frothymarrow):

- Modified type for [](#opt-vim.visuals.fidget-nvim.setupOpts.progress.display.overrides)
  from `anything` to a `submodule` for better type checking

[horriblename](https://github.com/horriblename)

- Fix broken treesitter-context keybinds in visual mode

[NotAShelf](https://github.com/notashelf)

- Add `deno fmt` as the default Markdown formatter. This will be enabled
  automatically if you have autoformatting enabled, but can be disabled manually
  if you choose to.

- Remove vim-tidal and friends

- Remove unmaintained Elixir language module. This has been long broken, and was
  unmaintained due to my disinterest in using Elixir. If you depend on Elixir
  language support, please create an issue. Do keep in mind that elixirls **does
  not exist in nixpkgs**.
