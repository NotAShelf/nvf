{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.binds.whichKey;
in {
  options.vim.binds.whichKey = {
    enable = mkEnableOption "which-key menu";
  };
}
