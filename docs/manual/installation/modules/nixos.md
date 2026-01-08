## NixOS Module {#ch-nixos-module}

The NixOS module allows us to customize the different `vim` options from inside
the NixOS configuration without having to call for the wrapper yourself. It is
the recommended way to use **nvf** alongside the home-manager module depending
on your needs.

### With Flakes {#sec-nixos-flakes}

```{=include=}
flakes.md
```

### Usage {#sec-nixos-flakes-usage}

To use **nvf** with flakes, we first need to add the input to our `flake.nix`.

```nix
# flake.nix
{
  inputs = {
    # nvf works best with and only directly supports flakes
    nvf = {
      url = "github:NotAShelf/nvf";
      # You can override the input nixpkgs to follow your system's
      # instance of nixpkgs. This is safe to do as nvf does not depend
      # on a binary cache.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ...
  };
}
```

Followed by importing the NixOS module somewhere in your configuration.

```nix
{
  # Assuming nvf is in your inputs and inputs is in the argument set.
  # See example below.
  imports = [ inputs.nvf.nixosModules.default ];
}
```

### Example Installation {#sec-example-installation-nixos}

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = { nixpkgs, nvf, ... }: {
    # ↓ this is your host output in the flake schema
    nixosConfigurations."your-hostname" = nixpkgs.lib.nixosSystem {
      modules = [
        nvf.nixosModules.default # <- this imports the NixOS module that provides the options
        ./configuration.nix # <- your host entrypoint, `programs.nvf.*` may be defined here
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
    # Your settings need to go into the settings attribute set
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

## Without Flakes {#sec-nixos-flakeless}

As of v0.8, it is possible to install **nvf** on a system if you are not using
flakes. This is possible thanks to the flake-compat project.

To get started, you must fetch the repository using `builtins.fetchTarball` or a
similar mechanism.

```nix
# configuration.nix
let
  nvf = import (builtins.fetchTarball {
    url = "https://github.com/notashelf/nvf/archive/<commit or tag>.tar.gz";
    # Optionally, you can add 'sha256' for verification and caching
    # sha256 = "<sha256>";
  });
in {
  imports = [
    # Import the NixOS module from your fetched input
    nvf.nixosModules.nvf
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
