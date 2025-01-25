{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.starter = {
    enable = mkEnableOption "mini.starter";
    setupOpts = mkPluginSetupOption "mini.starter" {};
  };
}
