{lib, ...}: let
  inherit (lib.options) mkEnableOption;
in {
  options.vim.minimap.minimap-vim = {
    enable = mkEnableOption "minimap view [minimap-vim]";
  };
}
