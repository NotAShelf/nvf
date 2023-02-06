{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./which-key.nix
    ./cheatsheet.nix
  ];
}
