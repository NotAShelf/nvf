{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.statusline = {
    enable = mkEnableOption "mini.statusline";
    setupOpts = mkPluginSetupOption "mini.statusline" {};
  };
}
