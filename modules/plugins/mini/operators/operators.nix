{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.operators = {
    enable = mkEnableOption "mini.operators";
    setupOpts = mkPluginSetupOption "mini.operators" {};
  };
}
