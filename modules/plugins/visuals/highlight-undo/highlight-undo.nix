{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.visuals.highlight-undo = {
    enable = mkEnableOption "highlight undo [highlight-undo]";
    setupOpts = mkPluginSetupOption "highlight-undo" {
      duration = mkOption {
        type = int;
        default = 500;
        description = "Duration of the highlight";
      };
    };
  };
}
