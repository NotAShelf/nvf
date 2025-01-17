{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.snippets = {
    enable = mkEnableOption "mini.snippets";
    setupOpts = mkPluginSetupOption "mini.snippets" {};
  };
}
