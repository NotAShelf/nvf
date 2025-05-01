{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.binds.hardtime-nvim = {
    enable = mkEnableOption "hardtime helper for no repeat keybinds";

    setupOpts = mkPluginSetupOption "hardtime-nvim" {};
  };
}
