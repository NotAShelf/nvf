# Release 0.6 {#sec-release-0.6}

Release notes for release 0.6

## Changelog {#sec-release-0.6-changelog}

[ksonj](https://github.com/ksonj):

- Add Terraform language support

[donnerinoern](https://github.com/donnerinoern):

- Added Gruvbox theme

- Added marksman LSP for Markdown

- Fixed markdown preview with Glow not working and added an option for changing the preview keybind

- colorizer.nvim: switched to a maintained fork

- Added `markdown-preview.nvim`, moved `glow.nvim` to a brand new `vim.utility.preview` category.

[elijahimmer](https://github.com/elijahimmer)

- Added rose-pine theme

[horriblename](https://github.com/horriblename):

- Fixed empty winbar when breadcrumbs are disabled

- Added custom `setupOpts` for various plugins

- Removed support for deprecated plugin "nvim-compe"

- Moved most plugins to `setupOpts` method

[frothymarrow](https://github.com/frothymarrow):

- Added option `vim.luaPackages` to wrap neovim with extra Lua packages.

- Rewrote the entire `fidget.nvim` module to include extensive configuration options. Option `vim.fidget-nvim.align.bottom` has
  been removed in favor of [vim.fidget-nvim.notification.window.align](vim.fidget-nvim.notification.window.align), which now supports
  `top` and `bottom` values. `vim.fidget-nvim.align.right` has no longer any equivalent and also has been removed.

- `which-key.nvim` categories can now be customized through [vim.binds.whichKey.register](vim.binds.whichKey.register).

- Added `magick` to `vim.luaPackages` for `image.nvim`

- Added `alejandra` to the default devShell.

- Migrated neovim-flake to `makeNeovimUnstable` wrapper

[notashelf](https://github.com/notashelf):

- Finished moving to `nixosOptionsDoc` in the documentation and changelog. We are fully free of asciidoc now

- Bumped plugin inputs to their latest versions

- Deprecated `presence.nvim` in favor of `neocord`. This means `vim.rich-presence.presence-nvim` is removed and will throw
  a warning if used. You are recommended to rewrite your neocord configuration from scratch based on the
  [official documentation](https://github.com/IogaMaster/neocord)

- Removed Tabnine plugin due to the usage of imperative tarball downloads. If you'd like to see it back, please make an issue.

- Added support for css and tailwindcss through vscode-language-servers-extracted & tailwind-language-server.
  Those can be enabled through `vim.languages.css` and `vim.languages.tailwind`

- Lualine module now allows customizing `always_divide_middle`, `ignore_focus` and `disabled_filetypes` through the new
  options: [vim.statusline.lualine.alwaysDivideMiddle](vim.statusline.lualine.alwaysDivideMiddle),
  [vim.statusline.lualine.ignoreFocus](vim.statusline.lualine.ignoreFocus) and
  [vim.statusline.lualine.disabledFiletypes](vim.statusline.lualine.disabledFiletypes)

- Updated all plugin inputs to their latest versions (14.04.2024) - this brought minor color changes to the Catppuccin
  theme.

- Moved home-manager module entrypoint to `flake/modules` and added an experimental Nixos module. This requires further testing
  before it can be considered ready for use.

- Made lib calls explicit. E.g. `lib.strings.optionalString` instead of `lib.optionalString`. This is a pattern expected
  to be followed by all contributors in the future.

- Added `image.nvim` for image previews.

- The final neovim package is now exposed. This means you can build the neovim package that will be added to your
  package list without rebuilding your system to test if your configuration yields a broken package.

- Changed the tree structure to distinguish between core options and plugin options.

- Added plugin auto-discovery from plugin inputs. This is mostly from
  [JordanIsaac's neovim-flake](https://github.com/jordanisaacs/neovim-flake)

[jacekpoz](https://github.com/jacekpoz):

- Added `vim.autocomplete.alwaysComplete`. Allows users to have the autocomplete window popup only when manually activated.
