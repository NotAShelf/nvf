{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.utility.outline.aerial-nvim = {
    enable = mkEnableOption "Aerial.nvim";
    setupOpts = mkPluginSetupOption "aerial.nvim" {};

    mappings = {
      toggle = mkMappingOption "Toggle aerial window" "gO";
    };
  };
}
