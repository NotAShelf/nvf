{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.ai = {
    enable = mkEnableOption "mini.ai";
    setupOpts = mkPluginSetupOption "mini.ai" {};
  };
}
