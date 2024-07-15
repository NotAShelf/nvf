# DAG entries in nvf {#ch-dag-entries}

From the previous chapter, it should be clear that DAGs are useful, because you
can add code that relies on other code. However, if you don't know what the
entries are called, it's hard to do that, so here is a list of the internal
entries in nvf:

`vim.luaConfigRC` (top-level DAG):

1. (`luaConfigPre`) - not a part of the actual DAG, instead, it's simply
   inserted before the rest of the DAG
2. `globalsScript` - used to set globals defined in `vim.globals`
3. `basic` - used to set basic configuration options
4. `theme` - used to set up the theme, which has to be done before other plugins
5. `pluginConfigs` - the result of the nested `vim.pluginRC` (internal option,
   see the [Custom Plugins](./custom-plugins.md) page for adding your own
   plugins) DAG, used to set up internal plugins
6. `extraPluginConfigs` - the result of `vim.extraPlugins`, which is not a
   direct DAG, but is converted to, and resolved as one internally
7. `mappings` - the result of `vim.maps`
