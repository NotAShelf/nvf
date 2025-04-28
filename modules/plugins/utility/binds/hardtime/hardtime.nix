{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.binds.hardtime = {
    enable = mkEnableOption "enable hardtime";

    setupOpts = mkPluginSetupOption "hardtime-nvim" {};
  };
}
