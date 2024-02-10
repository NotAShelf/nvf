# Release 0.6 {#sec-release-0.6}

Release notes for release 0.6

## Changelog {#sec-release-0.6-changelog}

[ksonj](https://github.com/ksonj):

- Add Terraform language support

[horriblename](https://github.com/horriblename):

- Fixed empty winbar when breadcrumbs are disabled

[donnerinoern](https://github.com/donnerinoern):

- Added Gruvbox theme

- Added marksman LSP for Markdown

- Fixed markdown preview with Glow not working and added an option for changing the preview keybind

- colorizer.nvim: switched to a maintained fork

[notashelf](https://github.com/notashelf):

- Finished moving to `nixosOptionsDoc` in the documentation and changelog. We are fully free of asciidoc now

- Bumped plugin inputs to their latest versions

- Deprecated `presence.nvim` in favor of `neocord`. This means `vim.rich-presence.presence-nvim` is removed and will throw
  a warning if used. You are recommended to rewrite your neocord config from scratch based on the
  [official documentation](https://github.com/IogaMaster/neocord)

- Added support for css and tailwindcss through vscode-language-servers-extracted & tailwind-language-server.
  Those can be enabled through `vim.languages.css` and `vim.languages.tailwind`

- Lualine module now allows customizing `always_divide_middle`, `ignore_focus` and `disabled_filetypes` through the new
  options: [vim.statusline.lualine.alwaysDivideMiddle](vim.statusline.lualine.alwaysDivideMiddle),
  [vim.statusline.lualine.ignoreFocus](vim.statusline.lualine.ignoreFocus) and
  [vim.statusline.lualine.disabledFiletypes](vim.statusline.lualine.disabledFiletypes)

- Updated all plugin inputs to their latest versions (26.01.2024) - this brought minor color changess to the Catppuccin
  theme
