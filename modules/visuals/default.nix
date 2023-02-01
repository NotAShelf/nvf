{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./config.nix
    ./visuals.nix
  ];
}
