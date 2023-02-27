{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./minimap-vim
    ./codewindow
  ];
}
