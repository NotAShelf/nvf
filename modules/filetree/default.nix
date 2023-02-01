{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./nvimtreelua.nix
  ];
}
