# Home-Manager Module {#ch-hm-module}

The home-manager module allows us to customize the different `vim` options from
inside the home-manager configuration without having to call for the wrapper
yourself. It is the recommended way to use **nvf** alongside the NixOS module
depending on your needs.

To use it, we first add the input flake.

```nix
{
  inputs = {
    obsidian-nvim.url = "github:epwalsh/obsidian.nvim";
    nvf = {
      url = "github:notashelf/nvf";
      # you can override input nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
      # you can also override individual plugins
      # for example:
      inputs.obsidian-nvim.follows = "obsidian-nvim"; # <- this will use the obsidian-nvim from your inputs
    };
  };
}
```

Followed by importing the home-manager module somewhere in your configuration.

```nix
{
  # assuming nvf is in your inputs and inputs is in the argset
  # see example below
  imports = [ inputs.nvf.homeManagerModules.default ];
}
```

## Example Installation {#sec-example-installation-hm}

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = { nixpkgs, home-manager, nvf, ... }: let
  system = "x86_64-linux"; in {
    # ↓ this is your home output in the flake schema, expected by home-manager
    "your-username@your-hostname" = home-manager.lib.homeManagerConfiguration
      modules = [
        nvf.homeManagerModules.default # <- this imports the home-manager module that provides the options
        ./home.nix # <- your home entrypoint
      ];
    };
  };
}
```

Once the module is properly imported by your host, you will be able to use the
`programs.nvf` module option anywhere in your configuration in order to
configure **nvf**.

```nix{
  programs.nvf = {
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

::: {.note}

**nvf** exposes a lot of options, most of which are not referenced in the
installation sections of the manual. You may find all available options in the
[appendix](https://notashelf.github.io/nvf/options)

:::
