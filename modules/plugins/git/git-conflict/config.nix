{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) mkKeymap;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.git.git-conflict;

  inherit (options.vim.git.git-conflict) mappings;
in {
  config = mkIf cfg.enable (mkMerge [
    {
      vim = {
        startPlugins = ["git-conflict-nvim"];

        keymaps = [
          (mkKeymap "n" cfg.mappings.ours "<Plug>(git-conflict-ours)" {desc = mappings.ours.description;})
          (mkKeymap "n" cfg.mappings.theirs "<Plug>(git-conflict-theirs)" {desc = mappings.theirs.description;})
          (mkKeymap "n" cfg.mappings.both "<Plug>(git-conflict-both)" {desc = mappings.both.description;})
          (mkKeymap "n" cfg.mappings.none "<Plug>(git-conflict-none)" {desc = mappings.none.description;})
          (mkKeymap "n" cfg.mappings.prevConflict "<Plug>(git-conflict-prev-conflict)" {desc = mappings.prevConflict.description;})
          (mkKeymap "n" cfg.mappings.nextConflict "<Plug>(git-conflict-next-conflict)" {desc = mappings.nextConflict.description;})
        ];

        pluginRC.git-conflict = entryAnywhere ''
          require('git-conflict').setup(${toLuaObject ({default_mappings = false;} // cfg.setupOpts)})
        '';
      };
    }
  ]);
}
