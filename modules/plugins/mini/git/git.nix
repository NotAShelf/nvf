{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.git = {
    enable = mkEnableOption "mini.git";
    setupOpts = mkPluginSetupOption "mini.git" {};
  };
}
