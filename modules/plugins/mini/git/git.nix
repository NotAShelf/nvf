{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.git = {
    enable = mkEnableOption "mini.git";
    setupOpts = mkPluginSetupOption "mini.git" {};
  };
}
