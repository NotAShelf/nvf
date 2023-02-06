{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./minimap-vim.nix
    ./codewindow.nix
  ];
}
