# Home-Manager Module {#ch-hm-module}

The home-manager module allows us to customize the different `vim` options from
inside the home-manager configuration without having to call for the wrapper
yourself. It is the recommended way to use **nvf** alongside the NixOS module
depending on your needs.

To use it, we first add the input flake.

```nix
{
  inputs = {
    # Optional, if you intend to follow nvf's obsidian-nvim input
    # you must also add it as a flake input.
    obsidian-nvim.url = "github:epwalsh/obsidian.nvim";

    # Required, nvf works best and only directly supports flakes
    nvf = {
      url = "github:notashelf/nvf";
      # You can override the input nixpkgs to follow your system's
      # instance of nixpkgs. This is safe to do as nvf does not depend
      # on a binary cache.
      inputs.nixpkgs.follows = "nixpkgs";
      # Optionally, you can also override individual plugins
      # for example:
      inputs.obsidian-nvim.follows = "obsidian-nvim"; # <- this will use the obsidian-nvim from your inputs
    };
  };
}
```

Followed by importing the home-manager module somewhere in your configuration.

```nix
{
  # Assuming "nvf" is in your inputs and inputs is in the argument set.
  # See example installation below
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

  outputs = { nixpkgs, home-manager, nvf, ... }: {
    # ↓ this is your home output in the flake schema, expected by home-manager
    "your-username@your-hostname" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        nvf.homeManagerModules.default # <- this imports the home-manager module that provides the options
        ./home.nix # <- your home entrypoint, `programs.nvf.*` may be defined here
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
