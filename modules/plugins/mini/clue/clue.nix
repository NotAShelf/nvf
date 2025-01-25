{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.clue = {
    enable = mkEnableOption "mini.clue";
    setupOpts = mkPluginSetupOption "mini.clue" {};
  };
}
