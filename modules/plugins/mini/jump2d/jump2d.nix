{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.jump2d = {
    enable = mkEnableOption "mini.jump2d";
    setupOpts = mkPluginSetupOption "mini.jump2d" {};
  };
}
