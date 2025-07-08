{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.move = {
    enable = mkEnableOption "mini.move";
    setupOpts = mkPluginSetupOption "mini.move" {};
  };
}
