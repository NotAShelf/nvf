{lib, ...}: let
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) int;
in {
  options.vim.auto-save = {
    enable = mkEnableOption "auto-save";
    setupOpts = mkPluginSetupOption "auto-save" {
      debounce_delay = mkOption {
        type = int;
        # plugin default is 135, adding an option to setupOpts for example
        default = 100;
        description = "saves the file at most every `debounce_delay` milliseconds";
      };
    };
  };
}
