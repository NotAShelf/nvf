## Standalone Installation on NixOS {#ch-standalone-nixos}

Your built Neovim configuration can be exposed as a flake output to make it
easier to share across machines, repositories and so on. Or it can be added to
your system packages to make it available across your system.

The following is an example installation of `nvf` as a standalone package with
the default theme enabled. You may use other options inside `config.vim` in
`configModule`, but this example will not cover that extensively.

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = {
    nixpkgs,
    nvf,
    self,
    ...
  }: {
    # This will make the package available as a flake output under 'packages'
    packages.x86_64-linux.my-neovim =
      (nvf.lib.neovimConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          # Or move this to a separate file and add it's path here instead
          # IE: ./nvf_module.nix
          (
            {pkgs, ...}: {
              # Add any custom options (and do feel free to upstream them!)
              # options = { ... };
              config.vim = {
                theme.enable = true;
                # and more options as you see fit...
              };
            }
          )
        ];
      })
      .neovim;

    # Example nixosConfiguration using the configured Neovim package
    nixosConfigurations = {
      yourHostName = nixpkgs.lib.nixosSystem {
        # ...
        modules = [
          # This will make wrapped neovim available in your system packages
          # Can also move this to another config file if you pass your own
          # inputs/self around with specialArgs
          ({pkgs, ...}: {
            environment.systemPackages = [self.packages.${pkgs.stdenv.system}.neovim];
          })
        ];
        # ...
      };
    };
  };
}
```
