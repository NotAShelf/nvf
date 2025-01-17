{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.snippets = {
    enable = mkEnableOption "mini.snippets";
    setupOpts = mkPluginSetupOption "mini.snippets" {};
  };
}
