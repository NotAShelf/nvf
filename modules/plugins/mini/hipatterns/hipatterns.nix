{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.hipatterns = {
    enable = mkEnableOption "mini.hipatterns";
    setupOpts = mkPluginSetupOption "mini.hipatterns" {};
  };
}
