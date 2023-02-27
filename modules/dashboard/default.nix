{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./alpha
    ./dashboard-nvim
    ./startify
  ];
}
