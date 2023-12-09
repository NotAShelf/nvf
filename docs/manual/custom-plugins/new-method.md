# New Method {#sec-new-method}

As of version 0.5, we have a more extensive API for configuring plugins, under `vim.extraPlugins`.

Instead of using DAGs exposed by the library, you may use the extra plugin module as follows:

```nix
{
  config.vim.extraPlugins = with pkgs.vimPlugins; {
    aerial = {
      package = aerial-nvim;
      setup = ''
        require('aerial').setup {
          -- some lua configuration here
        }
      '';
    };

    harpoon = {
      package = harpoon;
      setup = "require('harpoon').setup {}";
      after = ["aerial"];
    };
  };
}
```
