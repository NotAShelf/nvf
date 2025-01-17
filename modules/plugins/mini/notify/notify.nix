{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.notify = {
    enable = mkEnableOption "mini.notify";
    setupOpts = mkPluginSetupOption "mini.notify" {};
  };
}
