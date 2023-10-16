{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.utility.surround;
  self = import ./surround.nix {inherit lib;};
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
          (mkSetBinding mappings.insert "<Plug>(nvim-surround-insert)")
          (mkSetBinding mappings.insertLine "<Plug>(nvim-surround-insert-line)")
        ];
        normal = mkMerge [
          (mkSetBinding mappings.normal "<Plug>(nvim-surround-normal)")
          (mkSetBinding mappings.normalCur "<Plug>(nvim-surround-normal-cur)")
          (mkSetBinding mappings.normalLine "<Plug>(nvim-surround-normal-line)")
          (mkSetBinding mappings.normalCurLine "<Plug>(nvim-surround-normal-cur-line)")
          (mkSetBinding mappings.delete "<Plug>(nvim-surround-delete)")
          (mkSetBinding mappings.change "<Plug>(nvim-surround-change)")
        ];
        visualOnly = mkMerge [
          (mkSetBinding mappings.visual "<Plug>(nvim-surround-visual)")
          (mkSetBinding mappings.visualLine "<Plug>(nvim-surround-visual-line)")
        ];
      };
    };
  };
}
