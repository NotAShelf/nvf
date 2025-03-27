{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.snacks-nvim = {
    enable = mkEnableOption ''
      collection of QoL plugins for Neovim [snacks-nvim]
    '';

    setupOpts = mkPluginSetupOption "snacks-nvim" {};
  };
}
