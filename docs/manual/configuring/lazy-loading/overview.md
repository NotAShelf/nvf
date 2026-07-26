# Overview {#sec-lazy-overview}

Lazy loading defers plugin initialization until the plugin is actually needed.
Rather than loading every plugin at startup, nvf (via its `lz.n` backend) loads
plugins on demand, triggered by commands, events, filetypes, or keymaps. This
reduces startup time, especially in configurations with many plugins.

## Why Should I LazyLoad? {#sec-why-get-lazy}

Neovim evaluates all sourced Lua and Vimscript at startup. Plugins that register
autocommands, define highlight groups, or call `require()` unconditionally all
contribute to startup latency. For frequently opened editors (terminals,
`git commit`, quick file edits) even a few hundred milliseconds is noticeable.
Lazy loading moves that cost to the first use of a feature instead of every
startup.

## lz.n {#sec-lazy-backend}

[lz.n]: https://github.com/lumen-oss/lz.n

nvf uses [lz.n] as its lazy-loading backend. `lz.n` is a minimal, declarative
lazy loader for Neovim that integrates with Nix-managed plugin paths. Unlike
runtime package managers, `lz.n` does not download or manage plugins; it only
controls when they are sourced. This plays nicely with our model of using Nix to
manage plugins.

## Enabling Lazy Loading {#sec-lazy-enable}

Lazy loading is configured via `vim.lazy.plugins`, which accepts an attribute
set mapping plugin names to lazy-loading specifications:

```nix
{
  config.vim.lazy.plugins = {
    "my-plugin.nvim" = {
      package = pkgs.vimPlugins.my-plugin-nvim;

      # Mark the plugin as lazy. It will not load at startup.
      lazy = true;

      # Define at least one trigger to load the plugin.
      cmd = [ "MyPluginCommand" ];
    };
  };
}
```

If no trigger (`cmd`, `event`, `keys`, `ft`) is specified alongside
`lazy =
true`, the plugin will never be automatically loaded. You must call
`require("lz.n").load("my-plugin.nvim")` manually or define a trigger.
