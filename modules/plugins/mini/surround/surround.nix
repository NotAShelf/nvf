{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.surround = {
    enable = mkEnableOption "mini.surround";
    setupOpts = mkPluginSetupOption "mini.surround" {};
  };
}
