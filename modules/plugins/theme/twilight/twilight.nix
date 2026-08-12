{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.theme.twilight = {
    enable = mkEnableOption "twilight.nvim";

    setupOpts = mkPluginSetupOption "twilight.nvim" {};
  };
}
