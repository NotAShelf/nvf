# Adding Plugins {#sec-additional-plugins}

To add a new neovim plugin, first add the source url in the inputs section of `flake.nix`
with the prefix `plugin-`

```nix

{
  inputs = {
    # ...
    plugin-neodev-nvim = {
      url = "github:folke/neodev.nvim";
      flake = false;
    };
    # ...
  };
}
```

The addition of the `plugin-` prefix will allow neovim-flake to autodiscover the
input from the flake inputs automatically, allowing you to refer to it in areas
that require a very specific plugin type as defined in `lib/types/plugins.nix`

You can now reference this plugin using its string name, the plugin will be
built with the name and source URL from the flake input, allowing you to
refer to it as a **string**.

```nix
config.vim.startPlugins = ["neodev-nvim"];
```

## Modular setup options {#sec-modular-setup-options}

Most plugins is initialized with a call to `require('plugin').setup({...})`.

We use a special function that lets you easily add support for such setup options in a modular way:
`mkPluginSetupOption`.

Once you have added the source of the plugin as shown above, you can define the setup options like
this:

```nix
# in modules/.../your-plugin/your-plugin.nix

{lib, ...}:
let
  inherit (lib.types) bool int;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.your-plugin = {
    setupOpts = mkPluginSetupOption "plugin name" {
      enable_feature_a = mkOption {
        type = bool;
        default = false;
        # ...
      };

      number_option = mkOption {
        type = int;
        default = 3;
        # ...
      };
    };
  };
}
```

```nix
# in modules/.../your-plugin/config.nix
{lib, config, ...}:
let
  cfg = config.vim.your-plugin;
in {
  vim.luaConfigRC = lib.nvim.dag.entryAnywhere ''
    require('plugin-name').setup(${lib.nvim.lua.toLuaObject cfg.setupOpts})
  '';
}
```

This above config will result in this lua script:

```lua
require('plugin-name').setup({
  enable_feature_a = false,
  number_option = 3,
})
```

Now users can set any of the pre-defined option field, and can also add their own fields!

```nix
# in user's config
{
  vim.your-plugin.setupOpts = {
    enable_feature_a = true;
    number_option = 4;
    another_field = "hello";
    size = { # nested fields work as well
      top = 10;
    };
  };
}
```

## Details of toLuaObject {#sec-details-of-toluaobject}

As you've seen above, `toLuaObject` is used to convert our nix attrSet
`cfg.setupOpts`, into a lua table. Here are some rules of the conversion:

1. nix `null` converts to lua `nil`
2. number and strings convert to their lua counterparts
3. nix attrSet/list convert into lua tables
4. you can write raw lua code using `lib.generators.mkLuaInline`. This
   function is part of nixpkgs.

Example:

```nix
vim.your-plugin.setupOpts = {
  on_init = lib.generators.mkLuaInline ''
    function()
      print('we can write lua!')
    end
  '';
}
```
