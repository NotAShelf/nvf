{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetLuaBinding pushDownDefault;

  cfg = config.vim.minimap.codewindow;

  mappingDefinitions = options.vim.minimap.codewindow.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "codewindow-nvim"
      ];

      maps.normal = mkMerge [
        (mkSetLuaBinding mappings.open "require('codewindow').open_minimap")
        (mkSetLuaBinding mappings.close "require('codewindow').close_minimap")
        (mkSetLuaBinding mappings.toggle "require('codewindow').toggle_minimap")
        (mkSetLuaBinding mappings.toggleFocus "require('codewindow').toggle_focus")
      ];

      binds.whichKey.register = pushDownDefault {
        "<leader>m" = "+Minimap";
      };

      pluginRC.codewindow = entryAnywhere ''
        local codewindow = require('codewindow')
        codewindow.setup({
          exclude_filetypes = { 'NvimTree', 'orgagenda', 'Alpha'},
        })
      '';
    };
  };
}
