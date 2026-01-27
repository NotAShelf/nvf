# Release 0.3 {#sec-release-0-3}

Release 0.3 had to come out before I wanted it to due to Neovim 0.9 dropping
into nixpkgs-unstable. The Treesitter changes have prompted a Treesitter rework,
which was followed by reworking the languages system. Most of the changes to
those are downstreamed from the original repository. The feature requests that
was originally planned for 0.3 have been moved to 0.4, which should come out
soon.

## Changelog {#sec-release-0-3-changelog}

- We have transitioned to flake-parts, from flake-utils to extend the
  flexibility of this flake. This means the flake structure is different than
  usual, but the functionality remains the same.

- We now provide a home-manager module. Do note that it is still far from
  perfect, but it works.

- `nodejs_16` is now bundled with `Copilot.lua` if the user has enabled Copilot
  assistant.

- which-key section titles have been fixed. This is to be changed once again in
  a possible keybind rewrite, but now it should display the correct titles
  instead of `+prefix`

- Most of `presence.nvim`'s options have been made fully configurable through
  your configuration file.

- Most of the modules have been refactored to separate `config` and `options`
  attributes.

- Darwin has been deprecated as the Zig package is marked as broken. We will
  attempt to use the Zig overlay to return Darwin support.

- `Fidget.nvim` has been added as a neat visual addition for LSP installations.

- `diffview.nvim` has been added to provide a convenient diff utility.

  [discourse]: https://discourse.nixos.org/t/psa-if-you-are-on-unstable-try-out-nvim-treesitter-withallgrammars/23321?u=snowytrees

- Treesitter grammars are now configurable with
  {option}`vim.treesitter.grammars`. Utilizes the nixpkgs `nvim-treesitter`
  plugin rather than a custom input in order to take advantage of build support
  of pinned versions. See [discourse] for more information. Packages can be
  found under the `pkgs.vimPlugins.nvim-treesitter.builtGrammars` attribute.
  Treesitter grammars for supported languages should be enabled within the
  module. By default no grammars are installed, thus the following grammars
  which do not have a language section are not included anymore: **comment**,
  **toml**, **make**, **html**, **css**, **graphql**, **json**.

- A new section has been added for language support: `vim.languages.<language>`.

  - The options `enableLSP` {option}`vim.languages.enableTreesitter`, etc. will
    enable the respective section for all languages that have been enabled.
  - All LSP languages have been moved here
  - `plantuml` and `markdown` have been moved here
  - A new section has been added for `html`. The old
    `vim.treesitter.autotagHtml` can be found at
    {option}`vim.languages.html.treesitter.autotagHtml`.

- `vim.git.gitsigns.codeActions` has been added, allowing you to turn on
  Gitsigns' code actions.

- Removed the plugins document in the docs. Was too unwieldy to keep updated.

- `vim.visual.lspkind` has been moved to {option}`vim.lsp.lspkind.enable`

- Improved handling of completion formatting. When setting
  `vim.autocomplete.sources`, can also include optional menu mapping. And can
  provide your own function with `vim.autocomplete.formatting.format`.

- For `vim.visuals.indentBlankline.fillChar` and
  `vim.visuals.indentBlankline.eolChar` options, turning them off should be done
  by using `null` rather than `""` now.

- Transparency has been made optional and has been disabled by default.
  {option}`vim.theme.transparent` option can be used to enable or disable
  transparency for your configuration.

- Fixed deprecated configuration method for Tokyonight, and added new style
  "moon"

- Dart language support as well as extended flutter support has been added.
  Thanks to @FlafyDev for his contributions towards Dart language support.

- Elixir language support has been added through `elixir-tools.nvim`.

- `hop.nvim` and `leap.nvim` have been added for fast navigation.

- `modes.nvim` has been added to the UI plugins as a minor error highlighter.

- `smartcollumn.nvim` has been added to dynamically display a colorcolumn when
  the limit has been exceeded, providing per-buftype column position and more.

- `project.nvim` has been added for better project management inside Neovim.

- More configuration options have been added to `nvim-session-manager`.

- Editorconfig support has been added to the core functionality, with an enable
  option.

- `venn-nvim` has been dropped due to broken keybinds.
