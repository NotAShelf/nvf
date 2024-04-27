# Standalone Installation {#ch-standalone-installation}

It is possible to install **nvf** without depending on NixOS or home-manager as the parent
module system, using the `neovimConfiguration` function exposed by **nvf** extended library.
It takes in the configuration as a module, and returns an attribute set as a result.

```nix
{
  options = "The options that were available to configure";
  config = "The outputted configuration";
  pkgs = "The package set used to evaluate the module";
  neovim = "The built neovim package";
}
```

```{=include=} chapters
standalone/nixos.md
standalone/home-manager.md
```
