{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vim.utility.motion.leap;
in {
  options.vim.utility.motion.leap = {
    enable = mkEnableOption "Enable leap.nvim plugin (easy motion)";
  };
}
