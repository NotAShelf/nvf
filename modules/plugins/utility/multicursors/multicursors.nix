{lib, ...}: let
  inherit (lib.types) bool int str;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.utility.multicursors = {
    enable = mkEnableOption "multicursors.nvim plugin (vscode like multiple cursors)";

    setupOpts = mkPluginSetupOption "multicursors" {
      DEBUG_MODE = mkOption {
        type = bool;
        default = false;
      };
    };
  };
}
