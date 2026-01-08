# Release 0.9 {#sec-release-0-9}

## Breaking changes

- Nixpkgs has merged a fully incompatible rewrite of
  `vimPlugins.nvim-treesitter`. Namely, it changes from the frozen `master`
  branch to the new main branch. This change removes incremental selections, so
  it is no longer available.

## Changelog {#sec-release-0-9-changelog}

[suimong](https://github.com/suimong):

- Fix `vim.tabline.nvimBufferline` where `setupOpts.options.hover` requires
  `vim.opt.mousemoveevent` to be set.

[thamenato](https://github.com/thamenato):

- Attempt to adapt nvim-treesitter to (breaking) Nixpkgs changes. Some
  treesitter grammars were changed to prefer `grammarPlugins` over
  `builtGrammars`.

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

[ppenguin](https://github.com/Libadoxon):

- Improved/harmonized for `terraform` and `hcl`:
  - formatting (use `terraform fmt` or `tofu fmt` for `tf` files)
  - LSP config
  - Added `tofu` and `tofu-ls` as (free) alternative to `terrraform` and
    `terraform-ls`

[jtliang24](https://github.com/jtliang24):

- Updated nix language plugin to use pkgs.nixfmt instead of pkgs.nixfmt-rfc-style
