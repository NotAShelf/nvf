{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./glow
    ./config.nix
    ./module.nix
  ];
}
