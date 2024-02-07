# Release 0.5 {#sec-release-0.5}

Release notes for release 0.5

## Changelog {#sec-release-0.5-changelog}

[vagahbond](https://github.com/vagahbond):

- Added phan language server for PHP

- Added phpactor language server for PHP

[horriblename](https://github.com/horriblename):

- Added transparency support for tokyonight theme

- Fixed a bug where cmp's close and scrollDocs mappings wasn't working

- Streamlined and simplified extra plugin API with the addition of [vim.extraPlugins](vim.extraPlugins)

- Allow using command names in place of LSP packages to avoid automatic installation

- Add lua LSP and treesitter support, and neodev.nvim plugin support

- Add [vim.lsp.mappings.toggleFormatOnSave](vim.lsp.mappings.toggleFormatOnSave) keybind

[amanse](https://github.com/amanse):

- Added daily notes options for obsidian plugin

- Added jdt-language-server for Java

[yavko](https://github.com/yavko):

- Added Deno Language Server for javascript/typescript

- Added support for multiple languages [vim.spellChecking.languages](vim.spellChecking.languages), and added
  vim-dirtytalk through [vim.spellChecking.enableProgrammingWordList](vim.spellChecking.enableProgrammingWordList)

[frothymarrow](https://github.com/FrothyMarrow):

- Renamed `vim.visuals.cursorWordline` to [vim.visuals.cursorline.enable](vim.visuals.cursorline.enable)

- Added [vim.visuals.cursorline.lineNumbersOnly](vim.visuals.cursorline.lineNumbersOnly) to display cursorline
  only in the presence of line numbers

- Added Oxocarbon to the list of available themes.

[notashelf](https://github.com/notashelf):

- Added GitHub Copilot to nvim-cmp completion sources.

- Added [vim.ui.borders.enable](vim.ui.borders.enable) for global and individual plugin border configuration.

- LSP integrated breadcrumbs with [vim.ui.breadcrumbs.enable](vim.ui.breadcrumbs.enable) through nvim-navic

- LSP navigation helper with nvim-navbuddy, depends on nvim-navic (automatically enabled if navic is enabled)

- Addeed nvim-navic integration for catppuccin theme

- Fixed mismatching zig language description

- Added support for `statix` and `deadnix` through [vim.languages.nix.extraDiagnostics.types](vim.languages.nix.extraDiagnostics.types)

- Added `lsp_lines` plugin for showing diagnostic messages

- Added a configuration option for choosing the leader key

- The package used for neovim is now customizable by the user, using [vim.package](vim.package).
  For best results, always use an unwrapped package

- Added highlight-undo plugin for highlighting undo/redo targets

- Added bash LSP and formatter support

- Disabled Lualine LSP status indicator for toggleterm buffer

- Added `nvim-docs-view`, a plugin to display lsp hover documentation in a side panel

- Switched to `nixosOptionsDoc` in option documentation.
  To quote home-manager commit: "Output is mostly unchanged aside from some minor typographical and
  formatting changes, along with better source links."

- Updated indent-blankine.nvim to v3 - this comes with a few option changes, which will be migrated with `renamedOptionModule`

[jacekpoz](https://github.com/jacekpoz):

- Fixed scrollOffset not being used

- Updated clangd to 16

- Disabled `useSystemClipboard` by default

[ksonj](https://github.com/ksonj):

- Add support to change mappings to utility/surround

- Add black-and-isort python formatter

- Removed redundant "Enable ..." in `mkEnableOption` descriptions

- Add options to modify LSP key bindings and add proper whichkey descriptions

- Changed type of `statusline.lualine.activeSection` and `statusline.lualine.inactiveSection`
  from `attrsOf str` to `attrsOf (listOf str)`

- Added `statusline.lualine.extraActiveSection` and `statusline.lualine.extraInactiveSection`
