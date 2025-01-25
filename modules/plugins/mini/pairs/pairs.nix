{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.pairs = {
    enable = mkEnableOption "mini.pairs";
    setupOpts = mkPluginSetupOption "mini.pairs" {};
  };
}
