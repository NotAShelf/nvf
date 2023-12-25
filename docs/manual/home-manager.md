# Home Manager {#ch-hm-module}

The Home Manager module allows us to customize the different `vim` options from inside the home-manager configuration
and it is the preferred way of configuring neovim-flake, both on NixOS and non-NixOS systems.

To use it, we first add the input flake.

```nix
{
  neovim-flake = {
    url = github:notashelf/neovim-flake;
    # you can override input nixpkgs
    inputs.nixpkgs.follows = "nixpkgs";
    # you can also override individual plugins
    # i.e inputs.obsidian-nvim.follows = "obsidian-nvim"; # <- obsidian nvim needs to be in your inputs
  };
}
```

Followed by importing the home-manager module somewhere in your configuration.

```nix
{
  # assuming neovim-flake is in your inputs and inputs is in the argset
  imports = [ inputs.neovim-flake.homeManagerModules.default ];
}
```

An example installation for standalone home-manager would look like this:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    stylix.url = "github:notashelf/neovim-flake";
  };

  outputs = { nixpkgs, home-manager, neovim-flake ... }: let
  system = "x86_64-linux"; in {
    # ↓ this is the home-manager output in the flake schema
    homeConfigurations."yourUsername»" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        neovim-flake.homeManagerModules.default # <- this imports the home-manager module that provides the options
        ./home.nix # your home-manager configuration, probably where you will want to add programs.neovim-flake options
      ];
    };
  };
}
```

Once the module is imported, we will be able to define the following options (and much more) from inside the
home-manager configuration.

```nix{
  programs.neovim-flake = {

    enable = true;
    # your settings need to go into the settings attribute set
    # most settings are documented in the appendix
    settings = {
      vim.viAlias = false;
      vim.vimAlias = true;
      vim.lsp = {
        enable = true;
      };
    };
  };
}
```

:::{.note}
You may find all avaliable options in the [appendix](https://notashelf.github.io/neovim-flake/options)
:::
