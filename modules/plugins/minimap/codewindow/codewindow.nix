{lib, ...}: let
  inherit (lib) mkEnableOption mkMappingOption;
in {
  options.vim.minimap.codewindow = {
    enable = mkEnableOption "codewindow plugin for minimap view";

    mappings = {
      open = mkMappingOption "Open minimap [codewindow]" "<leader>mo";
      close = mkMappingOption "Close minimap [codewindow]" "<leader>mc";
      toggle = mkMappingOption "Toggle minimap [codewindow]" "<leader>mm";
      toggleFocus = mkMappingOption "Toggle minimap focus [codewindow]" "<leader>mf";
    };
  };
}
