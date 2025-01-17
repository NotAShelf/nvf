{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.animate = {
    enable = mkEnableOption "mini.animate";
    setupOpts = mkPluginSetupOption "mini.animate" {};
  };
}
