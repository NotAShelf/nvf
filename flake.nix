{
  description = "A neovim flake with a modular configuration";
  outputs = {
    flake-parts,
    self,
    ...
  } @ inputs: let
    # Call the extended library with `inputs`.
    # inputs is used to get the original standard library, and to pass inputs
    # to the plugin autodiscovery function
    lib = import ./lib/stdlib-extended.nix {inherit inputs self;};
  in
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {inherit lib;};
    } {
      # Allow users to bring their own systems.
      # «https://github.com/nix-systems/nix-systems»
      systems = import inputs.systems;
      imports = [
        ./flake/templates
        ./flake/apps.nix
        ./flake/packages.nix
        ./flake/develop.nix
      ];

      flake = {
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
      };

      perSystem = {pkgs, ...}: {
        # Provides the default formatter for 'nix fmt', which will format the
        # entire tree with Alejandra. The wrapper script is necessary due to
        # changes to the behaviour of Nix, which now encourages wrappers for
        # tree-wide formatting.
        formatter = pkgs.writeShellApplication {
          name = "nix3-fmt-wrapper";

          runtimeInputs = [
            pkgs.alejandra
            pkgs.fd
          ];

          text = ''
            # Find Nix files in the tree and format them with Alejandra
            fd "$@" -t f -e nix -x alejandra -q '{}'
          '';
        };

        # Provides checks to be built an ran on 'nix flake check'. They can also
        # be built individually with 'nix build' as described below.
        checks = {
          # Check if codebase is properly formatted.
          # This can be initiated with `nix build .#checks.<system>.nix-fmt`
          # or with `nix flake check`
          nix-fmt = pkgs.runCommand "nix-fmt-check" {nativeBuildInputs = [pkgs.alejandra];} ''
            alejandra --check ${self} < /dev/null | tee $out
          '';
        };
      };
    };

  inputs = {
    systems.url = "github:nix-systems/default";

    ## Basic Inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    flake-compat = {
      url = "git+https://git.lix.systems/lix-project/flake-compat.git";
      flake = false;
    };

    # Alternate neovim-wrapper
    mnw.url = "github:Gerg-L/mnw";
  };
}
