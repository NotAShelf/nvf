{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vim.utility.hop;
in {
  options.vim.utility.hop = {
    enable = mkEnableOption "Enable Hop.nvim plugin (easy motion)";
  };
}
