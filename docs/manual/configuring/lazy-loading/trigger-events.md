# Trigger Events {#sec-lazy-triggers}

nvf exposes four trigger mechanisms that tell `lz.n` when to load a lazy plugin.
Multiple triggers may be combined on the same plugin entry; the plugin loads on
whichever fires first.

## cmd {#sec-lazy-trigger-cmd}

Load the plugin the first time one of the listed Ex commands is invoked.

```nix
{
  config.vim.lazy.plugins = {
    "aerial.nvim" = {
      package = pkgs.vimPlugins.aerial-nvim;
      setupModule = "aerial";
      cmd = [ "AerialOpen" "AerialToggle" "AerialNavOpen" ];
    };
  };
}
```

The commands are registered as stubs at startup. When you run `:AerialOpen`, the
plugin loads and the real command executes.

## event {#sec-lazy-trigger-event}

Load the plugin when a Neovim autocommand event fires. Values are strings naming
standard Neovim events (`"BufEnter"`, `"InsertEnter"`, etc.) or structured
records with `event` and optional `pattern` fields.

```nix
{
  config.vim.lazy.plugins = {
    "indent-blankline.nvim" = {
      package = pkgs.vimPlugins.indent-blankline-nvim;
      setupModule = "ibl";
      event = [ "BufReadPost" "BufNewFile" ];
    };
  };
}
```

Using a structured record for pattern matching:

```nix
{
  config.vim.lazy.plugins = {
    "my-plugin.nvim" = {
      package = pkgs.vimPlugins.my-plugin-nvim;
      event = [
        { event = "BufReadPost"; pattern = "*.rs"; }
      ];
    };
  };
}
```

## keys {#sec-lazy-trigger-keys}

Load the plugin the first time a defined keybinding is pressed. Each entry is a
record with at minimum a `key` field.

```nix
{
  config.vim.lazy.plugins = {
    "aerial.nvim" = {
      package = pkgs.vimPlugins.aerial-nvim;
      setupModule = "aerial";
      keys = [
        {
          key = "<leader>a";
          action = ":AerialToggle<CR>";
          desc = "Toggle Aerial symbol outline";
        }
        {
          key = "<leader>A";
          action = ":AerialNavOpen<CR>";
          desc = "Open Aerial navigation";
        }
      ];
    };
  };
}
```

The keymaps are registered as pass-through stubs at startup. The first press
loads the plugin and re-fires the key.

## ft {#sec-lazy-trigger-ft}

Load the plugin when a buffer with a matching filetype is opened.

```nix
{
  config.vim.lazy.plugins = {
    "rust-tools.nvim" = {
      package = pkgs.vimPlugins.rust-tools-nvim;
      setupModule = "rust-tools";
      ft = [ "rust" ];
    };
  };
}
```

This is equivalent to listening on `FileType` events filtered by the listed
filetype names.
