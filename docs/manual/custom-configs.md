# Custom Configuration {#ch-custom-configuration}

Custom configuration is done with the `neovimConfiguration` while using the flake as a standalone package.
It takes in the configuration as a module. The output of the configuration function is an attrset.

```nix
{
  options = "The options that were available to configure";
  config = "The outputted configuration";
  pkgs = "The package set used to evaluate the module";
  neovim = "The built neovim package";
}
```

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
    # this will make the package available as a flake input
    packages.${system}.neovim = customNeovim.neovim;

    # this is an example nixosConfiguration using the built neovim package
    nixosConfigurations = {
      yourHostName = nixpkgs.lib.nixosSystem {
        # ...
        modules = [
          ./configuration.nix # or whatever your configuration is

          # this will make wrapped neovim available in your system packages
          {environment.systemPackages = [customNeovim.neovim];}
        ];
        # ...
      };
    };
  };
}
```

Your built neovim configuration can be exposed as a flake output, or be added to your system packages to make
it available across your system. You may also consider passing the flake output to home-manager to make it available
to a specific user _without_ using the home-manager module.
