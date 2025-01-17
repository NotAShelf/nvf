{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.splitjoin = {
    enable = mkEnableOption "mini.splitjoin";
    setupOpts = mkPluginSetupOption "mini.splitjoin" {};
  };
}
