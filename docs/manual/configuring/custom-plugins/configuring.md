# Configuring {#sec-configuring-plugins}

Just making the plugin to your Neovim configuration available might not always
be enough. In that case, you can write custom vimscript or lua config, using
either `config.vim.configRC` or `config.vim.luaConfigRC` respectively. Both of
these options are attribute sets, and you need to give the configuration you're
adding some name, like this:

```nix
{
  # this will create an "aquarium" section in your init.vim with the contents of your custom config
  # which will be *appended* to the rest of your configuration, inside your init.vim
  config.vim.configRC.aquarium = "colorscheme aquiarum";
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
