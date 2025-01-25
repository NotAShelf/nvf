{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.tabline = {
    enable = mkEnableOption "mini.tabline";
    setupOpts = mkPluginSetupOption "mini.tabline" {};
  };
}
