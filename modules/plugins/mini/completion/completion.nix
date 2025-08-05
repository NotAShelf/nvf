{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.mini.completion = {
    enable = mkEnableOption "mini.completion";
    setupOpts = mkPluginSetupOption "mini.completion" {};
  };
}
