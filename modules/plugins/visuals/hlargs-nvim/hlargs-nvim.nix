{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.visuals.hlargs-nvim = {
    enable = mkEnableOption "hlargs-nvim";
    setupOpts = mkPluginSetupOption "hlargs-nvim" {};
  };
}
