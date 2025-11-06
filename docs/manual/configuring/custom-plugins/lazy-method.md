# Lazy Method {#sec-lazy-method}

As of version **0.7**, an API is exposed to allow configuring lazy-loaded
plugins via `lz.n` and `lzn-auto-require`. Below is a comprehensive example of
how it may be loaded to lazy-load an arbitrary plugin.

```nix
{
  config.vim.lazy.plugins = {
    "aerial.nvim" = {
      package = pkgs.vimPlugins.aerial-nvim;
      setupModule = "aerial";
      setupOpts = {
        option_name = true;
      };
      after = ''
        -- custom lua code to run after plugin is loaded
        print('aerial loaded')
      '';

      # Explicitly mark plugin as lazy. You don't need this if you define one of
      # the trigger "events" below
      lazy = true;

      # load on command
      cmd = ["AerialOpen"];

      # load on event
      event = ["BufEnter"];

      # load on keymap
      keys = [
        {
          key = "<leader>a";
          action = ":AerialToggle<CR>";
        }
      ];
    };
  };
}
```

## LazyFile event {#sec-lazyfile-event}

**nvf** re-implements `LazyFile` as a familiar user event to load a plugin when
a file is opened:

```nix
{
  config.vim.lazy.plugins = {
    "aerial.nvim" = {
      package = pkgs.vimPlugins.aerial-nvim;
      event = [{event = "User"; pattern = "LazyFile";}];
      # ...
    };
  };
}
```

You can consider the `LazyFile` event as an alias to the combination of
`"BufReadPost"`, `"BufNewFile"` and `"BufWritePre"`, i.e., a list containing all
three of those events: `["BufReadPost" "BufNewFile" "BufWritePre"]`
