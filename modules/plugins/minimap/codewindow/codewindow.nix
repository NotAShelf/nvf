{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.minimap.codewindow = {
    enable = mkEnableOption "codewindow plugin for minimap view";

    mappings = {
      open = mkMappingOption config.vim.enableNvfKeymaps "Open minimap [codewindow]" "<leader>mo";
      close = mkMappingOption config.vim.enableNvfKeymaps "Close minimap [codewindow]" "<leader>mc";
      toggle = mkMappingOption config.vim.enableNvfKeymaps "Toggle minimap [codewindow]" "<leader>mm";
      toggleFocus = mkMappingOption config.vim.enableNvfKeymaps "Toggle minimap focus [codewindow]" "<leader>mf";
    };
  };
}
