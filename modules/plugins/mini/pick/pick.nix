{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.pick = {
    enable = mkEnableOption "mini.pick";
    setupOpts = mkPluginSetupOption "mini.pick" {};
  };
}
