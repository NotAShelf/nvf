{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.gestures.gesture-nvim = {
    enable = mkEnableOption "Enable gesture-nvim plugin";
  };
}
