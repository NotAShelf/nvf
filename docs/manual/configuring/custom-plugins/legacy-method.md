# Legacy Method {#sec-legacy-method}

Prior to version **0.5**, the method of adding new plugins was adding the plugin
package to {option}`vim.startPlugins` and adding its configuration as a DAG
under one of `vim.configRC` or {option}`vim.luaConfigRC`. While `configRC` has
been deprecated, users who have not yet updated to 0.5 or those who prefer a
more hands-on approach may choose to use the old method where the load order of
the plugins is explicitly determined by DAGs without internal abstractions.

## Adding New Plugins {#sec-adding-new-plugins}

To add a plugin not available in **nvf** as a module to your configuration using
the legacy method, you must add it to {option}`vim.startPlugins` in order to
make it available to Neovim at runtime.

```nix
{pkgs, ...}: {
  # Add a Neovim plugin from Nixpkgs to the runtime.
  # This does not need to come explicitly from packages. 'vim.startPlugins'
  # takes a list of *string* (to load internal plugins) or *package* to load
  # a Neovim package from any source.
  vim.startPlugins = [pkgs.vimPlugins.aerial-nvim];
}
```

Once the package is available in Neovim's runtime, you may use the `luaConfigRC`
option to provide configuration as a DAG using the **nvf** extended library in
order to configure the added plugin,

```nix
{inputs, ...}: let
  # This assumes you have an input called 'nvf' in your flake inputs
  # and 'inputs' in your specialArgs. In the case you have passed 'nvf'
  # to specialArgs, the 'inputs' prefix may be omitted.
  inherit (inputs.nvf.lib.nvim.dag) entryAnywhere;
in {
  # luaConfigRC takes Lua configuration verbatim and inserts it at an arbitrary
  # position by default or if 'entryAnywhere' is used.
  vim.luaConfigRC.aerial-nvim= entryAnywhere ''
    require('aerial').setup {
      -- your configuration here
    }
  '';
}
```
