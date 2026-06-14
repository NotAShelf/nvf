{
  description = "A neovim flake with a modular configuration";
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    systems = nixpkgs.lib.systems.flakeExposed;

    # Provide simple per-system abstraction
    # giving you the system and
    # the package set for that system directly.
    eachSystem = f:
      nixpkgs.lib.genAttrs systems
      (system: f system nixpkgs.legacyPackages.${system});

    # Call the extended library with `inputs`.
    # inputs is used to get the original standard library, and to pass inputs
    # to the plugin autodiscovery function
    lib = import ./lib/stdlib-extended.nix {inherit inputs self;};
  in {
    lib = {
      inherit (lib) nvim;
      inherit (lib.nvim) neovimConfiguration;
    };

    inherit (lib.importJSON ./npins/sources.json) pins;

    homeManagerModules = {
      nvf = import ./flake/modules/home-manager.nix {inherit lib inputs;};
      default = self.homeManagerModules.nvf;
      neovim-flake =
        lib.warn ''
          'homeManagerModules.neovim-flake' has been deprecated, and will be removed
          in a future release. Please use 'homeManagerModules.nvf' instead.
        ''
        self.homeManagerModules.nvf;
    };

    nixosModules = {
      nvf = import ./flake/modules/nixos.nix {inherit lib inputs;};
      default = self.nixosModules.nvf;
      neovim-flake =
        lib.warn ''
          'nixosModules.neovim-flake' has been deprecated, and will be removed
          in a future release. Please use 'nixosModules.nvf' instead.
        ''
        self.nixosModules.nvf;
    };

    darwinModules = {
      nvf = import ./flake/modules/nixos.nix {inherit lib inputs;};
      default = self.darwinModules.nvf;
    };

    # Provides the default formatter for 'nix fmt', which will format the
    # entire Nix source with Alejandra. The wrapper script is necessary due to
    # changes to the behaviour of Nix, which now encourages wrappers for
    # tree-wide formatting.
    formatter = eachSystem (
      _: pkgs:
        pkgs.writeShellApplication {
          name = "nix3-fmt-wrapper";

          runtimeInputs = [
            pkgs.alejandra
            pkgs.fd
            pkgs.deno
          ];

          text = ''
            # Find Nix files in the tree and format them with Alejandra
            echo "Formatting Nix files"
            fd "$@" -t f -e nix -x alejandra -q '{}'

            # Same for Markdown files, but with deno
            echo "Formatting Markdown files"
            fd "$@" -t f -e md -x deno fmt -q '{}'
          '';
        }
    );

    # Provides checks to be built an ran on 'nix flake check'. They can also
    # be built individually with 'nix build' as described below.
    checks = eachSystem (_: pkgs: {
      # Check if codebase is properly formatted.
      # This can be initiated with `nix build .#checks.<system>.nix-fmt`
      # or with `nix flake check`
      nix-fmt =
        pkgs.runCommand "nix-fmt-check"
        {
          src = self;
          nativeBuildInputs = [pkgs.alejandra pkgs.fd];
        } ''
          cd "$src"
          fd -t f -e nix -x alejandra --check '{}'
          touch $out
        '';

      # Check if Markdown sources are properly formatted
      # This can be initiated with `nix build .#checks.<system>.md-fmt`
      # or with `nix flake check`
      md-fmt =
        pkgs.runCommand "md-fmt-check" {
          src = self;
          nativeBuildInputs = [pkgs.deno pkgs.fd];
        } ''
          cd "$src"
          fd -t f -e md -x deno fmt --check '{}'
          touch $out
        '';
    });

    templates = import ./flake/templates;

    apps = eachSystem (system: _: let
      inherit (lib.meta) getExe;
    in {
      nix = {
        type = "app";
        program = getExe self.packages.${system}.nix;
        meta = {};
      };
      maximal = {
        type = "app";
        program = getExe self.packages.${system}.maximal;
        meta = {};
      };
      default = self.apps.${system}.nix;
    });

    packages = let
      inherit (lib.attrsets) recursiveUpdate;
    in
      recursiveUpdate
      (eachSystem (system: _: import ./flake/packages.nix {inherit inputs lib self system;}))
      (eachSystem (_: pkgs: {
        # This package exists to make development easier by providing the place and
        # boilerplate to build a test nvf configuration. Feel free to use this for
        # testing, but make sure to discard the changes before creating a pull
        # request.
        dev = let
          configuration = {
            # This is essentially the configuration that will be passed to the
            # builder function. For example:
            # vim.languages.nix.enable = true;
          };

          customNeovim = lib.nvim.neovimConfiguration {
            inherit pkgs;
            modules = [configuration];
          };
        in
          customNeovim.neovim;
      }));

    devShells = eachSystem (_: pkgs: {
      # The default dev shell provides packages required to interact with
      # the codebase as described by the contributing guidelines. It includes the
      # formatters required, and a few additional goodies for linting work.
      default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          # Nix tooling
          nil # LSP
          statix # static checker
          deadnix # dead code finder

          # So that we can interact with plugin sources
          npins

          # Formatters
          alejandra
          deno
        ];
      };
    });
  };

  inputs = {
    ## Basic Inputs
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    flake-compat = {
      url = "git+https://git.lix.systems/lix-project/flake-compat.git";
      flake = false;
    };

    # Alternate neovim-wrapper
    mnw.url = "github:Gerg-L/mnw";

    # Alternative documentation generator
    ndg = {
      url = "github:feel-co/ndg?ref=refs/tags/v2.8.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
