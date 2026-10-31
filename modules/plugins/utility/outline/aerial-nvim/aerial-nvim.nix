{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  mkMappingOption = config.vim.lib.mkMappingOption "Aerial";
in {
  options.vim.utility.outline.aerial-nvim = {
    enable = mkEnableOption "Aerial.nvim";
    setupOpts = mkPluginSetupOption "aerial.nvim" {};

    mappings = {
      toggle = mkMappingOption "Toggle window" "gO";
    };
  };
}
