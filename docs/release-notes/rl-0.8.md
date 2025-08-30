# Release 0.8 {#sec-release-0.8}

## Breaking changes

[Lspsaga documentation]: https://nvimdev.github.io/lspsaga/

- `git-conflict` keybinds are now prefixed with `<leader>` to avoid conflicting
  with builtins.

- `alpha` is now configured with nix, default config removed.

- Lspsaga module no longer ships default keybindings. The keybind format has
  been changed by upstream, and old keybindings do not have equivalents under
  the new API they provide. Please manually set your keybinds according to
  [Lspsaga documentation] following the new API.

- none-ls has been updated to the latest version. If you have been using raw Lua
  configuration to _manually_ configure it, some of the formats may become
  unavailable as they have been refactored out of the main none-ls repository
  upstream.

- `vim.useSystemClipboard` has been deprecated as a part of removing most
  top-level convenience options, and should instead be configured in the new
  module interface. You may set [](#opt-vim.clipboard.registers) appropriately
  to configure Neovim to use the system clipboard.

- Changed which-key group used for gitsigns from `<leader>g` to `<leader>h` to
  align with the "hunks" themed mapping and avoid conflict with the new [neogit]
  group.

[NotAShelf](https://github.com/notashelf):

[typst-preview.nvim]: https://github.com/chomosuke/typst-preview.nvim
[render-markdown.nvim]: https://github.com/MeanderingProgrammer/render-markdown.nvim
[yanky.nvim]: https://github.com/gbprod/yanky.nvim
[yazi.nvim]: https://github.com/mikavilpas/yazi.nvim
[snacks.nvim]: https://github.com/folke/snacks.nvim
[colorful-menu.nvim]: https://github.com/xzbdmw/colorful-menu.nvim
[oil.nvim]: https://github.com/stevearc/oil.nvim
[hunk.nvim]: https://github.com/julienvincent/hunk.nvim
[undotree]: https://github.com/mbbill/undotree

- Add [typst-preview.nvim] under
  `languages.typst.extensions.typst-preview-nvim`.

- Add a search widget to the options page in the nvf manual.

- Add [render-markdown.nvim] under
  `languages.markdown.extensions.render-markdown-nvim`.

- Implement [](#opt-vim.git.gitsigns.setupOpts) for user-specified setup table
  in gitsigns configuration.

- [](#opt-vim.options.mouse) no longer compares values to an enum of available
  mouse modes. This means you can provide any string without the module system
  warning you that it is invalid. Do keep in mind that this value is no longer
  checked, so you will be responsible for ensuring its validity.

- Deprecate `vim.enableEditorconfig` in favor of
  [](#opt-vim.globals.editorconfig).

- Deprecate rnix-lsp as it has been abandoned and archived upstream.

- Hardcoded indentation values for the Nix language module have been removed. To
  replicate previous behaviour, you must either consolidate Nix indentation in
  your Editorconfig configuration, or use an autocommand to set indentation
  values for buffers with the Nix filetype.

- Add [](#opt-vim.lsp.lightbulb.autocmd.enable) for manually managing the
  previously managed lightbulb autocommand.

  - A warning will occur if [](#opt-vim.lsp.lightbulb.autocmd.enable) and
    `vim.lsp.lightbulb.setupOpts.autocmd.enabled` are both set at the same time.
    Pick only one.

- Add [yanky.nvim] to available plugins, under `vim.utility.yanky-nvim`.

- Fix plugin `setupOpts` for yanky.nvim and assert if shada is configured as a
  backend while shada is disabled in Neovim options.

- Add [yazi.nvim] as a companion plugin for Yazi, the terminal file manager.

- Add [](#opt-vim.autocmds) and [](#opt-vim.augroups) to allow declaring
  autocommands via Nix.

- Fix plugin `setupOpts` for yanky.nvim and assert if shada is configured as a
  backend while shada is disabled in Neovim options.

- Add [yazi.nvim] as a companion plugin for Yazi, the terminal file manager.

- Add [snacks.nvim] under `vim.utility.snacks-nvim` as a general-purpose utility
  plugin.

- Move LSPSaga to `setupOpts` format, allowing freeform configuration in
  `vim.lsp.lspsaga.setupOpts`.

- Lazyload Lspsaga and remove default keybindings for it.

- Add [colorful-menu.nvim] to enhance the completion menus, with optional
  integration for blink-cmp and nvim-cmp
- Add [oil.nvim] as an alternative file explorer. It will be available under
  `vim.utility.oil-nvim`.
- Add `vim.diagnostics` to interact with Neovim's diagnostics module. Available
  options for `vim.diagnostic.config()` can now be customized through the
  [](#opt-vim.diagnostics.config) in nvf.

- Add `vim.clipboard` module for easily managing Neovim clipboard providers and
  relevant packages in a simple UI.
  - This deprecates `vim.useSystemClipboard` as well, see breaking changes
    section above for migration options.
- Add [hunk.nvim], Neovim plugin & tool for splitting diffs in Neovim. Available
  as `vim.git.hunk-nvim`

[sjcobb2022](https://github.com/sjcobb2022):

- Migrate all current lsp configurations to `vim.lsp.server` and remove internal
  dependency on `nvim-lspconfig`

[amadaluzia](https://github.com/amadaluzia):

[haskell-tools.nvim]: https://github.com/MrcJkb/haskell-tools.nvim

- Add Haskell support under `vim.languages.haskell` using [haskell-tools.nvim].

[horriblename](https://github.com/horriblename):

[blink.cmp]: https://github.com/saghen/blink.cmp

- Add [aerial.nvim].
- Add [nvim-ufo].
- Add [blink.cmp] support.
- Add `LazyFile` user event.
- Migrate language modules from none-ls to conform/nvim-lint
- Add tsx support in conform and lint
- Moved code setting `additionalRuntimePaths` and `enableLuaLoader` out of
  `luaConfigPre`'s default to prevent being overridden
- Use conform over custom autocmds for LSP format on save

[diniamo](https://github.com/diniamo):

- Add Odin support under `vim.languages.odin`.

- Disable the built-in format-on-save feature of zls. Use `vim.lsp.formatOnSave`
  instead.

[LilleAila](https://github.com/LilleAila):

- Remove `vim.notes.obsidian.setupOpts.dir`, which was set by default. Fixes
  issue with setting the workspace directory.
- Add `vim.snippets.luasnip.setupOpts`, which was previously missing.
- Add `"prettierd"` as a formatter option in
  `vim.languages.markdown.format.type`.
- Add the following plugins from
  [mini.nvim](https://github.com/echasnovski/mini.nvim)
  - `mini.ai`
  - `mini.align`
  - `mini.animate`
  - `mini.base16`
  - `mini.basics`
  - `mini.bracketed`
  - `mini.bufremove`
  - `mini.clue`
  - `mini.colors`
  - `mini.comment`
  - `mini.completion`
  - `mini.deps`
  - `mini.diff`
  - `mini.doc`
  - `mini.extra`
  - `mini.files`
  - `mini.fuzzy`
  - `mini.git`
  - `mini.hipatterns`
  - `mini.hues`
  - `mini.icons`
  - `mini.indentscope`
  - `mini.jump`
  - `mini.jump2d`
  - `mini.map`
  - `mini.misc`
  - `mini.move`
  - `mini.notify`
  - `mini.operators`
  - `mini.pairs`
  - `mini.pick`
  - `mini.sessions`
  - `mini.snippets`
  - `mini.splitjoin`
  - `mini.starter`
  - `mini.statusline`
  - `mini.surround`
  - `mini.tabline`
  - `mini.test`
  - `mini.trailspace`
  - `mini.visits`
- Add [fzf-lua](https://github.com/ibhagwan/fzf-lua) in `vim.fzf-lua`
- Add [rainbow-delimiters](https://github.com/HiPhish/rainbow-delimiters.nvim)
  in `vim.visuals.rainbow-delimiters`
- Add options to define highlights under [](#opt-vim.highlight)

[kaktu5](https://github.com/kaktu5):

- Add WGSL support under `vim.languages.wgsl`.

[tomasguinzburg](https://github.com/tomasguinzburg):

[solargraph]: https://github.com/castwide/solargraph
[gbprod/nord.nvim]: https://github.com/gbprod/nord.nvim

- Add Ruby support under `vim.languages.ruby` using [solargraph].
- Add `nord` theme from [gbprod/nord.nvim].

[thamenato](https://github.com/thamenato):

[ruff]: (https://github.com/astral-sh/ruff)
[cue]: (https://cuelang.org/)

- Add [ruff] as a formatter option in `vim.languages.python.format.type`.
- Add [cue] support under `vim.languages.cue`.

[ARCIII](https://github.com/ArmandoCIII):

[leetcode.nvim]: https://github.com/kawre/leetcode.nvim
[codecompanion-nvim]: https://github.com/olimorris/codecompanion.nvim

- Add `vim.languages.zig.dap` support through pkgs.lldb dap adapter. Code
  Inspiration from `vim.languages.clang.dap` implementation.
- Add [leetcode.nvim] plugin under `vim.utility.leetcode-nvim`.
- Add [codecompanion.nvim] plugin under `vim.assistant.codecompanion-nvim`.
- Fix [codecompanion-nvim] plugin: nvim-cmp error and setupOpts defaults.

[nezia1](https://github.com/nezia1):

- Add support for [nixd](https://github.com/nix-community/nixd) language server.

[jahanson](https://github.com/jahanson):

- Add [multicursors.nvim](https://github.com/smoka7/multicursors.nvim) to
  available plugins, under `vim.utility.multicursors`.
- Add [hydra.nvim](https://github.com/nvimtools/hydra.nvim) as dependency for
  `multicursors.nvim` and lazy loads by default.

[folospior](https://github.com/folospior):

- Fix plugin name for lsp/lspkind.

- Move `vim-illuminate` to `setupOpts format`

[iynaix](https://github.com/iynaix):

- Add lsp options support for [nixd](https://github.com/nix-community/nixd)
  language server.

[Mr-Helpful](https://github.com/Mr-Helpful):

- Corrects pin names used for nvim themes.

[Libadoxon](https://github.com/Libadoxon):

- Add [git-conflict](https://github.com/akinsho/git-conflict.nvim) plugin for
  resolving git conflicts.
- Add formatters for go: [gofmt](https://go.dev/blog/gofmt),
  [golines](https://github.com/segmentio/golines) and
  [gofumpt](https://github.com/mvdan/gofumpt).

[UltraGhostie](https://github.com/UltraGhostie)

- Add [harpoon](https://github.com/ThePrimeagen/harpoon) plugin for navigation

[MaxMur](https://github.com/TheMaxMur):

- Add YAML support under `vim.languages.yaml`.

[alfarel](https://github.com/alfarelcynthesis):

[conform.nvim]: https://github.com/stevearc/conform.nvim

- Add missing `yazi.nvim` dependency (`snacks.nvim`).
- Add [mkdir.nvim](https://github.com/jghauser/mkdir.nvim) plugin for automatic
  creation of parent directories when editing a nested file.
- Add [nix-develop.nvim](https://github.com/figsoda/nix-develop.nvim) plugin for
  in-neovim `nix develop`, `nix shell` and more.
- Add [direnv.vim](https://github.com/direnv/direnv.vim) plugin for automatic
  syncing of nvim shell environment with direnv's.
- Add [blink.cmp] source options and some default-disabled sources.
- Add [blink.cmp] option to add
  [friendly-snippets](https://github.com/rafamadriz/friendly-snippets) so
  blink.cmp can source snippets from it.
- Fix [blink.cmp] breaking when built-in sources were modified.
- Fix [conform.nvim] not allowing disabling formatting on and after save. Use
  `null` value to disable them if conform is enabled.

[TheColorman](https://github.com/TheColorman):

- Fix plugin `setupOpts` for `neovim-session-manager` having an invalid value
  for `autoload_mode`.

[esdevries](https://github.com/esdevries):

[projekt0n/github-nvim-theme]: https://github.com/projekt0n/github-nvim-theme

- Add `github-nvim-theme` theme from [projekt0n/github-nvim-theme].

[BANanaD3V](https://github.com/BANanaD3V):

- `alpha` is now configured with nix.
- Add `markview-nvim` markdown renderer.

[viicslen](https://github.com/viicslen):

- Add `intelephense` language server support under
  `vim.languages.php.lsp.server`

[Butzist](https://github.com/butzist):

- Add Helm chart support under `vim.languages.helm`.

[rice-cracker-dev](https://github.com/rice-cracker-dev):

- `eslint_d` now checks for configuration files to load.
- Fix an error where `eslint_d` fails to load.
- Add required files support for linters under
  `vim.diagnostics.nvim-lint.linters.*.required_files`.
- Add global function `nvf_lint` under
  `vim.diagnostics.nvim-lint.lint_function`.
- Deprecate `vim.scrollOffset` in favor of `vim.options.scrolloff`.
- Fix `svelte-language-server` not reloading .js/.ts files on change.

[Sc3l3t0n](https://github.com/Sc3l3t0n):

- Add F# support under `vim.languages.fsharp`.

[venkyr77](https://github.com/venkyr77):

- Add lint (luacheck) and formatting (stylua) support for Lua.
- Add lint (markdownlint-cli2) support for Markdown.
- Add catppuccin integration for Bufferline, Lspsaga.
- Add `neo-tree`, `snacks.explorer` integrations to `bufferline`.
- Add more applicable filetypes to illuminate denylist.
- Disable mini.indentscope for applicable filetypes.
- Fix fzf-lua having a hard dependency on fzf.
- Enable inlay hints support - `config.vim.lsp.inlayHints`.
- Add `neo-tree`, `snacks.picker` extensions to `lualine`.
- Add support for `vim.lsp.formatOnSave` and
  `vim.lsp.mappings.toggleFormatOnSave`

[tebuevd](https://github.com/tebuevd):

- Fix `pickers` configuration for `telescope` by nesting it under `setupOpts`
- Fix `find_command` configuration for `telescope` by nesting it under
  `setupOpts.pickers.find_files`
- Update default `telescope.setupOpts.pickers.find_files.find_command` to only
  include files (and therefore exclude directories from results)

[ckoehler](https://github.com/ckoehler):

[flash.nvim]: https://github.com/folke/flash.nvim
[gitlinker.nvim]: https://github.com/linrongbin16/gitlinker.nvim
[nvim-treesitter-textobjects]: https://github.com/nvim-treesitter/nvim-treesitter-textobjects

- Fix oil config referencing snacks
- Add [flash.nvim] plugin to `vim.utility.motion.flash-nvim`
- Fix default telescope ignore list entry for '.git/' to properly match
- Add [gitlinker.nvim] plugin to `vim.git.gitlinker-nvim`
- Add [nvim-treesitter-textobjects] plugin to `vim.treesitter.textobjects`
- Default to disabling Conform for Rust if rust-analyzer is used
  - To force using Conform, set `languages.rust.format.enable = true`.

[rrvsh](https://github.com/rrvsh):

- Add custom snippet support to `vim.snippets.luasnip`
- Fix namespace of python-lsp-server by changing it to python3Packages

[Noah765](https://github.com/Noah765):

[vim-sleuth]: https://github.com/tpope/vim-sleuth

- Add missing `flutter-tools.nvim` dependency `plenary.nvim`.
- Add necessary dependency of `flutter-tools.nvim` on lsp.
- Add the `vim.languages.dart.flutter-tools.flutterPackage` option.
- Fix the type of the `highlight` color options.
- Add [vim-sleuth] plugin under `vim.utility.sleuth`.

[howird](https://github.com/howird):

- Change python dap adapter name from `python` to commonly expected `debugpy`.

[aionoid](https://github.com/aionoid):

[avante-nvim]: https://github.com/yetone/avante.nvim

- Fix [render-markdown.nvim] file_types option type to list, to accept merging.
- Add [avante.nvim] plugin under `vim.assistant.avante-nvim`.

[poz](https://poz.pet):

[everforest]: https://github.com/sainnhe/everforest
[oil]: https://github.com/stevearc/oil.nvim
[oil-git-status]: https://github.com/refractalize/oil-git-status.nvim

- Fix gitsigns null-ls issue.
- Add [everforest] theme support.
- Add [oil-git-status] support to [oil] module.

[Haskex](https://github.com/haskex):

[Hardtime.nvim]: https://github.com/m4xshen/hardtime.nvim

- Add Plugin [Hardtime.nvim] under `vim.binds.hardtime-nvim` with `enable` and
  `setupOpts` options

[taylrfnt](https://github.com/taylrfnt):

[nvim-tree](https://github.com/nvim-tree/nvim-tree.lua):

- Add missing `right_align` option for existing `renderer.icons` options.
- Add missing `render.icons` options (`hidden_placement`,
  `diagnostics_placement`, and `bookmarks_placement`).

[cramt](https://github.com/cramt):

- Add `rubylsp` option in `vim.languages.ruby.lsp.server` to use shopify's
  ruby-lsp language server

[Haskex](https://github.com/haskex):

[solarized-osaka.nvim]: https://github.com/craftzdog/solarized-osaka.nvim

- Add [solarized-osaka.nvim] theme

[img-clip.nvim]: https://github.com/hakonharnes/img-clip.nvim

- Add [img-clip.nvim] plugin in `vim.utility.images.img-clip` with `enable` and
  `setupOpts`
- Add `vim.utility.images.img-clip.enable = isMaximal` in configuration.nix

[anil9](https://github.com/anil9):

[clojure-lsp]: https://github.com/clojure-lsp/clojure-lsp
[conjure]: https://github.com/Olical/conjure

- Add Clojure support under `vim.languages.clojure` using [clojure-lsp]
- Add code evaluation environment [conjure] under `vim.repl.conjure`

[CallumGilly](https://github.com/CallumGilly):

- Add missing `transparent` option for existing
  [onedark.nvim](https://github.com/navarasu/onedark.nvim) theme.

[theutz](https://github.com/theutz):

- Added "auto" flavour for catppuccin theme

[lackac](https://github.com/lackac):

[solarized.nvim]: https://github.com/maxmx03/solarized.nvim
[smart-splits.nvim]: https://github.com/mrjones2014/smart-splits.nvim
[neogit]: https://github.com/NeogitOrg/neogit

- Add [solarized.nvim] theme with support for multiple variants
- Add [smart-splits.nvim] for navigating between Neovim windows and terminal
  multiplexer panes. Available at `vim.utility.smart-splits`.
- Restore vim-dirtytalk plugin and fix ordering with spellcheck in generated
  config.
- Fix lualine separator options
- Add [neogit], an interactive and powerful Git interface for Neovim, inspired
  by Magit
- Allow deregistering which-key binds or groups by setting them to `null`

[justDeeevin](https://github.com/justDeeevin):

[supermaven-nvim]: https://github.com/supermaven-inc/supermaven-nvim

- Add [supermaven-nvim] plugin in `vim.assistant.supermaven-nvim` with `enable`
  and `setupOpts`

[trueNAHO](https://github.com/trueNAHO):

- `flake-parts`'s `nixpkgs-lib` input follows nvf's `nixpkgs` input to reduce
  download size.

- `flake-utils`'s `systems` inputs follows nvf's `systems` input to transitively
  leverage the pattern introduced in commit
  [fc8206e7a61d ("flake: utilize
  nix-systems for overridable flake systems")](https://github.com/NotAShelf/nvf/commit/fc8206e7a61d7eb02006f9010e62ebdb3336d0d2).

[soliprem](https://github.com/soliprem):

- fix broken `neorg` grammars
- remove obsolete warning in the `otter` module

[JManch](https://github.com/JManch):

- Fix default [blink.cmp] sources "path" and "buffer" not working when
  `autocomplete.nvim-cmp.enable` was disabled and
  `autocomplete.nvim-cmp.sources` had not been modified.

[Poseidon](https://github.com/poseidon-rises):

[nvim-biscuits]: https://github.com/code-biscuits/nvim-biscuits
[just-lsp]: https://github.com/terror/just-lsp
[roslyn-ls]: https://github.com/dotnet/vscode-csharp
[jsonls]: https://github.com/microsoft/vscode/tree/1.101.2/extensions/json-language-features/server
[jsonfmt]: https://github.com/caarlos0/jsonfmt
[superhtml]: https://github.com/kristoff-it/superhtml
[htmlHINT]: https://github.com/htmlhint/HTMLHint
[qmk-nvim]: https://github.com/codethread/qmk.nvim
[qmlls]: https://doc.qt.io/qt-6/qtqml-tooling-qmlls.html
[qmlformat]: https://doc.qt.io/qt-6/qtqml-tooling-qmlformat.html

- Add [nvim-biscuits] support under `vim.utility.nvim-biscuits`.
- Add just support under `vim.languages.just` using [just-lsp].
- Add [roslyn-ls] to the `vim.languages.csharp` module.
- Add JSON support under `vim.languages.json` using [jsonls] and [jsonfmt].
- Add advanced HTML support under `vim.languages.html` using [superhtml] and
  [htmlHINT].
- Add QMK support under `vim.utility.qmk-nvim` via [qmk-nvim].
- Add QML support under `vim.languages.qml` using [qmlls] and [qmlformat].

[Morsicus](https://github.com/Morsicus):

- Add [EEx Treesitter Grammar](https://github.com/connorlay/tree-sitter-eex) for
  Elixir
- Add
  [HEEx Treesitter Grammar](https://github.com/phoenixframework/tree-sitter-heex)
  for Elixir

[diced](https://github.com/diced):

- Fixed `typescript` treesitter grammar not being included by default.

[valterschutz](https://github.com/valterschutz):

[ruff]: (https://github.com/astral-sh/ruff)

- Add [ruff-fix] as a formatter option in `vim.languages.python.format.type`.

[gmvar](https://github.com/gmvar):

[harper-ls]: https://github.com/Automattic/harper

- Add [harper-ls] to the `vim.lsp` module.

[derethil](https://github.com/derethil):

- Fix `vim.lazy.plugins.<name>.enabled` Lua evaluation.
