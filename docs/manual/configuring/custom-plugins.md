# Custom Plugins {#ch-custom-plugins}

Neovim-flake, by default, exposes a wide variety of plugins as module options
for your convience and bundles necessary dependencies into neovim-flake's
runtime. In case a plugin is not available in neovim-flake, you may consider
making a pull request to neovim-flake to include it as a module or you may add
it to your configuration locally.

## Adding Plugins {#ch-adding-plugins}

There are multiple ways of adding custom plugins to your neovim-flake
configuration.

You can use custom plugins, before they are implemented in the flake. To add a
plugin, you need to add it to your config's `vim.startPlugins` array.

Adding a plugin to `startPlugins` will not allow you to configure the plugin
that you have addeed, but neovim-flake provides multiple way of configuring any
custom plugins that you might have added to your configuration.

```{=include=} sections
custom-plugins/configuring.md
custom-plugins/new-method.md
custom-plugins/old-method.md
```
