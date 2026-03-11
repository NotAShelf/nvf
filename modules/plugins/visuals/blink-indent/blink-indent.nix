{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.visuals.blink-indent = {
    enable = mkEnableOption "indentation guides [blink-indent]";
    setupOpts = mkPluginSetupOption "blink-indent" {};
  };
}
