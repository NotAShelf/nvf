{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.map = {
    enable = mkEnableOption "mini.map";
    setupOpts = mkPluginSetupOption "mini.map" {};
  };
}
