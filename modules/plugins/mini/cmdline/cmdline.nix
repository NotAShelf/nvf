{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.cmdline = {
    enable = mkEnableOption "mini.cmdline";
    setupOpts = mkPluginSetupOption "mini.cmdline" {};
  };
}
