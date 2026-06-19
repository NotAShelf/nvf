{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.extra = {
    enable = mkEnableOption "mini.extra";
    setupOpts = mkPluginSetupOption "mini.extra" {};
  };
}
