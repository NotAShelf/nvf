{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.crazy-coverage = {
    enable = mkEnableOption "coverage for neovim";

    setupOpts =
      mkPluginSetupOption "crazy-coverage.nvim" {};
  };
}
