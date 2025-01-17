{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.fuzzy = {
    enable = mkEnableOption "mini.fuzzy";
    setupOpts = mkPluginSetupOption "mini.fuzzy" {};
  };
}
