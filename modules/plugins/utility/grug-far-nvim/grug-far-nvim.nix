{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.grug-far-nvim = {
    enable = mkEnableOption "grug-far";
    setupOpts = mkPluginSetupOption "grug-far" {};
  };
}
