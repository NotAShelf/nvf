{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.nvim-biscuits = {
    enable = mkEnableOption ''
      A neovim port of Assorted Biscuits.
    '';

    setupOpts = mkPluginSetupOption "nvim-biscuits" {};
  };
}
