# Release 0.9 {#sec-release-0-9}

## Breaking changes

- Nixpkgs has merged a fully incompatible rewrite of
  `vimPlugins.nvim-treesitter`. Namely, it changes from the frozen `master`
  branch to the new main branch. This change removes incremental selections, so
  it is no longer available.
- [obsidian.nvim] now uses a maintained fork which has removed the `dir`
  setting. Use `workspaces` instead:

  ```nix
  {
    workspaces = [
      {
        name = "any-string";
        path = "~/old/dir/path/value";
      }
    ];
  }
  ```

  Some other settings and commands are now deprecated but are still supported.

  - The `setupOpts.mappings` options were also removed. Use the built-in Neovim
    settings (nvf's {option}`vim.keymaps`)

[Snoweuph](https://github.com/snoweuph)

- "Correct `languages.go.treesitter` to contain all Go file types.
  `languages.go.treesitter.package` is now `languages.go.treesitter.goPackage`.
  New are:

  - `languages.go.treesitter.goPackage`.

  - `languages.go.treesitter.gomodPackage`.

  - `languages.go.treesitter.gosumPackage`.

  - `languages.go.treesitter.goworkPackage`.

  - `languages.go.treesitter.gotmplPackage`.

- Fix `vim.assistant.codecompanion-nvim.setupOpts.display.diff.provider` to only
  allow valid options. `default` is no longer valid. `inline` and `split` are
  two new valid options.

- Added [taplo](https://taplo.tamasfe.dev/) as the default formatter and lsp for
  `languages.toml` so we don't default to AI-Slop.

## Changelog {#sec-release-0-9-changelog}

[taylrfnt](https://github.com/taylrfnt)

- Introduce a `darwinModule` option for Darwin users. The ergonomics of
  importing a `nixosModule` into a Darwin flake were less than ideal, and when
  users fork and update npins, they are prone to encountering errors like the
  following:

  ```shell
  (class: "nixos") cannot be imported into a module 
  evaluation that expects class "darwin".
  ```

[suimong](https://github.com/suimong):

- Fix `vim.tabline.nvimBufferline` where `setupOpts.options.hover` requires
  `vim.opt.mousemoveevent` to be set.

[thamenato](https://github.com/thamenato):

- Attempt to adapt nvim-treesitter to (breaking) Nixpkgs changes. Some
  treesitter grammars were changed to prefer `grammarPlugins` over
  `builtGrammars`.

[NotAShelf](https://github.com/notashelf):

- Lazyload noice.nvim and nvim-web-devicons on `DeferredUIEnter`

[jfeo](https://github.com/jfeo):

[ccc.nvim]: https://github.com/uga-rosa/ccc.nvim

- Added [ccc.nvim] option {option}`vim.utility.ccc.setupOpts` with the existing
  hard-coded options as default values.

[Ring-A-Ding-Ding-Baby](https://github.com/Ring-A-Ding-Ding-Baby):

- Aligned `codelldb` adapter setup with [rustaceanvim]’s built-in logic.
- Added `languages.rust.dap.backend` option to choose between `codelldb` and
  `lldb-dap` adapters.

[Libadoxon](https://github.com/Libadoxon):

- `toggleterm` open map now also works when in terminal mode

[jtliang24](https://github.com/jtliang24):

- Updated nix language plugin to use pkgs.nixfmt instead of
  pkgs.nixfmt-rfc-style

[alfarel](https://github.com/alfarelcynthesis):

[obsidian.nvim]: https://github.com/obsidian-nvim/obsidian.nvim
[blink.cmp]: https://cmp.saghen.dev/
[snacks.nvim]: https://github.com/folke/snacks.nvim
[mini.nvim]: https://nvim-mini.org/mini.nvim/
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
[fzf-lua]: https://github.com/ibhagwan/fzf-lua
[render-markdown.nvim]: https://github.com/MeanderingProgrammer/render-markdown.nvim
[markview.nvim]: https://github.com/OXY2DEV/markview.nvim
[which-key.nvim]: https://github.com/folke/which-key.nvim

- Upgrade [obsidian.nvim] to use a maintained fork, instead of the unmaintained
  upstream.
  - Various upstream improvements:
    - Support [blink.cmp] and completion plugin autodetection.
    - Support various pickers for prompts, including [snacks.nvim]'s
      `snacks.picker`, [mini.nvim]'s `mini.pick`, [telescope.nvim], and
      [fzf-lua].
    - Merge commands like `ObsidianBacklinks` into `Obisidian backlinks`. The
      old format is still supported by default.
    - Some `setupOpts` options have changed:
      - `disable_frontmatter` -> `frontmatter.enabled` (and inverted), still
        supported.
      - `note_frontmatter_func` -> `frontmatter.func`, still supported.
      - `statusline` module is now deprecated in favour of `footer`, still
        supported.
      - `dir` is no longer supported, use `workspaces`:

        ```nix
        {
          workspaces = [
            {
              name = "any-string";
              path = "~/old/dir/path/value";
            }
          ];
        }
        ```

      - `use_advanced_uri` -> `open.use_advanced_uri`.
      - Mappings are now expected to be set using the built-in Neovim APIs,
        managed by `vim.keymaps` in nvf, instead of `mappings` options.
      - Some option defaults have changed.
    - And more.
  - Automatically configure an enabled picker in the order mentioned above, if
    any are enabled.
  - Add integration with `snacks.image` for rendering workspace/vault assets.
  - Detect if [render-markdown.nvim] or [markview.nvim] are enabled and disable
    the `ui` module if so. It should work without this, but `render-markdown`'s
    {command}`:healthcheck` doesn't know that.
  - Remove [which-key.nvim] `<leader>o` `+Notes` description which did not
    actually correspond to any keybinds.

[pyrox0](https://github.com/pyrox0):

- Added [rumdl](https://github.com/rvben/rumdl) support to `languages.markdown`

- Added [sqruff](https://github.com/quarylabs/sqruff) support to `languages.sql`

- Lazy-load `crates.nvim` plugin when using
  `vim.languages.rust.extensions.crates-nvim.enable`

- Added [Pyrefly](https://pyrefly.org/) and [zuban](https://zubanls.com/)
  support to `languages.python`

- Added TOML support via {option}`languages.toml` and the
  [Tombi](https://tombi-toml.github.io/tombi/) language server, linter, and
  formatter.

- Added Jinja support via `languages.jinja`

- Added [hlargs.nvim](https://github.com/m-demare/hlargs.nvim) support as
  `visuals.hlargs-nvim`.

- Lazy-load `nvim-autopairs` plugin when using
  `vim.autopairs.nvim-autopairs.enable`

[Machshev](https://github.com/machshev):

- Added `ruff` and `ty` LSP support for Python under `programs.python`.

[Snoweuph](https://github.com/snoweuph)

- Added [Selenen](https://github.com/kampfkarren/selene) for more diagnostics in
  `languages.lua`.

- Added [`mdformat`](https://mdformat.rtfd.io/) support to `languages.markdown`
  with the extensions for [GFM](https://github.github.com/gfm/),
  [front matter](https://www.markdownlang.com/advanced/frontmatter.html) and
  [footnotes](https://www.markdownguide.org/extended-syntax/#footnotes).

- Added XML syntax highlighting, LSP support and formatting

- Added [mypy](https://www.mypy-lang.org/) to `languages.python` for extra
  diagnostics.

- Added [tera](https://keats.github.io/tera/) language support (syntax
  highlighting only).

- Added Debugging support to `languages.odin` with
  [nvim-dap-odin](https://github.com/NANDquark/nvim-dap-odin).

- Disabled notifications for
  [nvim-dap-odin](https://github.com/NANDquark/nvim-dap-odin), because it
  contain no use full information, only spam, and it can't be made lazy.

- Added [`golangci-lint`](https://golangci-lint.run/) for more diagnostics.

- Added [`gopher.nvim`](https://github.com/olexsmir/gopher.nvim) for extra
  actions in `languages.go`.

- updated default filetypes for
  [harper-ls](https://github.com/Automattic/harper) to match what they are
  supposed to be.

- Added Makefile support via `languages.make`.

- Fix `languages.hcl` init, depending on `comment-nvim` by checking if it is
  enabled. Fixes a crash (#1350).

- Added Debugging support to `languages.php`.

- Added Formatting support to `languages.php` via
  [PHP-CS-Fixer](https://github.com/PHP-CS-Fixer/PHP-CS-Fixer).

- Didn't Add
  [`syntax-gaslighting`](https://github.com/NotAShelf/syntax-gaslighting.nvim),
  you're crazy.

[vagahbond](https://github.com/vagahbond): [codewindow.nvim]:
https://github.com/gorbit99/codewindow.nvim

- Add [codewindow.nvim] plugin in `vim.assistant.codewindow` with `enable` and
  `setupOpts`

[irobot](https://github.com/irobot):

- Fix non-functional `vim.keymaps.*.noremap`. Now, setting it to false is
  equivalent to `:lua vim.keymap.set(..., { remap = true })`

[kazimazi](https://github.com/kazimazi):

- Added [`grug-far.nvim`](https://github.com/MagicDuck/grug-far.nvim) the find
  and replace tool for neovim.
- Fix lsp `client.supports_method` deprecation warning in nvim v0.12.
- Add [`blink.indent`](https://github.com/saghen/blink.indent) indent guideline
  plugin.

[Ladas552](https://github.com/Ladas552)

- Changed `withRuby` to not be enabled by default
- Fix virtualtext mode in colorizer

[horriblename](https://github.com/horriblename):

- Ignore terminals by default in spell-checking

[poz](https://poz.pet):

[neocmakelsp]: https://github.com/neocmakelsp/neocmakelsp
[arduino-language-server]: https://github.com/arduino/arduino-language-server
[glsl_analyzer]: https://github.com/nolanderc/glsl_analyzer

- Add CMake support with [neocmakelsp].
- Add Arduino support with [arduino-language-server].
- Add GLSL support with [glsl_analyzer].

[itscrystalline](https://github.com/itscrystalline):

[img-clip.nvim]: https://github.com/hakonharnes/img-clip.nvim

- [img-clip.nvim]'s configuration now has it's own DAG entry, separate from
  image-nvim.

<!-- vim: set textwidth=80: -->
