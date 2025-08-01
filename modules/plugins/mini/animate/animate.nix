{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.animate = {
    enable = mkEnableOption "mini.animate";
    setupOpts = mkPluginSetupOption "mini.animate" {};
  };
}
