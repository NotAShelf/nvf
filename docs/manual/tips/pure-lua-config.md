# Pure Lua Configuration {#sec-pure-lua-config}

We recognize that you might not always want to configure your setup purely in
Nix, sometimes doing things in Lua is simply the "superior" option. In such a
case you might want to configure your Neovim instance using Lua, and nothing but
Lua. It is also possible to mix Lua and Nix configurations through the following
method.

## Custom Configuration Directory {#sec-custom-config-dir}

[Neovim 0.9]: https://github.com/neovim/neovim/pull/22128

As of [Neovim 0.9], {var}`$NVIM_APPNAME` is a variable expected by Neovim to
decide on the configuration directory. nvf sets this variable as `"nvf"`,
meaning `~/.config/nvf` will be regarded as _the_ configuration directory by
Neovim, similar to how `~/.config/nvim` behaves in regular installations. This
allows some degree of Lua configuration, backed by our low-level wrapper
[mnw](https://github.com/Gerg-L/mnw). Creating a `lua/` directory located in
`$NVIM_APPNAME` ("nvf" by default) and placing your configuration in, e.g.,
`~/.config/nvf/lua/myconfig` will allow you to `require` it as a part of the Lua
module system through nvf's module system.

Let's assume your `~/.config/nvf/lua/myconfig/init.lua` consists of the
following:

```lua
-- init.lua
vim.keymap.set("n", " ", "<Nop>", { silent = true, remap = false })
vim.g.mapleader = " "
```

The following Nix configuration via [](#opt-vim.luaConfigRC) will allow loading
this

```nix
{
  # The attribute name "myconfig-dir" here is arbitrary. It is required to be
  # a *named* attribute by the DAG system, but the name is entirely up to you.
  vim.luaConfigRC.myconfig-dir = ''
    require("myconfig")

    -- Any additional Lua
  '';
}
```

[DAG system]: https://notashelf.github.io/nvf/index.xhtml#ch-using-dags

After you load your custom configuration, you may use an `init.lua` located in
your custom configuration directory to configure Neovim exactly as you would
without a wrapper like nvf. If you want to place your `require` call in a
specific position (i.e., before or after options you set in nvf) the
[DAG system] will let you place your configuration in a location of your
choosing.

[top-level DAG system]: https://notashelf.github.io/nvf/index.xhtml#ch-vim-luaconfigrc
