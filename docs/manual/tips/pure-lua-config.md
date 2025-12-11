# Pure Lua Configuration {#sec-pure-lua-config}

We recognize that you might not always want to configure your setup purely in
Nix, sometimes doing things in Lua is simply the "superior" option. In such a
case you might want to configure your Neovim instance using Lua, and nothing but
Lua. It is also possible to mix Lua and Nix configurations.

Pure Lua or hybrid Lua/Nix configurations can be achieved in two different ways.
_Purely_, by modifying Neovim's runtime directory or _impurely_ by placing Lua
configuration in a directory found in `$HOME`. For your convenience, this
section will document both methods as they can be used.

## Pure Runtime Directory {#sec-pure-nvf-runtime}

As of 0.6, nvf allows you to modify Neovim's runtime path to suit your needs.
One of the ways the new runtime option is to add a configuration **located
relative to your `flake.nix`**, which must be version controlled in pure flakes
manner.

```nix
{
  # Let us assume we are in the repository root, i.e., the same directory as the
  # flake.nix. For the sake of the argument, we will assume that the Neovim lua
  # configuration is in a nvim/ directory relative to flake.nix.
  vim = {
    additionalRuntimePaths = [
      # This will be added to Neovim's runtime paths. Conceptually, this behaves
      # very similarly to ~/.config/nvim but you may not place a top-level
      # init.lua to be able to require it directly.
      ./nvim
    ];
  };
}
```

This will add the `nvim` directory, or rather, the _store path_ that will be
realised after your flake gets copied to the Nix store, to Neovim's runtime
directory. You may now create a `lua/myconfig` directory within this nvim
directory, and call it with {option}`vim.luaConfigRC`.

```nix
{pkgs, ...}: {
  vim = {
    additionalRuntimePaths = [
      # You can list more than one file here.
      ./nvim-custom-1

      # To make sure list items are ordered, use lib.mkBefore or lib.mkAfter
      # Simply placing list items in a given order will **not** ensure that
      # this list  will be deterministic.
      ./nvim-custom-2
    ];

    startPlugins = [pkgs.vimPlugins.gitsigns];

    # Neovim supports in-line syntax highlighting for multi-line strings.
    # Simply place the filetype in a /* comment */ before the line.
    luaConfigRC.myconfig = /* lua */ ''
      -- Call the Lua module from ./nvim/lua/myconfig
      require("myconfig")

      -- Any additional Lua configuration that you might want *after* your own
      -- configuration. For example, a plugin setup call.
      require('gitsigns').setup({})
    '';
  };
}
```

## Impure Absolute Directory {#sec-impure-absolute-dir}

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

The following Nix configuration via {option}`vim.luaConfigRC` will allow loading
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

[DAG system]: ./configuring.html#ch-using-dags

After you load your custom configuration, you may use an `init.lua` located in
your custom configuration directory to configure Neovim exactly as you would
without a wrapper like nvf. If you want to place your `require` call in a
specific position (i.e., before or after options you set in nvf) the
[DAG system] will let you place your configuration in a location of your
choosing.

[top-level DAG system]: https://notashelf.github.io/nvf/index.xhtml#ch-vim-luaconfigrc
