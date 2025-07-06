{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.jump = {
    enable = mkEnableOption "mini.jump";
    setupOpts = mkPluginSetupOption "mini.jump" {};
  };
}
