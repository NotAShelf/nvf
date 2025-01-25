{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.comment = {
    enable = mkEnableOption "mini.comment";
    setupOpts = mkPluginSetupOption "mini.comment" {};
  };
}
