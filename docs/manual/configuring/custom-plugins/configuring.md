# Configuring {#sec-configuring-plugins}

Just making the plugin to your Neovim configuration available might not always be enough. In that
case, you can write custom lua config using either `config.vim.lazy.plugins.*.setupOpts`
`config.vim.extraPlugins.*.setup` or `config.vim.luaConfigRC`. 

The first option uses an extended version of `lz.n`'s PluginSpec. `setupModule` and `setupOpt` can
be used if the plugin uses a `require('module').setup(...)` pattern. Otherwise, the `before` and
`after` hooks should do what you need.

```nix
{
  config.vim.lazy.plugins = {
    aerial-nvim = {
      # ^^^^^^^^^ this name should match the package.pname or package.name
      package = aerial-nvim;

      setupModule = "aerial";
      setupOpts = {option_name = false;};

      after = "print('aerial loaded')";
    };
  };
}
```

The second option uses an attribute set, which maps DAG section names to a custom type, which has
the fields `package`, `after`, `setup`. They allow you to set the package of the plugin, the
sections its setup code should be after (note that the `extraPlugins` option has its own DAG
scope), and the its setup code respectively. For example:

```nix
config.vim.extraPlugins = with pkgs.vimPlugins; {
  aerial = {
    package = aerial-nvim;
    setup = "require('aerial').setup {}";
  };

  harpoon = {
    package = harpoon;
    setup = "require('harpoon').setup {}";
    after = ["aerial"]; # place harpoon configuration after aerial
  };
}
```

The third option also uses an attribute set, but this one is resolved as a DAG
directly. The attribute names denote the section names, and the values lua code.
For example:

```nix
{
  # this will create an "aquarium" section in your init.lua with the contents of your custom config
  # which will be *appended* to the rest of your configuration, inside your init.vim
  config.vim.luaConfigRC.aquarium = "vim.cmd('colorscheme aquiarum')";
}
```

:::{.note}
If your configuration needs to be put in a specific place in the config, you
can use functions from `inputs.nvf.lib.nvim.dag` to order it. Refer to
https://github.com/nix-community/home-manager/blob/master/modules/lib/dag.nix
to find out more about the DAG system.
:::

If you successfully made your plugin work, please feel free to create a PR to
add it to **nvf** or open an issue with your findings so that we can make it
available for everyone easily.
