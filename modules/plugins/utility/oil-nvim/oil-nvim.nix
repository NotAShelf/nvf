{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.oil-nvim = {
    enable = mkEnableOption ''
      Neovim file explorer: edit your filesystem like a buffer [oil-nvim]
    '';

    setupOpts = mkPluginSetupOption "oil-nvim" {};

    gitStatus = {
      enable = mkEnableOption ''
        Git status on [oil-nvim] directory listings
      '';

      setupOpts = mkPluginSetupOption "oil-git-status-nvim" {};
    };
  };
}
