{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.basics = {
    enable = mkEnableOption "mini.basics";
    setupOpts = mkPluginSetupOption "mini.basics" {};
  };
}
