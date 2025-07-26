{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.utility.outline.aerial-nvim = {
    enable = mkEnableOption "Aerial.nvim";
    setupOpts = mkPluginSetupOption "aerial.nvim" {};

    mappings = {
      toggle = mkMappingOption config.vim.enableNvfKeymaps "Toggle aerial window" "gO";
    };
  };
}
