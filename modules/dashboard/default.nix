{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./alpha.nix
    ./dashboard-nvim.nix
    ./startify.nix
  ];
}
