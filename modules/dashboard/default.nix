{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    #./alpha-nvim.nix
    ./dashboard-nvim.nix
  ];
}
