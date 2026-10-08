{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.guess-indent-nvim = {
    enable = mkEnableOption "Automatic indentation style detection [guess-indent.nvim]";

    setupOpts = mkPluginSetupOption "guess-indent.nvim" {};
  };
}
