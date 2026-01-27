# Release 0.4 {#sec-release-0-4}

Following the release of v0.3, I have decided to release v0.4 with a massive new
change: customizable keybinds. As of the 0.4 release, keybinds will no longer be
hardcoded and instead provided by each module's own keybinds section. The old
keybind system (`vim.keybinds = {}`) is now considered deprecated and the new
lib functions are recommended to be used for adding keybinds for new plugins, or
adding keybinds to existing plugins.

Alongside customizable keybinds, there are a few quality of life updates, such
as `lazygit` integration and the new experimental Lua loader of Neovim 0.9
thanks to our awesome contributors who made this update possible during my
absence.

## Changelog {#sec-release-0-4-changelog}

[n3oney](https://github.com/n3oney):

- Streamlined keybind adding process towards new functions in extended stdlib.

- Moved default keybinds into keybinds section of each module

- Simplified luaConfigRC and configRC setting - they can now just take strings

- Refactored the resolveDag function - you can just provide a string now, which
  will default to dag.entryAnywhere

- Fixed formatting sometimes removing parts of files

- Made formatting synchronous

- Gave null-ls priority over other formatters

[horriblename](https://github.com/horriblename):

- Added `clangd` as alternative lsp for C/++.

- Added `toggleterm` integration for `lazygit`.

- Added new option `enableluaLoader` to enable neovim's experimental module
  loader for faster startup time.

- Fixed bug where flutter-tools can't find `dart` LSP

- Added Debug Adapter (DAP) support for clang, rust, go, python and dart.

[notashelf](https://github.com/notashelf):

- Made Copilot's Node package configurable. It is recommended to keep as
  default, but providing a different NodeJS version is now possible.

- Added `vim.cursorlineOpt` for configuring Neovim's `vim.o.cursorlineopt`.

- Added `filetree.nvimTreeLua.view.cursorline`, default false, to enable
  cursorline in nvimtre.

- Added Fidget.nvim support for the Catppuccin theme.

- Updated bundled NodeJS version used by `Copilot.lua`. v16 is now marked as
  insecure on Nixpkgs, and we updated to v18

- Enabled Catppuccin modules for plugins available by default.

- Added experimental Svelte support under `vim.languages`.

- Removed unnecessary scrollbar element from notifications and codeaction
  warning UI.

- `vim.utility.colorizer` has been renamed to `vim.utility.ccc` after the plugin
  it uses

- Color preview via `nvim-colorizer.lua`

- Updated Lualine statusline UI

- Added vim-illuminate for smart highlighting

- Added a module for enabling Neovim's spellchecker

- Added prettierd as an alternative formatter to prettier - currently defaults
  to prettier

- Fixed presence.nvim inheriting the wrong client id

- Cleaned up documentation
