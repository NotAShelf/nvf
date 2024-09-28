# DAG entries in nvf {#ch-dag-entries}

From the previous chapter, it should be clear that DAGs are useful, because you
can add code that relies on other code. However, if you don't know what the
entries are called, it's hard to do that, so here is a list of the internal
entries in nvf:

## `vim.luaConfigRC` (top-level DAG) {#ch-vim-luaconfigrc}

1. (`luaConfigPre`) - not a part of the actual DAG, instead, it's simply
   inserted before the rest of the DAG
2. `globalsScript` - used to set globals defined in `vim.globals`
3. `basic` - used to set basic configuration options
4. `optionsScript` - used to set options defined in `vim.o`
5. `theme` (this is simply placed before `pluginConfigs`, meaning that
   surrounding entries don't depend on it) - used to set up the theme, which has
   to be done before other plugins
6. `pluginConfigs` - the result of the nested `vim.pluginRC` (internal option,
   see the [Custom Plugins](/index.xhtml#ch-custom-plugins) page for adding your
   own plugins) DAG, used to set up internal plugins
7. `extraPluginConfigs` - the result of `vim.extraPlugins`, which is not a
   direct DAG, but is converted to, and resolved as one internally
8. `mappings` - the result of `vim.maps`
