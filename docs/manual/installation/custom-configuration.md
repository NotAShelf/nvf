# Standalone Installation {#ch-standalone-installation}

It is possible to install nvf without depending on NixOS or Home-Manager as the
parent module system, using the `neovimConfiguration` function exposed in the
extended library. This function will take `modules` and `extraSpecialArgs` as
arguments, and return the following schema as a result.

```nix
{
  options = "The options that were available to configure";
  config = "The outputted configuration";
  pkgs = "The package set used to evaluate the module";
  neovim = "The built neovim package";
}
```

An example flake that exposes your custom Neovim configuration might look like

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    packages."x86_64-linux" = let
        neovimConfigured = (inputs.nvf.lib.neovimConfiguration {
          inherit (nixpkgs.legacyPackages."x86_64-linux") pkgs;
          modules = [{
              config.vim = {
                # Enable custom theming options
                theme.enable = true;

                # Enable Treesitter
                tree-sitter.enable = true;

                # Other options will go here. Refer to the config
                # reference in Appendix B of the nvf manual.
                # ...
              };
          }];
        });
    in {
      # Set the default package to the wrapped instance of Neovim.
      # This will allow running your Neovim configuration with
      # `nix run` and in addition, sharing your configuration with
      # other users in case your repository is public.
      default = neovimConfigured.neovim;
    };
  };
}
```

<!-- TODO: mention the built-in flake template here when it is added -->

The next two chapters will detail specific usage of standalone nvf
configurations on NixOS and Home-Manager.

```{=include=} chapters
standalone/nixos.md
standalone/home-manager.md
```
