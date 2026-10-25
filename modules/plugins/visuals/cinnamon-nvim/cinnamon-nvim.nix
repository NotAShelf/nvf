{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrs;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.visuals.cinnamon-nvim = {
    enable = mkEnableOption "smooth scrolling for ANY command [cinnamon-nvim]";
    setupOpts = mkPluginSetupOption "cinnamon.nvim" {
      options = mkOption {
        type = attrs;
        default = {
          # Defaults provided for the sake of documentation only!
          # Who would've guessed setupOpts.options would be confusing?
          mode = "cursor";
          count_only = false;
        };
        description = "Scroll options";
      };

      keymaps = {
        basic = mkEnableOption "basic animation keymaps";
        extra = mkEnableOption "extra animation keymaps";
      };
    };
  };
}
