{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./nvim-bufferline.nix
  ];
}
