{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.colors = {
    enable = mkEnableOption "mini.colors";
    setupOpts = mkPluginSetupOption "mini.colors" {};
  };
}
