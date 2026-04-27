{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.presence.cord-nvim = {
    enable = mkEnableOption "Discord rich presence [cord.nvim]";

    setupOpts = mkPluginSetupOption "cord.nvim" {};
  };
}
