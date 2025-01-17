{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.icons = {
    enable = mkEnableOption "mini.icons";
    setupOpts = mkPluginSetupOption "mini.icons" {};
  };
}
