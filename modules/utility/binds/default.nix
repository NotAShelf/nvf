{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./which-key
    ./cheatsheet
  ];
}
