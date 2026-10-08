{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.visuals.twilight-nvim = {
    enable = mkEnableOption "TreeSitter-aware code dimming [twilight.nvim]";

    setupOpts = mkPluginSetupOption "twilight.nvim" {};
  };
}
