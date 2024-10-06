{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.binds) mkBinding;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.visuals;
in {
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.smoothScroll.enable {
      vim.startPlugins = ["cinnamon-nvim"];
      vim.pluginRC.smoothScroll = entryAnywhere ''
        require('cinnamon').setup()
      '';
    })

    (mkIf cfg.highlight-undo.enable {
      vim.startPlugins = ["highlight-undo"];
      vim.pluginRC.highlight-undo = entryAnywhere ''
        require('highlight-undo').setup({
          duration = ${toString cfg.highlight-undo.duration},
          highlight_for_count = ${boolToString cfg.highlight-undo.highlightForCount},
          undo = {
            hlgroup = ${cfg.highlight-undo.undo.hlGroup},
            mode = 'n',
            lhs = 'u',
            map = 'undo',
            opts = {}
          },

          redo = {
            hlgroup = ${cfg.highlight-undo.redo.hlGroup},
            mode = 'n',
            lhs = '<C-r>',
            map = 'redo',
            opts = {}
          },
        })
      '';
    })
  ]);
}
