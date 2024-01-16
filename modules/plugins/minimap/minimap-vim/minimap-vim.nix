{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption;
in {
  options.vim.minimap.minimap-vim = {
    enable = mkEnableOption "minimap-vim plugin for minimap view";
  };
}
