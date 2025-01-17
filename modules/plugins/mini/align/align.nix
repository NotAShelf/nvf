{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.align = {
    enable = mkEnableOption "mini.align";
    setupOpts = mkPluginSetupOption "mini.align" {};
  };
}
