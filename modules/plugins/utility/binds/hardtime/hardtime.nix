{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.binds.hardtime-nvim = {
    enable = mkEnableOption "Hardtime - A Plugin for Blocks key repeats in Neovim.";

    setupOpts = mkPluginSetupOption "hardtime-nvim" {};
  };
}
