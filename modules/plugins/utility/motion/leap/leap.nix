{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) nullOr str;
in {
  options.vim.utility.motion.leap = {
    enable = mkEnableOption "leap.nvim plugin (easy motion)";

    mappings = {
      leapForwardTo = mkOption {
        type = nullOr str;
        description = "Leap forward to";
        default = "<leader>ss";
      };
      leapBackwardTo = mkOption {
        type = nullOr str;
        description = "Leap backward to";
        default = "<leader>sS";
      };
      leapForwardTill = mkOption {
        type = nullOr str;
        description = "Leap forward till";
        default = "<leader>sx";
      };
      leapBackwardTill = mkOption {
        type = nullOr str;
        description = "Leap backward till";
        default = "<leader>sX";
      };
      leapFromWindow = mkOption {
        type = nullOr str;
        description = "Leap from window";
        default = "gs";
      };
    };
  };
}
