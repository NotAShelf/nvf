# Adding Plugins {#sec-additional-plugins}

There are two methods for adding new Neovim plugins to **nvf**. npins is the
faster option that should be preferred if the plugin consists of pure Lua or
Vimscript code. In which case there is no building required, and we can easily
handle the copying of plugin files. Alternative method, which is required when
plugins try to build their own libraries (e.g., in Rust or C) that need to be
built with Nix to function correctly.

## With npins {#sec-npins-for-plugins}

npins is the standard method of adding new plugins to **nvf**. You simply need
the repository URL for the plugin, and can add it as a source to be built
automatically with one command. To add a new Neovim plugin, use `npins`. For
example:

```bash
nix-shell -p npins # or nix shell nixpkgs#npins if using flakes
```

Then run:

```bash
npins add --name <plugin name> github <owner> <repo> -b <branch>
```

::: {.note}

Be sure to replace any non-alphanumeric characters with `-` for `--name`. For
example

```bash
npins add --name lazydev-nvim github folke lazydev.nvim -b main
```

:::

Once the `npins` command is done, you can start referencing the plugin as a
**string**.

```nix
{
  config.vim.startPlugins = ["lazydev-nvim"];
}
```

## Packaging Complex Plugins {#sec-pkgs-for-plugins}

[blink.cmp]: https://github.com/Saghen/blink.cmp

Some plugins require additional packages to be built and substituted to function
correctly. For example [blink.cmp] requires its own fuzzy matcher library, built
with Rust, to be installed or else defaults to a much slower Lua implementation.
In the Blink documentation, you are advised to build with `cargo` but that is
not ideal since we are leveraging the power of Nix. In this case the ideal
solution is to write a derivation for the plugin.

We use `buildRustPackage` to build the library from the repository root, and
copy everything in the `postInstall` phase.

```nix
postInstall = ''
  cp -r {lua,plugin} "$out"

  mkdir -p "$out/doc"
  cp 'doc/'*'.txt' "$out/doc/"

  mkdir -p "$out/target"
  mv "$out/lib" "$out/target/release"
'';
```

In a similar fashion, you may utilize `stdenv.mkDerivation` and other Nixpkgs
builders to build your library from source, and copy the relevant files and Lua
plugin files in the `postInstall` phase. Do note, however, that you still need
to fetch the plugin sources somehow. npins is, once again, the recommended
option to fetch the plugin sources. Refer to the previous section on how to use
npins to add a new plugin.

Plugins built from source must go into the `flake/pkgs/by-name` overlay. It will
automatically create flake outputs for individual packages. Lastly, you must add
your package to the plugin builder (`pluginBuilders`) function manually in
`modules/wrapper/build/config.nix`. Once done, you may refer to your plugin as a
**string**.

```nix
{
  config.vim.startPlugins = ["blink-cmp"];
}
```

## Modular setup options {#sec-modular-setup-options}

Most plugins is initialized with a call to `require('plugin').setup({...})`.

We use a special function that lets you easily add support for such setup
options in a modular way: `mkPluginSetupOption`.

Once you have added the source of the plugin as shown above, you can define the
setup options like this:

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

This above config will result in this Lua script:

```lua
require('plugin-name').setup({
  enable_feature_a = false,
  number_option = 3,
})
```

Now users can set any of the pre-defined option field, and can also add their
own fields!

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

1. Nix `null` converts to lua `nil`
2. Number and strings convert to their lua counterparts
3. Nix attribute sets (`{}`) and lists (`[]`) convert into Lua dictionaries and
   tables respectively. Here is an example of Nix -> Lua conversion.
   - `{foo = "bar"}` -> `{["foo"] = "bar"}`
   - `["foo" "bar"]` -> `{"foo", "bar"}`
4. You can write raw Lua code using `lib.generators.mkLuaInline`. This function
   is part of nixpkgs, and is accessible without relying on **nvf**'s extended
   library.
   - `mkLuaInline "function add(a, b) return a + b end"` will yield the
     following result:

   ```nix
   {
    _type = "lua-inline";
    expr = "function add(a, b) return a + b end";
   }
   ```

   The above expression will be interpreted as a Lua expression in the final
   config. Without the `mkLuaInline` function, you will only receive a string
   literal. You can use it to feed plugin configuration tables Lua functions
   that return specific values as expected by the plugins.

   ```nix
   {
      vim.your-plugin.setupOpts = {
        on_init = lib.generators.mkLuaInline ''
          function()
            print('we can write lua!')
          end
        '';
      };
   }
   ```

## Lazy plugins {#sec-lazy-plugins}

If the plugin can be lazy-loaded, `vim.lazy.plugins` should be used to add it.
Lazy plugins are managed by `lz.n`.

```nix
# in modules/.../your-plugin/config.nix
{config, ...}: let
  cfg = config.vim.your-plugin;
in {
  vim.lazy.plugins.your-plugin = {
    # Instead of vim.startPlugins, use this:
    package = "your-plugin";

    # ıf your plugin uses the `require('your-plugin').setup{...}` pattern
    setupModule = "your-plugin";
    inherit (cfg) setupOpts;

    # Events that trigger this plugin to be loaded
    event = ["DirChanged"];
    cmd = ["YourPluginCommand"];

    # Plugin Keymaps
    keys = [
      # We'll cover this in detail in the 'keybinds' section
      {
        key = "<leader>d";
        mode = "n";
        action = ":YourPluginCommand";
      }
    ];
  };
}
```

This results in the following lua code:

```lua
require('lz.n').load({
  {
    "name-of-your-plugin",
    after = function()
      require('your-plugin').setup({
        --[[ your setupOpts ]]--
      })
    end,

    event = {"DirChanged"},
    cmd = {"YourPluginCommand"},
    keys = {
      {"<leader>d", ":YourPluginCommand", mode = {"n"}},
    },
  }
})
```

[`vim.lazy.plugins` spec]: https://notashelf.github.io/nvf/options.html#opt-vim.lazy.plugins

A full list of options can be found in the [`vim.lazy.plugins` spec] on the
rendered manual.
