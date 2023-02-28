{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.gestures.gesture-nvim;
in {
  options.vim.gestures.gesture-nvim = {
    enable = mkEnableOption "Enable gesture-nvim plugin";
  };
}
