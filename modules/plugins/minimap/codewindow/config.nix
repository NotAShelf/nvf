{
  config,
  lib,
  ...
}: let
  inherit (lib) addDescriptionsToMappings mkIf mkMerge mkSetLuaBinding nvim;

  cfg = config.vim.minimap.codewindow;

  self = import ./codewindow.nix {inherit lib;};

  mappingDefinitions = self.options.vim.minimap.codewindow.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "codewindow-nvim"
    ];

    vim.maps.normal = mkMerge [
      (mkSetLuaBinding mappings.open "require('codewindow').open_minimap")
      (mkSetLuaBinding mappings.close "require('codewindow').close_minimap")
      (mkSetLuaBinding mappings.toggle "require('codewindow').toggle_minimap")
      (mkSetLuaBinding mappings.toggleFocus "require('codewindow').toggle_focus")
    ];

    vim.luaConfigRC.codewindow = nvim.dag.entryAnywhere ''
      local codewindow = require('codewindow')
      codewindow.setup({
        exclude_filetypes = { 'NvimTree', 'orgagenda', 'Alpha'},
      })
    '';
  };
}
