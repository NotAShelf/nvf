# Adding Plugins {#sec-additional-plugins}

To add a new neovim plugin, first add the source url in the inputs section of `flake.nix`

```nix

{
  inputs = {
    # ...
    neodev-nvim = {
      url = "github:folke/neodev.nvim";
      flake = false;
    };
    # ...
  };
}
```

Then add the name of the plugin into the `availablePlugins` variable in `lib/types/plugins.nix`:

```nix
# ...
availablePlugins = [
  # ...
  "neodev-nvim"
];
```

You can now reference this plugin using its string name:

```nix
config.vim.startPlugins = ["neodev-nvim"];
```
