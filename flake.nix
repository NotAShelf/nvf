{
  description = "A neovim flake with a modular configuration";
  outputs = {
    flake-parts,
    self,
    ...
  } @ inputs: let
    # call the extended library with `inputs`
    # inputs is used to get the original standard library, and to pass inputs to the plugin autodiscovery function
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
        ./flake/legacyPackages.nix
        ./flake/overlays.nix
        ./flake/packages.nix
        ./flake/develop.nix
      ];

      flake = {
        lib = {
          inherit (lib) nvim;
          inherit (lib.nvim) neovimConfiguration;
        };

        homeManagerModules = {
          nvf = import ./flake/modules/home-manager.nix {inherit lib self;};
          default = self.homeManagerModules.nvf;
          neovim-flake =
            lib.warn ''
              'homeManagerModules.neovim-flake' has been deprecated, and will be removed
              in a future release. Please use 'homeManagerModules.nvf' instead.
            ''
            self.homeManagerModules.nvf;
        };

        nixosModules = {
          nvf = import ./flake/modules/nixos.nix {inherit lib self;};
          default = self.nixosModules.nvf;
          neovim-flake =
            lib.warn ''
              'nixosModules.neovim-flake' has been deprecated, and will be removed
              in a future release. Please use 'nixosModules.nvf' instead.
            ''
            self.nixosModules.nvf;
        };

        inherit (lib.importJSON ./npins/sources.json) pins;
      };

      perSystem = {pkgs, ...}: {
        # Provide the default formatter. `nix fmt` in project root
        # will format available files with the correct formatter.
        # P.S: Please do not format with nixfmt! It messes with many
        # syntax elements and results in unreadable code.
        formatter = pkgs.alejandra;

        # Check if codebase is properly formatted.
        # This can be initiated with `nix build .#checks.<system>.nix-fmt`
        # or with `nix flake check`
        checks = {
          nix-fmt = pkgs.runCommand "nix-fmt-check" {nativeBuildInputs = [pkgs.alejandra];} ''
            alejandra --check ${self} < /dev/null | tee $out
          '';
        };
      };
    };

  # Flake inputs
  inputs = {
    ## Basic Inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    systems.url = "github:nix-systems/default";

    # Alternate neovim-wrapper
    mnw.url = "github:Gerg-L/mnw";

    # For generating documentation website
    nmd = {
      url = "sourcehut:~rycee/nmd";
      flake = false;
    };

    # Language servers (use master instead of nixpkgs)
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };
}
