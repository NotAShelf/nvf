{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.ui.noice;
in {
  options.vim.ui.noice = {
    enable = mkEnableOption "noice-nvim";
  };
}
