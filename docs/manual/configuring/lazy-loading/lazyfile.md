# The LazyFile Event {#sec-lazy-lazyfile}

nvf re-implements the `LazyFile` user event familiar from lazy.nvim. It is a
synthetic Neovim `User` autocommand event that fires the first time a real file
is opened: a buffer with an actual file path, not a dashboard, an empty scratch
buffer, or a terminal.

## When LazyFile Fires {#sec-lazy-lazyfile-when}

`LazyFile` is an alias for the combination of three standard Neovim events:

- `BufReadPost`: an existing file was read into a buffer.
- `BufNewFile`: a new (not yet saved) file was opened.
- `BufWritePre`: a buffer is about to be written (catches unsaved new files
  before the first save).

This means the plugin loads when the user starts editing a file, not at startup
or on every buffer switch.

## Why Use LazyFile {#sec-lazy-lazyfile-why}

Plugins that only make sense in the context of an open file (LSP clients, indent
guides, Git signs, diagnostics) are good candidates for `LazyFile` loading.
Using `BufReadPost` directly would miss new files; using `BufEnter` would
include dashboard and empty buffers. `LazyFile` covers the common case.

## Example {#sec-lazy-lazyfile-example}

```nix
{
  config.vim.lazy.plugins = {
    "gitsigns.nvim" = {
      package = pkgs.vimPlugins.gitsigns-nvim;
      setupModule = "gitsigns";
      setupOpts = {
        signs = {
          add = { text = "+"; };
          change = { text = "~"; };
          delete = { text = "_"; };
        };
      };
      event = [{ event = "User"; pattern = "LazyFile"; }];
    };
  };
}
```

With the above configuration, `gitsigns.nvim` is not loaded at startup. It loads
the first time a file buffer is opened, keeping startup fast for sessions that
never open a file (e.g. `nvim` alone on the command line). This mechanism is
regularly used in nvf modules. In case you notice plugins loading slow, it is
worth experimenting whether the situation improves with lazy loading, and
potentially upstreaming your optimizations to nvf.
