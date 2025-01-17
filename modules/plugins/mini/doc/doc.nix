{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.doc = {
    enable = mkEnableOption "mini.doc";
    setupOpts = mkPluginSetupOption "mini.doc" {};
  };
}
