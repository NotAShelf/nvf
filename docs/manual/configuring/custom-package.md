# Custom Neovim Package {#ch-custom-package}

As of v0.5, you may now specify the Neovim package that will be wrapped with
your configuration. This is done with the [](#opt-vim.package) option.

```nix
{inputs, pkgs, ...}: {
  # using the neovim-nightly overlay
  vim.package = inputs.neovim-overlay.packages.${pkgs.stdenv.system}.neovim;
}
```

The neovim-nightly-overlay always exposes an unwrapped package. If using a
different source, you are highly recommended to get an "unwrapped" version of
the neovim package, similar to `neovim-unwrapped` in nixpkgs.

```nix
{ pkgs, ...}: {
  # using the neovim-nightly overlay
  vim.package = pkgs.neovim-unwrapped;
}
```
