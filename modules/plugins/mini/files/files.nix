{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.files = {
    enable = mkEnableOption "mini.files";
    setupOpts = mkPluginSetupOption "mini.files" {};
  };
}
