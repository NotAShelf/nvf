# Adding Plugins From Different Sources {#sec-plugin-sources}

**nvf** attempts to avoid depending on Nixpkgs for Neovim plugins. For the most
part, this is accomplished by defining each plugin's source and building them
from source.

[npins]: https://github.com/andir/npins

To define plugin sources, we use [npins] and pin each plugin source using
builtin fetchers. You are not bound by this restriction. In your own
configuration, any kind of fetcher or plugin source is fine.

## Nixpkgs & Friends {#ch-plugins-from-nixpkgs}

`vim.startPlugins` and `vim.optPlugins` options take either a **string**, in
which case a plugin from nvf's internal plugins registry will be used, or a
**package**. If your plugin does not require any setup, or ordering for it s
configuration, then it is possible to add it to `vim.startPlugins` to load it on
startup.

```nix
{pkgs, ...}: {
  # Aerial does require some setup. In the case you pass a plugin that *does*
  # require manual setup, then you must also call the setup function.
  vim.startPlugins = [pkgs.vimPlugins.aerial-nvim];
}
```

[`vim.extraPlugins`]: ./options.html#option-vim-extraPlugins

This will fetch aerial.nvim from nixpkgs, and add it to Neovim's runtime path to
be loaded manually. Although for plugins that require manual setup, you are
encouraged to use [`vim.extraPlugins`].

```nix
{
  vim.extraPlugins = {
    aerial = {
      package = pkgs.vimPlugins.aerial-nvim;
      setup = "require('aerial').setup {}";
    };
  };
}
```

[custom plugins section]: ./configuring.html#ch-custom-plugins

More details on the extraPlugins API is documented in the
[custom plugins section].

## Building Your Own Plugins {#ch-plugins-from-source}

In the case a plugin is not available in Nixpkgs, or the Nixpkgs package is
outdated (or, more likely, broken) it is possible to build the plugins from
source using a tool, such as [npins]. You may also use your _flake inputs_ as
sources.

Example using plugin inputs:

```nix
{
  # In your flake.nix
  inputs = {
    aerial-nvim = {
      url = "github:stevearc/aerial.nvim"
      flake = false;
    };
  };

  # Make sure that 'inputs' is properly propagated into Nvf, for example, through
  # specialArgs.
  outputs = { ... };
}
```

In the case, you may use the input directly for the plugin's source attribute in
`buildVimPlugin`.

```nix
# Make sure that 'inputs' is properly propagated! It will be missing otherwise
# and the resulting errors might be too obscure.
{inputs, ...}: let
  aerial-from-source = pkgs.vimUtils.buildVimPlugin {
      name = "aerial-nvim";
      src = inputs.aerial-nvim;
    };
in {
  vim.extraPlugins = {
    aerial = {
      package = aerial-from-source;
      setup = "require('aerial').setup {}";
    };
  };
}
```

Alternatively, if you do not want to keep track of the source using flake inputs
or npins, you may call `fetchFromGitHub` (or other fetchers) directly. An
example would look like this.

```nix
regexplainer = buildVimPlugin {
  name = "nvim-regexplainer";
  src = fetchFromGitHub {
    owner = "bennypowers";
    repo = "nvim-regexplainer";
    rev = "4250c8f3c1307876384e70eeedde5149249e154f";
    hash = "sha256-15DLbKtOgUPq4DcF71jFYu31faDn52k3P1x47GL3+b0=";
  };

  # The 'buildVimPlugin' imposes some "require checks" on all plugins build from
  # source. Failing tests, if they are not relevant, can be disabled using the
  # 'nvimSkipModule' argument to the 'buildVimPlugin' function.
  nvimSkipModule = [
    "regexplainer"
    "regexplainer.buffers.init"
    "regexplainer.buffers.popup"
    "regexplainer.buffers.register"
    "regexplainer.buffers.shared"
    "regexplainer.buffers.split"
    "regexplainer.component.descriptions"
    "regexplainer.component.init"
    "regexplainer.renderers.narrative.init"
    "regexplainer.renderers.narrative.narrative"
    "regexplainer.renderers.init"
    "regexplainer.utils.defer"
    "regexplainer.utils.init"
    "regexplainer.utils.treesitter"
  ];
}
```
