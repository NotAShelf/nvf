{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.visuals.neoscroll-nvim = {
    enable = mkEnableOption "smooth scrolling for window movement commands [neoscroll.nvim]";

    setupOpts = mkPluginSetupOption "neoscroll.nvim" {};
  };
}
