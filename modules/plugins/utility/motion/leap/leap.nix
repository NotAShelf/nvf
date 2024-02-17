{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.vim.utility.motion.leap = {
    enable = mkEnableOption "leap.nvim plugin (easy motion)";

    mappings = {
      leapForwardTo = mkOption {
        type = types.nullOr types.str;
        description = "Leap forward to";
        default = "s";
      };
      leapBackwardTo = mkOption {
        type = types.nullOr types.str;
        description = "Leap backward to";
        default = "S";
      };
      leapForwardTill = mkOption {
        type = types.nullOr types.str;
        description = "Leap forward till";
        default = "x";
      };
      leapBackwardTill = mkOption {
        type = types.nullOr types.str;
        description = "Leap backward till";
        default = "X";
      };
      leapFromWindow = mkOption {
        type = types.nullOr types.str;
        description = "Leap from window";
        default = "gs";
      };
    };
  };
}
