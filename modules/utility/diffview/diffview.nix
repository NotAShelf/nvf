{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.utility.diffview-nvim;
in {
  options.vim.utility.diffview-nvim = {
    enable = mkEnableOption "Enable diffview-nvim";
  };
}
