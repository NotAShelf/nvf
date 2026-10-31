{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  mkMappingOption = config.vim.lib.mkMappingOption "codewindow";
in {
  options.vim.minimap.codewindow = {
    enable = mkEnableOption "codewindow plugin for minimap view";

    mappings = {
      open = mkMappingOption "Open minimap" "<leader>mo";
      close = mkMappingOption "Close minimap" "<leader>mc";
      toggle = mkMappingOption "Toggle minimap" "<leader>mm";
      toggleFocus = mkMappingOption "Toggle minimap focus" "<leader>mf";
    };

    setupOpts = mkPluginSetupOption "codewindow" {};
  };
}
