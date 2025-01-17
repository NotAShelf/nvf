{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.files = {
    enable = mkEnableOption "mini.files";
    setupOpts = mkPluginSetupOption "mini.files" {};
  };
}
