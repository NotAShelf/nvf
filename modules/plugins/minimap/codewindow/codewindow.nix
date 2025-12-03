{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.types) bool str listOf;
in {
  options.vim.minimap.codewindow = {
    enable = mkEnableOption "codewindow plugin for minimap view";
    openByDefault = mkEnableOption "codewindow plugin opening automatically";

    mappings = {
      open = mkMappingOption "Open minimap [codewindow]" "<leader>mo";
      close = mkMappingOption "Close minimap [codewindow]" "<leader>mc";
      toggle = mkMappingOption "Toggle minimap [codewindow]" "<leader>mm";
      toggleFocus = mkMappingOption "Toggle minimap focus [codewindow]" "<leader>mf";
    };

    setupOpts = mkPluginSetupOption "codewindow" {
      auto_enable = mkOption {
        description = "Open automatically";
        type = bool;
        default = true;
      };

      exclude_filetypes = mkOption {
        description = "Excluded files types";
        type = listOf str;
        default = ["NvimTree" "orgagenda" "Alpha"];
      };
    };
  };
}
