# Custom Plugins {#ch-custom-plugins}

**nvf**, by default, exposes a wide variety of plugins as module options for
your convenience and bundles necessary dependencies into **nvf**'s runtime. In
case a plugin is not available in **nvf**, you may consider making a pull
request to **nvf** to include it as a module or you may add it to your
configuration locally.

## Adding Plugins {#ch-adding-plugins}

There are multiple ways of adding custom plugins to your **nvf** configuration.

You can use custom plugins, before they are implemented in the flake. To add a
plugin to the runtime, you need to add it to the [](#opt-vim.startPlugins) list
in your configuration.

Adding a plugin to `startPlugins` will not allow you to configure the plugin
that you have added, but **nvf** provides multiple ways of configuring any custom
plugins that you might have added to your configuration.

```{=include=} sections
custom-plugins/configuring.md
custom-plugins/lazy-method.md
custom-plugins/non-lazy-method.md
custom-plugins/legacy-method.md
```
