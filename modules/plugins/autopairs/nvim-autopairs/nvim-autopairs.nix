{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.autopairs.nvim-autopairs = {
    enable = mkEnableOption "autopairs";
    setupOpts = mkPluginSetupOption "nvim-autopairs" {};
  };
}
