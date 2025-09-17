# Overriding plugins {#ch-overriding-plugins}

The [additional plugins section](#sec-additional-plugins) details the addition
of new plugins to nvf under regular circumstances, i.e. while making a pull
request to the project. You may _override_ those plugins in your config to
change source versions, e.g., to use newer versions of plugins that are not yet
updated in **nvf**.

```nix
vim.pluginOverrides = {
  lazydev-nvim = pkgs.fetchFromGitHub {
    owner = "folke";
    repo = "lazydev.nvim";
    rev = "";
    hash = "";
  };
 # It's also possible to use a flake input
 lazydev-nvim = inputs.lazydev-nvim;
 # Or a local path 
 lazydev-nvim = ./lazydev;
 # Or a npins pin... etc
};
```

This will override the source for the `neodev.nvim` plugin that is used in nvf
with your own plugin.

::: {.warning}

While updating plugin inputs, make sure that any configuration that has been
deprecated in newer versions is changed in the plugin's `setupOpts`. If you
depend on a new version, requesting a version bump in the issues section is a
more reliable option.

:::
