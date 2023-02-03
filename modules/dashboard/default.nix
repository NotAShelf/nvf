{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./config.nix
    #./alpha-nvim.nix
    ./dashboard-nvim.nix
  ];
}
