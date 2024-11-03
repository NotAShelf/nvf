# Lazy Method {#sec-lazy-method}

As of version **0.7**, we exposed an API for configuring lazy-loaded plugins via
`lz.n` and `lzn-auto-require`.

```nix
{
  config.vim.lazy.plugins = {
    aerial = {
      package = pkgs.vimPlugins.aerial-nvim;
      setupModule = aerial;
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
