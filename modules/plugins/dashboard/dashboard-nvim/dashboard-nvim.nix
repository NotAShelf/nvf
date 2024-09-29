{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.dashboard.dashboard-nvim = {
    enable = mkEnableOption "Fancy and Blazing Fast start screen plugin of neovim [dashboard.nvim]";
    setupOpts = mkPluginSetupOption "dashboard.nvim" {};
  };
}
