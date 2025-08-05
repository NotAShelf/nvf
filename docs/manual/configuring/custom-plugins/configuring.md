# Configuring {#sec-configuring-plugins}

Just making the plugin to your Neovim configuration available might not always
be enough., for example, if the plugin requires a setup table. In that case, you
can write custom Lua configuration using one of

- `config.vim.lazy.plugins.*.setupOpts`
- `config.vim.extraPlugins.*.setup`
- `config.vim.luaConfigRC`.

## Lazy Plugins {#ch-vim-lazy-plugins}

`config.vim.lazy.plugins.*.setupOpts` is useful for lazy-loading plugins, and
uses an extended version of `lz.n's` `PluginSpec` to expose a familiar
interface. `setupModule` and `setupOpt` can be used if the plugin uses a
`require('module').setup(...)` pattern. Otherwise, the `before` and `after`
hooks should do what you need.

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

## Standard API {#ch-vim-extra-plugins}

`vim.extraPlugins` uses an attribute set, which maps DAG section names to a
custom type, which has the fields `package`, `after`, `setup`. They allow you to
set the package of the plugin, the sections its setup code should be after (note
that the `extraPlugins` option has its own DAG scope), and the its setup code
respectively. For example:

```nix
{pkgs, ...}: {
  config.vim.extraPlugins = {
    aerial = {
      package = pkgs.vimPlugins.aerial-nvim;
      setup = "require('aerial').setup {}";
    };

    harpoon = {
      package = pkgs.vimPlugins.harpoon;
      setup = "require('harpoon').setup {}";
      after = ["aerial"]; # place harpoon configuration after aerial
    };
  };
}
```

### Setup using luaConfigRC {#setup-using-luaconfigrc}

`vim.luaConfigRC` also uses an attribute set, but this one is resolved as a DAG
directly. The attribute names denote the section names, and the values lua code.
For example:

```nix
{
  # This will create a section called "aquarium" in the 'init.lua' with the
  # contents of your custom configuration. By default 'entryAnywhere' is implied
  # in DAGs, so this will be inserted to an arbitrary position. In the case you 
  # wish to control the position of this section with more precision, please
  # look into the DAGs section of the manual.
  config.vim.luaConfigRC.aquarium = "vim.cmd('colorscheme aquiarum')";
}
```

<!-- deno-fmt-ignore-start -->
[DAG system]: #ch-using-dags
[DAG section]: #ch-dag-entries

::: {.note}
One of the **greatest strengths** of **nvf** is the ability to order
configuration snippets precisely using the [DAG system]. DAGs
are a very powerful mechanism that allows specifying positions
of individual sections of configuration as needed. We provide helper functions
in the extended library, usually under `inputs.nvf.lib.nvim.dag` that you may
use.

Please refer to the [DAG section] in the nvf manual
to find out more about the DAG system.
:::
<!-- deno-fmt-ignore-end -->
