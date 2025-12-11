# Release 0.6 {#sec-release-0-6}

Release notes for release 0.6

## Breaking Changes and Migration Guide {#sec-breaking-changes-and-migration-guide}

In v0.6 we are introducing `setupOpts`: many plugin related options are moved
into their respective `setupOpts` submodule, e.g. `nvimTree.disableNetrw` is
renamed to `nvimTree.setupOpts.disable_netrw`.

_Why?_ in short, you can now pass in anything to setupOpts and it will be passed
to your `require'plugin'.setup{...}`. No need to wait for us to support every
single plugin option.

The warnings when you rebuild your config should be enough to guide you through
what you need to do, if there's an option that was renamed but wasn't listed in
the warning, please file a bug report!

To make your migration process less annoying, here's a keybind that will help
you with renaming stuff from camelCase to snake_case (you'll be doing that a
lot):

```lua
-- paste this in a temp.lua file and load it in vim with :source /path/to/temp.lua
function camelToSnake()
    -- Get the current word under the cursor
    local word = vim.fn.expand("<cword>")
    -- Replace each capital letter with an underscore followed by its lowercase equivalent
    local snakeCase = string.gsub(word, "%u", function(match)
        return "_" .. string.lower(match)
    end)
    -- Remove the leading underscore if present
    if string.sub(snakeCase, 1, 1) == "_" then
        snakeCase = string.sub(snakeCase, 2)
    end
    vim.fn.setreg(vim.v.register, snakeCase)
    -- Select the word under the cursor and paste
    vim.cmd("normal! viwP")
end

vim.api.nvim_set_keymap('n', '<leader>a', ':lua camelToSnake()<CR>', { noremap = true, silent = true })
```

## Changelog {#sec-release-0-6-changelog}

[ksonj](https://github.com/ksonj):

- Added Terraform language support.

- Added `ChatGPT.nvim`, which can be enabled with
  {option}`vim.assistant.chatgpt.enable`. Do keep in mind that this option
  requires `OPENAI_API_KEY` environment variable to be set.

[donnerinoern](https://github.com/donnerinoern):

- Added Gruvbox theme.

- Added marksman LSP for Markdown.

- Fixed markdown preview with Glow not working and added an option for changing
  the preview keybind.

- colorizer.nvim: switched to a maintained fork.

- Added `markdown-preview.nvim`, moved `glow.nvim` to a brand new
  `vim.utility.preview` category.

[elijahimmer](https://github.com/elijahimmer)

- Added rose-pine theme.

[poz](https://poz.pet):

- Added `vim.autocomplete.alwaysComplete`. Allows users to have the autocomplete
  window popup only when manually activated.

[horriblename](https://github.com/horriblename):

- Fixed empty winbar when breadcrumbs are disabled.

- Added custom `setupOpts` for various plugins.

- Removed support for deprecated plugin "nvim-compe".

- Moved most plugins to `setupOpts` method.

[frothymarrow](https://github.com/frothymarrow):

- Added option `vim.luaPackages` to wrap neovim with extra Lua packages.

- Rewrote the entire `fidget.nvim` module to include extensive configuration
  options. Option `vim.fidget-nvim.align.bottom` has been removed in favor of
  `vim.fidget-nvim.notification.window.align`, which now supports `top` and
  `bottom` values. `vim.fidget-nvim.align.right` has no longer any equivalent
  and also has been removed.

- `which-key.nvim` categories can now be customized through
  [vim.binds.whichKey.register](./options.html#option-vim-binds-whichKey-register)

- Added `magick` to `vim.luaPackages` for `image.nvim`.

- Added `alejandra` to the default devShell.

- Migrated neovim-flake to `makeNeovimUnstable` wrapper.

[notashelf](https://github.com/notashelf):

- Finished moving to `nixosOptionsDoc` in the documentation and changelog. All
  documentation options and files are fully free of Asciidoc, and will now use
  Nixpkgs flavored markdown.

- Bumped plugin inputs to their latest versions.

- Deprecated `presence.nvim` in favor of `neocord`. This means
  `vim.rich-presence.presence-nvim` is removed and will throw a warning if used.
  You are recommended to rewrite your neocord configuration from scratch based
  on the. [official documentation](https://github.com/IogaMaster/neocord)

- Removed Tabnine plugin due to the usage of imperative tarball downloads. If
  you'd like to see it back, please create an issue.

- Added support for css and tailwindcss through
  vscode-language-servers-extracted & tailwind-language-server. Those can be
  enabled through `vim.languages.css` and `vim.languages.tailwind`.

- Lualine module now allows customizing `always_divide_middle`, `ignore_focus`
  and `disabled_filetypes` through the new options:
  [vim.statusline.lualine.alwaysDivideMiddle](./options.html#option-vim-statusline-lualine-alwaysDivideMiddle),
  [vim.statusline.lualine.ignoreFocus](./options.html#option-vim-statusline-lualine-ignoreFocus)
  and
  [vim.statusline.lualine.disabledFiletypes](./options.html#option-vim-statusline-lualine-disabledFiletypes).

- Updated all plugin inputs to their latest versions (**21.04.2024**) - this
  brought minor color changes to the Catppuccin theme.

- Moved home-manager module entrypoint to `flake/modules` and added an
  experimental Nixos module. This requires further testing before it can be
  considered ready for use.

- Made lib calls explicit. E.g. `lib.strings.optionalString` instead of
  `lib.optionalString`. This is a pattern expected to be followed by all
  contributors in the future.

- Added `image.nvim` for image previews.

- The final neovim package is now exposed. This means you can build the neovim
  package that will be added to your package list without rebuilding your system
  to test if your configuration yields a broken package.

- Changed the tree structure to distinguish between core options and plugin
  options.

- Added plugin auto-discovery from plugin inputs. This is mostly from
  [JordanIsaac's neovim-flake](https://github.com/jordanisaacs/neovim-flake).
  Allows contributors to add plugin inputs with the `plugin-` prefix to have
  them automatically discovered for the `plugin` type in `lib/types`.

- Moved internal `wrapLuaConfig` to the extended library, structured its
  arguments to take `luaBefore`, `luaConfig` and `luaAfter` as strings, which
  are then concatted inside a lua block.

- Added {option}`vim.luaConfigPre` and {option} `vim-luaConfigPost` for
  inserting verbatim Lua configuration before and after the resolved Lua DAG
  respectively. Both of those options take strings as the type, so you may read
  the contents of a Lua file from a given path.

- Added `vim.spellchecking.ignoredFiletypes` and
  `vim.spellChecking.programmingWordlist.enable` for ignoring certain filetypes
  in spellchecking and enabling `vim-dirtytalk` respectively. The previously
  used `vim.spellcheck.vim-dirtytalk` aliases to the latter option.

- Exposed `withRuby`, `withNodeJs`, `withPython3`, and `python3Packages` from
  the `makeNeovimConfig` function under their respective options.

- Added {option}`vim.extraPackages` for appending additional packages to the
  wrapper PATH, making said packages available while inside the Neovim session.

- Made Treesitter options configurable, and moved treesitter-context to
  `setupOpts` while it is enabled.

- Added {option}`vim.notify.nvim-notify.setupOpts.render` which takes either a
  string of enum, or a Lua function. The default is "compact", but you may
  change it according to nvim-notify documentation.
