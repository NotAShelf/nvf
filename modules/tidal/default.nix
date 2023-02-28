{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./tidal.nix
    ./config.nix
  ];
}
