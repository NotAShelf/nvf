# Custom Inputs {#ch-custom-inputs}

One of the greatest strengths of **nvf** is its ability to get plugins from
flake inputs and build them locally from any given source. For plugins that do
not require any kind of additional building step, this is a powerful method of
adding plugins to your configuration that are not packaged in nixpkgs, or those
you want to track from source without relying on nixpkgs.

The [additional plugins section](#sec-additional-plugins) details the addition
of new plugins to nvf under regular circumstances, i.e. while making a pull
request to the project. You may _override_ those plugin inputs in your own
`flake.nix` to change source versions, e.g., to use newer versions of plugins
that are not yet updated in **nvf**.

```nix
{

  inputs = {
    # ...

    # The name here is arbitrary, you can name it whatever.
    # This will add a plugin input called "your-neodev-input"
    # that you can reference in a `follows` line.
    your-neodev-input = {
      url = "github:folke/neodev.nvim";
      flake = false;
    };

    nvf = {
      url = "github:notashelf/nvf";

      # The name of the input must match for the follows line
      # plugin-neodev-nvim is what the input is called inside nvf
      # so you must match the exact name here.
      inputs.plugin-neodev-nvim.follows = "your-neodev-input";
    };
    # ...
  };
}
```

This will override the source for the `neodev.nvim` plugin that is used in nvf
with your own input. You can update your new input via `nix flake update` or
more specifically `nix flake update <name of your input>` to keep it up to date.

::: {.warning}

While updating plugin inputs, make sure that any configuration that has been
deprecated in newer versions is changed in the plugin's `setupOpts`. If you
depend on a new version, requesting a version bump in the issues section is a
more reliable option.

:::
