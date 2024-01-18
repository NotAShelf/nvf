# Release 0.6 {#sec-release-0.6}

Release notes for release 0.6

## Changelog {#sec-release-0.6-changelog}

[ksonj](https://github.com/ksonj):

- Add Terraform language support

[horriblename](https://github.com/horriblename):

- Fixed empty winbar when breadcrumbs are disabled

[notashelf](https://github.com/notashelf):

- Finished moving to `nixosOptionsDoc` in the documentation and changelog. We are fully free of asciidoc now

- Bumped plugin inputs to their latest versions

- Deprecated `presence.nvim` in favor of `neocord`. This means `vim.rich-presence.presence-nvim` is removed and will throw
  a warning if used. You are recommended to rewrite your neocord config from scratch based on the
  [official documentation](https://github.com/IogaMaster/neocord)

[donnerinoern](https://github.com/donnerinoern):

- Added Gruvbox theme

- Added marksman LSP for Markdown
