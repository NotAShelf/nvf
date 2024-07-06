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

    defaultInherits = {
      inherit (config.flake) homeManagerModules nixosModules;
      inherit inputs;
      testProfile = ./profiles/minimal.nix;
    };

    callPackage = callPackageWith (recursiveUpdate pkgs defaultInherits);
  in {
    checks = packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./checks;
    };

    # expose checks as packages to be built
    packages = {
      test-home-manager-module = self'.checks.homeManagerModule.driverInteractive;
      test-nixos-module = self'.checks.nixosModule.driverInteractive;
    };
  };
}
