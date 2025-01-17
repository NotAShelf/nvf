{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.move = {
    enable = mkEnableOption "mini.move";
    setupOpts = mkPluginSetupOption "mini.move" {};
  };
}
