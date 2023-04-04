{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vim.utility.motion.hop;
in {
  options.vim.utility.motion.hop = {
    enable = mkEnableOption "Enable Hop.nvim plugin (easy motion)";
  };
}
