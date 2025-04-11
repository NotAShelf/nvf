# Non-lazy Method {#sec-non-lazy-method}

As of version **0.5**, we have a more extensive API for configuring plugins,
under `vim.extraPlugins`. Instead of using DAGs exposed by the library, you may
use the extra plugin module as follows:

```nix
{pkgs, ...}: {
  config.vim.extraPlugins = {
    aerial = {
      package = pkgs.vimPlugins.aerial-nvim;
      setup = ''
        require('aerial').setup {
          -- some lua configuration here
        }
      '';
    };

    harpoon = {
      package = pkgs.vimPlugins.harpoon;
      setup = "require('harpoon').setup {}";
      after = ["aerial"];
    };
  };
}
```
