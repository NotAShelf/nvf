{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.notify = {
    enable = mkEnableOption "mini.notify";
    setupOpts = mkPluginSetupOption "mini.notify" {};
  };
}
