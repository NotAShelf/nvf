{
  config,
  lib,
  options,
  ...
}: let
  inherit (builtins) toJSON;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetExprBinding mkSetLuaBinding pushDownDefault;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.git.gitsigns;

  gsMappingDefinitions = options.vim.git.gitsigns.mappings;

  gsMappings = addDescriptionsToMappings cfg.mappings gsMappingDefinitions;
in {
  config = mkIf cfg.enable (mkMerge [
    {
      vim = {
        startPlugins = ["gitsigns-nvim"];

        maps = {
          normal = mkMerge [
            (mkSetExprBinding gsMappings.nextHunk ''
              function()
                if vim.wo.diff then return ${toJSON gsMappings.nextHunk.value} end

                vim.schedule(function() package.loaded.gitsigns.next_hunk() end)

                return '<Ignore>'
              end
            '')

            (mkSetExprBinding gsMappings.previousHunk ''
              function()
                if vim.wo.diff then return ${toJSON gsMappings.previousHunk.value} end

                vim.schedule(function() package.loaded.gitsigns.prev_hunk() end)

                return '<Ignore>'
              end
            '')

            (mkSetLuaBinding gsMappings.stageHunk "package.loaded.gitsigns.stage_hunk")
            (mkSetLuaBinding gsMappings.resetHunk "package.loaded.gitsigns.reset_hunk")
            (mkSetLuaBinding gsMappings.undoStageHunk "package.loaded.gitsigns.undo_stage_hunk")

            (mkSetLuaBinding gsMappings.stageBuffer "package.loaded.gitsigns.stage_buffer")
            (mkSetLuaBinding gsMappings.resetBuffer "package.loaded.gitsigns.reset_buffer")

            (mkSetLuaBinding gsMappings.previewHunk "package.loaded.gitsigns.preview_hunk")

            (mkSetLuaBinding gsMappings.blameLine "function() package.loaded.gitsigns.blame_line{full=true} end")
            (mkSetLuaBinding gsMappings.toggleBlame "package.loaded.gitsigns.toggle_current_line_blame")

            (mkSetLuaBinding gsMappings.diffThis "package.loaded.gitsigns.diffthis")
            (mkSetLuaBinding gsMappings.diffProject "function() package.loaded.gitsigns.diffthis('~') end")

            (mkSetLuaBinding gsMappings.toggleDeleted "package.loaded.gitsigns.toggle_deleted")
          ];

          visual = mkMerge [
            (mkSetLuaBinding gsMappings.stageHunk "function() package.loaded.gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end")
            (mkSetLuaBinding gsMappings.resetHunk "function() package.loaded.gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end")
          ];
        };

        binds.whichKey.register = pushDownDefault {
          "<leader>h" = "+Gitsigns";
        };

        pluginRC.gitsigns = entryAnywhere ''
          require('gitsigns').setup(${toLuaObject cfg.setupOpts})
        '';
      };
    }

    (mkIf cfg.codeActions.enable {
      vim.lsp.null-ls = {
        enable = true;
        setupOpts.sources = [
          (mkLuaInline ''
            require("null-ls").builtins.code_actions.gitsigns
          '')
        ];
      };
    })
  ]);
}
