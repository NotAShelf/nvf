{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.visits = {
    enable = mkEnableOption "mini.visits";
    setupOpts = mkPluginSetupOption "mini.visits" {};
  };
}
