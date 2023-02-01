{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./minimap-vim.nix
  ];
}
