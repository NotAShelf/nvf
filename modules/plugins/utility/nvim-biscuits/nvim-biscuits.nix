{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.nvim-biscuits = {
    enable = mkEnableOption "a Neovim port of Assorted Biscuits [nvim-biscuits]";

    setupOpts = mkPluginSetupOption "nvim-biscuits" {};
  };
}
