{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.ui.fastaction = {
    enable = mkEnableOption "overriding vim.ui.select with fastaction.nvim";
    setupOpts = mkPluginSetupOption "fastaction" {};
  };
}
