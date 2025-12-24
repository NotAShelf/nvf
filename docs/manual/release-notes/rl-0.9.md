# Release 0.9 {#sec-release-0-9}

## Breaking changes

- Theme `base16` has been replaced with `tinted` theme
- `mini-base16` `base16-colors` property has been renamed to `tinted-colors`

## Changelog {#sec-release-0-9-changelog}

[suimong](https://github.com/suimong):

- Fix `vim.tabline.nvimBufferline` where `setupOpts.options.hover` requires
  `vim.opt.mousemoveevent` to be set.

[JamyGolden](https://github.com/JamyGolden):

- Add support for `tinted-nvim` (base16, base24) themes
