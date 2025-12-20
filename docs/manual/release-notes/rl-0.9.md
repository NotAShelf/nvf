# Release 0.9 {#sec-release-0-9}

## Changelog {#sec-release-0-9-changelog}


[suimong](https://github.com/suimong):

- Fix `vim.tabline.nvimBufferline` where `setupOpts.options.hover` requires `vim.opt.mousemoveevent` to be set.

[alfarel](https://github.com/alfarelcynthesis):

[obsidian.nvim]: https://github.com/obsidian-nvim/obsidian.nvim
[markview.nvim]: https://github.com/OXY2DEV/markview.nvim

- Upgrade [obsidian.nvim] to use a maintained fork, instead of the unmaintained
  upstream.
  - Support [blink.cmp] and completion plugin autodetection.
  - Support various pickers for prompts, including [snacks.nvim]'s
    `snacks.picker`, [mini.nvim]'s `mini.pick`, `telescope`, and [fzf-lua]. nvf
    will now pick one of these (in that order) if they are enabled.
  - Merge commands like `ObsidianBacklinks` into `Obisidian backlinks`. The old
    format is still supported by default.
  - Add suggested integration with `snacks.image` for rendering in-workspace
    assets.
  - Various other improvements.
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
  - Supposedly detects if [render-markdown.nvim] or [markview.nvim] are enabled
    and disables the `ui` module to prevent conflicts. In testing
    `render-markdown.nvim` still has conflicts unless manually disabled, so nvf
    will disable `ui.enable` explicitly if either is enabled.
