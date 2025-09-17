{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) nullOr str;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.motion.flash-nvim = {
    enable = mkEnableOption "enhanced code navigation with flash.nvim";
    setupOpts = mkPluginSetupOption "flash-nvim" {};

    mappings = {
      jump = mkOption {
        type = nullOr str;
        default = "s";
        description = "Jump";
      };
      treesitter = mkOption {
        type = nullOr str;
        default = "S";
        description = "Treesitter";
      };
      remote = mkOption {
        type = nullOr str;
        default = "r";
        description = "Remote Flash";
      };
      treesitter_search = mkOption {
        type = nullOr str;
        default = "R";
        description = "Treesitter Search";
      };
      toggle = mkOption {
        type = nullOr str;
        default = "<c-s>";
        description = "Toggle Flash Search";
      };
    };
  };
}
