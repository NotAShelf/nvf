{
  inputs,
  config,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: let
    inherit (lib.filesystem) packagesFromDirectoryRecursive;
    inherit (lib.customisation) callPackageWith;
    inherit (lib.attrsets) recursiveUpdate;

    # Attribute set containing paths to specific profiles. This is meant to be
    # an easy path to where profiles are defined as the tests directory gets
    # more complicated, and allow easier renames.
    profiles = {
      minimal = ./profiles/minimal.nix;
    };

    # Attributes to pass to all builder packages.
    defaultInherits = {
      inherit inputs profiles;
      inherit (config.flake) homeManagerModules nixosModules;
    };

    callPackage = callPackageWith (recursiveUpdate pkgs defaultInherits);
  in {
    checks = packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./checks;
    };

    # Expose checks as packages to be built
    packages.test = self'.checks.home-manager-test.driverInteractive;
  };
}
