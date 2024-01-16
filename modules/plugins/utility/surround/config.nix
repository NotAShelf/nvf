{
  config,
  lib,
  ...
}: let
  inherit (lib) addDescriptionsToMappings mkIf mkMerge mkSetBinding nvim;

  cfg = config.vim.utility.surround;
  self = import ./surround.nix {inherit lib config;};
  mappingDefinitions = self.options.vim.utility.surround.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "nvim-surround"
      ];

      luaConfigRC.surround = nvim.dag.entryAnywhere ''
        require('nvim-surround').setup()
      '';

      maps = {
        insert = mkMerge [
          (mkIf (mappings.insert != null) (mkSetBinding mappings.insert "<Plug>(nvim-surround-insert)"))
          (mkIf (mappings.insertLine != null) (mkSetBinding mappings.insertLine "<Plug>(nvim-surround-insert-line)"))
        ];
        normal = mkMerge [
          (mkIf (mappings.normal != null) (mkSetBinding mappings.normal "<Plug>(nvim-surround-normal)"))
          (mkIf (mappings.normalCur != null) (mkSetBinding mappings.normalCur "<Plug>(nvim-surround-normal-cur)"))
          (mkIf (mappings.normalLine != null) (mkSetBinding mappings.normalLine "<Plug>(nvim-surround-normal-line)"))
          (mkIf (mappings.normalCurLine != null) (mkSetBinding mappings.normalCurLine "<Plug>(nvim-surround-normal-cur-line)"))
          (mkIf (mappings.delete != null) (mkSetBinding mappings.delete "<Plug>(nvim-surround-delete)"))
          (mkIf (mappings.change != null) (mkSetBinding mappings.change "<Plug>(nvim-surround-change)"))
        ];
        visualOnly = mkMerge [
          (mkIf (mappings.visual != null) (mkSetBinding mappings.visual "<Plug>(nvim-surround-visual)"))
          (mkIf (mappings.visualLine != null) (mkSetBinding mappings.visualLine "<Plug>(nvim-surround-visual-line)"))
        ];
      };
    };
  };
}
