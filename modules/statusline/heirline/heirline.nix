{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.statusline.heirline;
in {
  options.vim.statusline.heirline = {
    enable = mkEnableOption "Enable Heirline";
  };
}
