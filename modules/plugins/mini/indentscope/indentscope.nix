{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.indentscope = {
    enable = mkEnableOption "mini.indentscope";
    setupOpts = mkPluginSetupOption "mini.indentscope" {};
  };
}
