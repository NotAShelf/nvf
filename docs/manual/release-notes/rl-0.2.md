# Release 0.2 {#sec-release-0-2}

Release notes for release 0.2

## Changelog {#sec-release-0-2-changelog}

[notashelf](https://github.com/notashelf):

- Added two minimap plugins under `vim.minimap`. `codewindow.nvim` is enabled by
  default, while `minimap.vim` is available with its code-minimap dependency.
- A complementary plugin, `obsidian.nvim` and the Neovim alternative for Emacs'
  orgmode with `orgmode.nvim` have been added. Both will be disabled by default.
- Smooth scrolling for ANY movement command is now available with
  `cinnamon.nvim`
- You will now notice a dashboard on startup. This is provided by the
  `alpha.nvim` plugin. You can use any of the three available dashboard plugins,
  or disable them entirely.
- There is now a scrollbar on active buffers, which can highlight errors by
  hooking to your LSPs. This is on by default, but can be toggled off under
  `vim.visuals` if seen necessary.
- Discord Rich Presence has been added through `presence.nvim` for those who
  want to flex that they are using the _superior_ text editor.
- An icon picker is now available with telescope integration. You can use
  `:IconPickerInsert` or `:IconPickerYank` to add icons to your code.
- A general-purpose cheatsheet has been added through `cheatsheet.nvim`. Forget
  no longer!
- `ccc.nvim` has been added to the default plugins to allow picking colors with
  ease.
- Most UI components of Neovim have been replaced through the help of
  `noice.nvim`. There are also notifications and custom UI elements available
  for Neovim messages and prompts.
- A (floating by default) terminal has been added through `toggleterm.nvim`.
- Harness the power of ethical (`tabnine.nvim`) and not-so-ethical
  (`copilot.lua`) AI by those new assistant plugins. Both are off by default,
  TabNine needs to be wrapped before it's working.
- Experimental mouse gestures have been added through `gesture.nvim`. See plugin
  page and the relevant module for more details on how to use.
- Re-open last visited buffers via `nvim-session-manager`. Disabled by default
  as deleting buffers seems to be problematic at the moment.
- Most of NvimTree's configuration options have been changed with some options
  being toggled to off by default.
- Lualine had its configuration simplified and style toned down. Less color,
  more info.
- Modules where multiple plugin configurations were in the same directory have
  been simplified. Each plugin inside a single module gets its directory to be
  imported.
- Separate config options with the same parent attribute have been merged into
  one for simplicity.
