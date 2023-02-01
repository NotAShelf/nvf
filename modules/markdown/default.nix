{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./config.nix
    ./glow.nix
  ];
}
