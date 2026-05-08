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

- `languages.{terraform,hcl}`: LSP servers now default to `tofu-ls`. While this
  is unlikely to cause any noticeable change in behavior or breakage, it's
  mentioned just in case.

- `vim.treesitter.foldByDefault` is removed. Folding behavior should be
  controlled via `vim.options.foldenable` directly instead. RIP
  `vim.treesitter.foldByDefault` 2026-03-19 - 2026-03-19.

- `vim.assistant.codecompanion-nvim.setupOpts.strategies` has been renamed to
  `vim.assistant.codecompanion-nvim.setupOpts.interactions` to match the
  upstream codecompanion.nvim v19 rename. If you set options like
  `setupOpts.strategies.chat.adapter`, rename them to
  `setupOpts.interactions.chat.adapter`.

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

- Added `json5` into `languages.json`. Some options where renamed.

- Moved `vim.lsp.harper-ls` to `vim.lsp.presets.haper`.

- Removed `typst_lsp` from `languages.typst.lsp.servers`, because it is
  deprecated and thus was pulled from nixpkgs.
  <https://github.com/NixOS/nixpkgs/commit/bf24296bbe2e31ac7147b02ea645922390ca8f4b>

- Renamed `ts_ls` to `typescript-language-server`.

- Renamed `denols` to `deno`.

- Renamed `tsgo` to `typescript-go`.

- Renamed `vala_ls` to `vala-language-server`.

- Renamed `terraformls-tf` and `terraformls-hcl` to `terraform-ls`.

- Renamed `tofuls-tf` and `tofuls-hcl` to `tofu-ls`.

- Renamed `ruby_lsp` to `ruby-lsp`.

- Renamed `r_language_server` to `r-languageserver`.

- Renamed `julials` to `julia-languageserver`.

- Renamed `astro` to `astro-language-server`.

- Renamed `bash-ls` to `bash-language-server`.

- Renamed `jsonls` to `vscode-json-language-server`.

- Renamed `cssls` to `vscode-css-language-server`.

- Renamed `jdtls` to `jdt-language-server`.

- Renamed `elixirls` to `elixir-ls`.

- Removed `languages.tailwind` which only provided an LSP. Use
  `lsp.presets.tailwindcss-language-server` instead.

- Renamed `languages.ts` to `languages.typescript`.

- Added {option}`vim.languages.go.treesitter.gotmpl.injection` and Renamed
  `languages.go.treesitter.gotmplPackage` to
  {option}`vim.languages.go.treesitter.gotmpl.package`

- Split SCSS from `languages.css` into `languages.scss` and add extra tools for
  SCSS/SASS. This also changes the default LSP to `some-sass-language-server`
  for SCSS/SASS.

[CaueAnjos](https://github.com/caueanjos)

- Renamed `roslyn_ls` to `roslyn-ls`
- Turned `omnisharp-extended-lsp-nvim` into an extension disabled by default
- Turned `csharpls-extended-lsp-nvim` into an extension disabled by default

## Changelog {#sec-release-0-9-changelog}

[ErinaYip](https://github.com/ErinaYip):

- Added separate `disabledFiletypes.statusline` and `disabledFiletypes.winbar`
  options in the lualine module, allowing users to configure which filetypes
  should disable lualine for each component independently. Also exposed
  `ignoreFocus` option.

[SecBear](https://github.com/SecBear):

- Renamed `setupOpts.strategies` to `setupOpts.interactions` in the
  codecompanion-nvim module to match the upstream v19 rename. The old key
  triggered a migration shim that silently discarded user `interactions`
  overrides.

[midischwarz12](https://github.com/midischwarz12):

- Changed the prettier-plugin-astro build to use `writableTmpDirAsHomeHook` to
  avoid pnpm hook failures in sandboxed builds.

- Fix `vim.utility.leetcode-nvim` adding `fzf-lua` to `vim.startPlugins` when
  `vim.fzf-lua` already manages the plugin lazily, avoiding duplicate `/start`
  and `/opt` installs and the corresponding `mnw` evaluation warning.

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
- Allow nulling treesitter packages for various language modules, filter `null`
  values in `vim.treesitter.grammars`.

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

[ppenguin](https://github.com/ppenguin):

- Improved/harmonized for `terraform` and `hcl`:
  - formatting (use `terraform fmt` or `tofu fmt` for `tf` files)
  - LSP config
  - Added `tofu` and `tofu-ls` as (free) alternative to `terrraform` and
    `terraform-ls`

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

- Allow disabling nvf's vendored keymaps by toggling `vendoredKeymaps.enable`.

[pyrox0](https://github.com/pyrox0):

- Added [rumdl](https://github.com/rvben/rumdl) support to `languages.markdown`

- Added [sqruff](https://github.com/quarylabs/sqruff) support to `languages.sql`

- Lazy-load `crates.nvim` plugin when using
  `vim.languages.rust.extensions.crates-nvim.enable`

- Added [Pyrefly](https://pyrefly.org/) and [zuban](https://zubanls.com/)
  support to `languages.python`

- Added TOML support via {option}`vim.languages.toml.enable` and the
  [Tombi](https://tombi-toml.github.io/tombi/) language server, linter, and
  formatter.

- Added Jinja support via `languages.jinja`

- Added [hlargs.nvim](https://github.com/m-demare/hlargs.nvim) support as
  `visuals.hlargs-nvim`.

- Lazy-load `nvim-autopairs` plugin when using
  `vim.autopairs.nvim-autopairs.enable`

- Added support for neovim 0.12's `ui2` feature via `vim.ui.ui2`

[Machshev](https://github.com/machshev):

- Added `ruff` and `ty` LSP support for Python under `programs.python`.

[Snoweuph](https://github.com/snoweuph)

- Added {option}`vim.treesitter.queries` to support adding custom queries.

- Added injections for `query = '' ... ''` as `query` and `mkLualine '' ... ''`,
  `entryAnywhere '' ... ''`, `entryBefore [] '' ... ''`,
  `entryAfter [] '' ... ''` as `lua` in nix.

- Added {option}`vim.languages.tera.treesitter.injection` to configure, what
  language the content is.

- Added {option}`vim.languages.jinja.treesitter.injection` to configure, what
  language the content is.

- Added {option}`vim.treesitter.filetypeMappings` to support mappings similar to
  <https://github.com/nvim-treesitter/nvim-treesitter/blob/main/plugin/filetypes.lua>.
  This is mostly use full for Markdown code block injections.

- Added some Tree-sitter filetype mappings for:
  - `bash` = `ash`, `dash`, `zsh`
  - `yaml` = `yaml`

- Added `vim.lsp.presets.<name>` to contain LSP configurations. This allows for
  more flexibility in nvf and reuse of LSPs across languages. Dropped
  `deprecatedSingleOrListOf` in favor of `listOf` for the affected LSP options.

- Added {option}`vim.lsp.presets.angular-language-server.enable` for Angular
  Template support.

- Added {option}`vim.lsp.presets.vtsls.enable` for Vue TypeScript support.

- Added {option}`vim.lsp.presets.vue-language-server.enable` for Vue Template
  support.

- Added {option}`vim.lsp.presets.some-sass-language-server.enable`.

- Fix `vim.lsp.presets.vala-language-server` to be wrapped correctly with
  `uncrustify`.

- Fix `tressiter` to allow `null` in grammar options, so they can be filtered
  out.

- Fix {option}`vim.utility.nvim-biscuits.enable` by upgrading, to fix
  tree-sitter incompatibilities.

- Fix image.nvim processor configuration and cleanup module.

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

- Added [liquid](https://keats.github.io/tera/) language support (syntax
  highlighting only) via `languages.liquid`.

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

- Add `lsp.presets.emmet-ls` as supported LSP to
  - `languages.jinja`
  - `languages.liquid`
  - `languages.tera`
  - `languages.twig`
  - `languages.astro`

- Fix `languages.hcl` init, depending on `comment-nvim` by checking if it is
  enabled. Fixes a crash (#1350).

- Added [`tsgo`](https://github.com/microsoft/typescript-go) as an LSP to
  `languages.ts`.

- Fix `languages.ts` registration of formatters.

- Added `biome-check` and `biome-organize-imports` formatters to `languages.ts`.

- Added [`biomejs`](https://biomejs.dev/) as extra diagnostics provider to
  `languages.ts`.

- Added `languages.vue`.

- Add `languages.fluent` using the official plugin. This only provides
  highlighting.

- Add `languages.gettext`. This only provides highlighting.

- Add `languages.openscad` using
  [`openscad-lsp`](https://github.com/Leathong/openscad-LSP). This currently
  relies on neovim builtin syntax for highlighting, and the lsp for formatting
  and diagnostics.

- Added Debugging support to `languages.php`.

- Added Formatting support to `languages.php` via
  [PHP-CS-Fixer](https://github.com/PHP-CS-Fixer/PHP-CS-Fixer).

- Added minimal `languages.twig`. Currently using [djlint](https://djlint.com/)
  for most options, as better alternatives like
  [twig-cs-fixer](https://github.com/VincentLanglet/Twig-CS-Fixer) aren't
  packaged for nix.

- Added `languages.tex`. Currently only highlighting, formatting and lsp. No
  previewing yet.

- Added `languages.jq`. Supports highlighting, formatting and lsp.

- Extend `languages.asm` to support more filetypes out of the box.

- Added {option}`vim.languages.java.extensions.maven-nvim.enable` for Maven
  support;

- Added {option}`vim.languages.java.extensions.gradle-nvim.enable` for Gradle
  support;

- Didn't Add
  [`syntax-gaslighting`](https://github.com/NotAShelf/syntax-gaslighting.nvim),
  you're crazy.

- Added neovim theme `gruber-darker`
  <https://github.com/blazkowolf/gruber-darker.nvim>.

- Added coverage support (`vim.utility.crazy-coverage`) via
  [`crazy-coverage.nvim`](https://github.com/mr-u0b0dy/crazy-coverage.nvim).

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

[phanirithvij](https://github.com/phanirithvij):

[elm-language-server]: https://github.com/elm-tooling/elm-language-server

- Add Elm support with [elm-language-server]

[alv-around](https://github.com/alv-around):

- Fix `vim.assistant.codecompanion-nvim` lazy loading with [blink-cmp]

[foobar14](https://github.com/foobar14):

- Fix `vim.formatter.conform-nvim.setupOpts.formatters` type for correct merging

[SmackleFunky](https://github.com/SmackleFunky):

- Updated codecompanion-nvim adapters to allow specifying a model.

[tlvince](https://github.com/tlvince):

- Added configuration option for `foldenable`

[CaueAnjos](https://github.com/caueanjos)

- Added razor support for `roslyn_ls` and `csharp_ls`
- Added `csharpier` formatter to csharp language

[mputz86](https://github.com/mputz86)

- Add `vim.treesitter.indent.pattern` to specify file pattern(s) for which
  treesitter indentation should be used
- Add `vim.treesitter.indent.excludes` to exclude filetypes from the treesitter
  indentation; e.g. useful for Haskell and PureScript, for which treesitter
  indentation does not work good
- Allow `vim.treesitter.context.setupOpts.max_lines` to also be given as a
  string in order to allow percentage values like `"20%"`

<!-- vim: set textwidth=80: -->
