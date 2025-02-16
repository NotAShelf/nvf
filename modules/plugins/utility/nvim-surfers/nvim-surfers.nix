{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.types) str;
in {
  options.vim.utility = {
    nvim-surfers = {
      enable = mkEnableOption "nvim-surfers";
      setupOpts = mkPluginSetupOption "nvim-surfers" {
        tmux = mkEnableOption "using tmux for nvim-surfers";
        path = mkOption {
          type = str;
          default = "resources/surfers.mp4";
          description = "Path of the Subway Surfers gameplay to watch.";
        };
      };
    };
  };
}
