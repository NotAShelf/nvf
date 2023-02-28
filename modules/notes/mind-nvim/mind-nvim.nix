{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.notes.mind-nvim;
in {
  options.vim.notes.mind-nvim = {
    enable = mkEnableOption "The power of trees at your fingertips. ";
  };
}
