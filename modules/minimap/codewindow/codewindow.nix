{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.minimap.codewindow;
in {
  options.vim.minimap.codewindow = {
    enable = mkEnableOption "Enable minimap-vim plugin";
  };
}
