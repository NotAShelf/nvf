{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.jump = {
    enable = mkEnableOption "mini.jump";
    setupOpts = mkPluginSetupOption "mini.jump" {};
  };
}
