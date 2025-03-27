# Configuring {#sec-configuring-plugins}

Just making the plugin to your Neovim configuration available might not always
be enough. In that case, you can write custom lua config using either
`config.vim.lazy.plugins.*.setupOpts` `config.vim.extraPlugins.*.setup` or
`config.vim.luaConfigRC`.

The first option uses an extended version of `lz.n`'s PluginSpec. `setupModule`
and `setupOpt` can be used if the plugin uses a `require('module').setup(...)`
pattern. Otherwise, the `before` and `after` hooks should do what you need.

```nix
{
  config.vim.lazy.plugins = {
    aerial.nvim = {
    # ^^^^^^^^^ this name should match the package.pname or package.name
      package = aerial-nvim;

      setupModule = "aerial";
      setupOpts = {option_name = false;};

      after = "print('aerial loaded')";
    };
  };
}
```

The second option uses an attribute set, which maps DAG section names to a
custom type, which has the fields `package`, `after`, `setup`. They allow you to
set the package of the plugin, the sections its setup code should be after (note
that the `extraPlugins` option has its own DAG scope), and the its setup code
respectively. For example:

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

<!-- deno-fmt-ignore-start -->

::: {.note}
One of the greatest strengths of nvf is the ability to order
snippets of configuration via the DAG system. It will allow specifying positions
of individual sections of configuration as needed. nvf provides helper functions
in the extended library, usually under `inputs.nvf.lib.nvim.dag` that you may
use.

Please refer to the [DAG section](#ch-dag-entries) in the nvf manual
to find out more about the DAG system.
:::

<!-- deno-fmt-ignore-end -->
