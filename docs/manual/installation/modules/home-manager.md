# Home-Manager Module {#ch-hm-module}

The home-manager module allows us to customize the different `vim` options from
inside the home-manager configuration without having to call for the wrapper
yourself. It is the recommended way to use **nvf** alongside the NixOS module
depending on your needs.

## With Flakes {#sec-hm-flakes}

```{=include=}
flakes.md
```

### Usage {#sec-hm-flakes-usage}

To use **nvf** with flakes, we first need to add the input to our `flake.nix`.

```nix
# flake.nix
{
  inputs = {
    # Optional, if you intend to follow nvf's obsidian-nvim input
    # you must also add it as a flake input.
    obsidian-nvim.url = "github:epwalsh/obsidian.nvim";

    # Required, nvf works best and only directly supports flakes
    nvf = {
      url = "github:NotAShelf/nvf";
      # You can override the input nixpkgs to follow your system's
      # instance of nixpkgs. This is safe to do as nvf does not depend
      # on a binary cache.
      inputs.nixpkgs.follows = "nixpkgs";
      # Optionally, you can also override individual plugins
      # for example:
      inputs.obsidian-nvim.follows = "obsidian-nvim"; # <- this will use the obsidian-nvim from your inputs
    };

    # ...
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

### Example Installation {#sec-example-installation-hm}

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

```nix
{
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

## Without Flakes {#sec-hm-flakeless}

As of v0.8, it is possible to install **nvf** on a system if you are not using
flakes. This is possible thanks to the flake-compat project.

To get started, you must fetch the repository using `builtins.fetchTarball` or a
similar mechanism.

```nix
# home.nix
let
  nvf = import (builtins.fetchTarball {
    url = "https://github.com/notashelf/nvf/archive/<commit or tag>.tar.gz";
    # Optionally, you can add 'sha256' for verification and caching
    # sha256 = "<sha256>";
  });
in {
  imports = [
    # Import the NixOS module from your fetched input
    nvf.homeManagerModules.nvf
  ];

  # Once the module is imported, you may use `programs.nvf` as exposed by the
  # NixOS module.
  programs.nvf.enable = true;
}
```

[npins]: https://github.com/andir/npins
[niv]: https://github.com/nmattia/niv

::: {.tip}

Nix2 does not have a builtin lockfile mechanism like flakes. As such you must
manually update the URL and hash for your input. This is annoying to deal with,
and most users choose to defer this task to projects such as [npins] or [niv].
If you are new to NixOS, I encourage you to look into Flakes and see if they fit
your use case. Alternatively, look into the aforementioned projects for more
convenient dependency management mechanisms.

:::
