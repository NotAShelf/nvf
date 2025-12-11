# Custom Plugins {#ch-custom-plugins}

**nvf** exposes a very wide variety of plugins by default, which are consumed by
module options. This is done for your convenience, and to bundle all necessary
dependencies into **nvf**'s runtime with full control of versioning, testing and
dependencies. In the case a plugin you need is _not_ available, you may consider
making a pull request to add the package you're looking for, or you may add it
to your configuration locally. The below section describes how new plugins may
be added to the user's configuration.

## Adding Plugins {#ch-adding-plugins}

Per **nvf**'s design choices, there are several ways of adding custom plugins to
your configuration as you need them. As we aim for extensive configuration, it
is possible to add custom plugins (from nixpkgs, pinning tools, flake inputs,
etc.) to your Neovim configuration before they are even implemented in **nvf**
as a module.

:::{.info}

To add a plugin to your runtime, you will need to add it to
{option}`vim.startPlugins` list in your configuration. This is akin to cloning a
plugin to `~/.config/nvim`, but they are only ever placed in the Nix store and
never exposed to the outside world for purity and full isolation.

:::

As you would configure a cloned plugin, you must configure the new plugins that
you've added to `startPlugins.` **nvf** provides multiple ways of configuring
any custom plugins that you might have added to your configuration.

```{=include=} sections
custom-plugins/configuring.md
custom-plugins/lazy-method.md
custom-plugins/non-lazy-method.md
custom-plugins/legacy-method.md
```
