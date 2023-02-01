{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./lualine.nix
    ./config.nix
  ];
}
