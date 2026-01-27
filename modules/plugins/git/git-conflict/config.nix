{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetBinding;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.git.git-conflict;

  gcMappingDefinitions = options.vim.git.git-conflict.mappings;

  gcMappings = addDescriptionsToMappings cfg.mappings gcMappingDefinitions;
in {
  config = mkIf cfg.enable (mkMerge [
    {
      vim = {
        startPlugins = ["git-conflict-nvim"];

        maps = {
          normal = mkMerge [
            (mkSetBinding gcMappings.ours "<Plug>(git-conflict-ours)")
            (mkSetBinding gcMappings.theirs "<Plug>(git-conflict-theirs)")
            (mkSetBinding gcMappings.both "<Plug>(git-conflict-both)")
            (mkSetBinding gcMappings.none "<Plug>(git-conflict-none)")
            (mkSetBinding gcMappings.prevConflict "<Plug>(git-conflict-prev-conflict)")
            (mkSetBinding gcMappings.nextConflict "<Plug>(git-conflict-next-conflict)")
          ];
        };

        pluginRC.git-conflict = entryAnywhere ''
          require('git-conflict').setup(${toLuaObject ({default_mappings = false;} // cfg.setupOpts)})
        '';
      };
    }
  ]);
}
