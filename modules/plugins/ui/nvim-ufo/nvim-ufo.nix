{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.ui.nvim-ufo = {
    enable = mkEnableOption "nvim-ufo";
    setupOpts = mkPluginSetupOption "nvim-ufo" {};
  };
}
