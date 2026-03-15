{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.utility.motion.leap = {
    enable = mkEnableOption "leap.nvim plugin (easy motion)";

    mappings = {
      leapForwardTo = mkMappingOption "Leap forward to" "<leader>ss";
      leapBackwardTo = mkMappingOption "Leap backward to" "<leader>sS";
      leapForwardTill = mkMappingOption "Leap forward till" "<leader>sx";
      leapBackwardTill = mkMappingOption "Leap backward till" "<leader>sX";
      leapFromWindow = mkMappingOption "Leap from window" "gs";
    };
  };
}
