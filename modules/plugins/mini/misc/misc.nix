{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.misc = {
    enable = mkEnableOption "mini.misc";
    setupOpts = mkPluginSetupOption "mini.misc" {};
  };
}
