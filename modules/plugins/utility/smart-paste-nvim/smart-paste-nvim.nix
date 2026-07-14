{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.smart-paste-nvim = {
    enable = mkEnableOption "context-aware paste indentation [smart-paste.nvim]";

    setupOpts = mkPluginSetupOption "smart-paste.nvim" {};
  };
}
