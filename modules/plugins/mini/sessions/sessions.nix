{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.sessions = {
    enable = mkEnableOption "mini.sessions";
    setupOpts = mkPluginSetupOption "mini.sessions" {};
  };
}
