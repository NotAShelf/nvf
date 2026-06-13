{
  inputs,
  self,
  config,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: let
    inherit (lib.filesystem) packagesFromDirectoryRecursive;
    inherit (lib.customisation) callPackageWith;
    inherit (lib.attrsets) recursiveUpdate;

    # Attribute set containing paths to specific profiles. This is meant to be
    # an easy path to where profiles are defined as the tests directory gets
    # more complicated, and allow easier renames.
    profiles = {
      # Minimal profile is small and lightweight. Plugins that require dependencies
      # or tests that are resource intensive should not use the minimal profile.
      minimal = ./profiles/minimal.nix;
    };

    modules = {
      nixos = config.flake.nixosModules;
      home-manager = config.flake.homeManagerModules;
    };

    # Call tests with preset special arguments.
    defaultInherits = {inherit inputs profiles modules;};
    callPackage = callPackageWith (recursiveUpdate pkgs defaultInherits);
    checkPackages = packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./checks;
    };
  in {
    # Machine tests that will be ran either manually with 'nix build .#checks.<system>.<check>'
    # or automatically on 'nix flake check' unless '--no-build-checks' has been passed to it.
    # We merge 'config.legacyPackages' here to make sure we also build and check plugin packages
    # that are declared in legacyPackages are built as well, which is usually reserved to Neovim
    # plugins tracked with npins.
    checks = checkPackages;
  };
}
