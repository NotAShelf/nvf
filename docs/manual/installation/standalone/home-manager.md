# Standalone Installation on Home-Manager {#ch-standalone-hm}

Your built Neovim configuration can be exposed as a flake output to make it
easier to share across machines, repositories and so on. Or it can be added to
your system packages to make it available across your system.

The following is an example installation of `nvf` as a standalone package with
the default theme enabled. You may use other options inside `config.vim` in
`configModule`, but this example will not cover that.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = {nixpkgs, home-manager, nvf, ...}: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    configModule = {
      # Add any custom options (and do feel free to upstream them!)
      # options = { ... };

      config.vim = {
        theme.enable = true;
        # and more options as you see fit...
      };
    };

    customNeovim = nvf.lib.neovimConfiguration {
      modules = [configModule];
      inherit pkgs;
    };
  in {
    # this will make the package available as a flake input
    packages.${system}.my-neovim = customNeovim.neovim;

    # this is an example home-manager configuration
    # using the built neovim package
    homeConfigurations = {
      "your-username@your-hostname" = home-manager.lib.homeManagerConfiguration {
        # ...
        modules = [
          ./home.nix

          # this will make wrapped neovim available in your system packages
          {environment.systemPackages = [customNeovim.neovim];}
        ];
        # ...
      };
    };
  };
}
```
