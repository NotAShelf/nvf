## Using the Module Interface {#ch-module-interface}

Before describing the module interface, it is worth nothing that NVF is a hybrid
wrapper. It does not lock you into one of Lua or Nix, and both languages are
considered first-class citizens for configuring your editor. However, Nix is the
primarily supported language for NVF. While [DAGs](#ch-using-dags) allow for the
surgical insertion of Lua code into your configuration, in most cases you will
be more interested in using or extending the Nix-based module system.

### {#ch-using-modules}

Up until v0.6, most modules exposed all supported plugin options as individual
module options. With the release of v0.6, almost every module has been converted
to a new `setupOpts` format that provides complete user freedom over a plugin's
`setup({})` function.

The anatomy of a typical **plugin** module consists of two primary options:

`vim.<category>.<plugin>.enable` and `vim.<category>.<plugin>.setupOpts`. The
first option is disabled by default, and dictates whether the plugin is enabled.
If set to `true`, the plugin will be enabled and added to your Neovim's runtime
path. The second is an attribute set (`{}`) that will be converted to the
plugin's setup table. From Lua-based setups you may be used to something like
this:

```lua
require("nvim-autopairs").setup({
  check_ts = true,
  disable_filetype = { "TelescopePrompt", "vim" }
})
```

This is the typical setup table. It is sometimes expressed slightly differently
(e.g., the table might be stored as a variable) but the gist is that you pass a
table to the `setup()` function. The principle of `setupOpts` is the same. It
converts a Nix attribute set to a Lua table using the `toLuaObject` function
located in nvf's extended library. The same configuration would be expressed in
Nix as follows:

```nix
{
  setupOpts = {
    check_ts = true; # boolean
    disable_filetype = ["TelescopePrompt" "vim"]; # Lua table
  };
}
```

<!-- markdownlint-disable MD051 MD059 -->

The `setupOpts` option is freeform, so anything you put in it will be converted
to its Lua equivalent and will appear in your built `init.lua`. You can find
details about `toLuaObject` [here](#sec-details-of-toluaobject). The top-level
DAG entries in **nvf** are documented in the [DAG entries](#ch-dag-entries)
section. You can read more about DAGs in the [using DAGs](#ch-using-dags)
section.

<!-- markdownlint-enable MD051 MD059 -->
