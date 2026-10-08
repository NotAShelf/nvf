{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.auto-indent-nvim = {
    enable = mkEnableOption "VSCode-like tab indentation [auto-indent.nvim]";

    setupOpts = mkPluginSetupOption "auto-indent.nvim" {};
  };
}
