# Legacy Method {#sec-legacy-method}

Prior to version 0.5, the method of adding new plugins was adding the plugin
package to `vim.startPlugins` and add its configuration as a DAG under one of
`vim.configRC` or `vim.luaConfigRC`. Users who have not yet updated to 0.5, or
prefer a more hands-on approach may use the old method where the load order of
the plugins is determined by DAGs.

## Adding plugins {#sec-adding-plugins}

To add a plugin to **nvf**'s runtime, you may add it

```nix
{pkgs, ...}: {
  # add a package from nixpkgs to startPlugins
  vim.startPlugins = [
    pkgs.vimPlugins.aerial-nvim  ];
}
```

And to configure the added plugin, you can use the `luaConfigRC` option to
provide configuration as a DAG using the **nvf** extended library.

```nix
{inputs, ...}: let
  # assuming you have an input called nvf pointing at the nvf repository
  inherit (inputs.nvf.lib.nvim.dag) entryAnywhere;
in {
  vim.luaConfigRC.aerial-nvim= entryAnywhere ''
    require('aerial').setup {
      -- your configuration here
    }
  '';
}
```
