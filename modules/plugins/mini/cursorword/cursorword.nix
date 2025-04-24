{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.cursorword = {
    enable = mkEnableOption "mini.cursorword";
    setupOpts = mkPluginSetupOption "mini.cursorword" {};
  };
}
