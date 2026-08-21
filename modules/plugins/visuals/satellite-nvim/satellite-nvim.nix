{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.visuals.satellite-nvim = {
    enable = mkEnableOption "decorated scrollbar for Neovim [satellite.nvim]";

    setupOpts = mkPluginSetupOption "satellite.nvim" {};
  };
}
