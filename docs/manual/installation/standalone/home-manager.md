# Standalone Installation (home-manager) {#ch-standalone-home-manager}

The following is an example of a barebones vim configuration with the default theme enabled.

```nix
{
  inputs.neovim-flake = {
    url = "github:notashelf/neovim-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {nixpkgs, neovim-flake, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    configModule = {
      # Add any custom options (and feel free to upstream them!)
      # options = ...

      config.vim = {
        theme.enable = true;
      };
    };

    customNeovim = neovim-flake.lib.neovimConfiguration {
      modules = [configModule];
      inherit pkgs;
    };
  in {
    # this is an example nixosConfiguration using the built neovim package
    homeConfigurations = {
      yourHostName = home-manager.lib.nixosSystem {
        # TODO
      };
    };
  };
}
```
