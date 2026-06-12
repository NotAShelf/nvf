{
  config,
  lib,
  options,
  ...
}: let
  inherit (builtins) toJSON;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.binds) mkKeymap pushDownDefault;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.git.gitsigns;

  inherit (options.vim.git.gitsigns) mappings;
in {
  config = mkIf cfg.enable (mkMerge [
    {
      vim = {
        startPlugins = ["gitsigns-nvim"];

        keymaps = [
          (mkKeymap "n" cfg.mappings.nextHunk ''
              function()
                if vim.wo.diff then return ${toJSON cfg.mappings.nextHunk} end

                vim.schedule(function() package.loaded.gitsigns.next_hunk() end)

                return '<Ignore>'
              end
            '' {
              desc = mappings.nextHunk.description;
              lua = true;
              expr = true;
            })

          (mkKeymap "n" cfg.mappings.previousHunk ''
              function()
                if vim.wo.diff then return ${toJSON cfg.mappings.previousHunk} end

                vim.schedule(function() package.loaded.gitsigns.prev_hunk() end)

                return '<Ignore>'
              end
            '' {
              desc = mappings.previousHunk.description;
              lua = true;
              expr = true;
            })

          (mkKeymap "n" cfg.mappings.stageHunk "package.loaded.gitsigns.stage_hunk" {
            desc = mappings.stageHunk.description;
            lua = true;
          })
          (mkKeymap "n" cfg.mappings.resetHunk "package.loaded.gitsigns.reset_hunk" {
            desc = mappings.resetHunk.description;
            lua = true;
          })
          (mkKeymap "n" cfg.mappings.undoStageHunk "package.loaded.gitsigns.undo_stage_hunk" {
            desc = mappings.undoStageHunk.description;
            lua = true;
          })

          (mkKeymap "n" cfg.mappings.stageBuffer "package.loaded.gitsigns.stage_buffer" {
            desc = mappings.stageBuffer.description;
            lua = true;
          })
          (mkKeymap "n" cfg.mappings.resetBuffer "package.loaded.gitsigns.reset_buffer" {
            desc = mappings.resetBuffer.description;
            lua = true;
          })

          (mkKeymap "n" cfg.mappings.previewHunk "package.loaded.gitsigns.preview_hunk" {
            desc = mappings.previewHunk.description;
            lua = true;
          })

          (mkKeymap "n" cfg.mappings.blameLine "function() package.loaded.gitsigns.blame_line{full=true} end" {
            desc = mappings.blameLine.description;
            lua = true;
          })
          (mkKeymap "n" cfg.mappings.toggleBlame "package.loaded.gitsigns.toggle_current_line_blame" {
            desc = mappings.toggleBlame.description;
            lua = true;
          })

          (mkKeymap "n" cfg.mappings.diffThis "package.loaded.gitsigns.diffthis" {
            desc = mappings.diffThis.description;
            lua = true;
          })
          (mkKeymap "n" cfg.mappings.diffProject "function() package.loaded.gitsigns.diffthis('~') end" {
            desc = mappings.diffProject.description;
            lua = true;
          })

          (mkKeymap "n" cfg.mappings.toggleDeleted "package.loaded.gitsigns.toggle_deleted" {
            desc = mappings.toggleDeleted.description;
            lua = true;
          })

          (mkKeymap "v" cfg.mappings.stageHunk "function() package.loaded.gitsigns.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end" {
            desc = mappings.stageHunk.description;
            lua = true;
          })
          (mkKeymap "v" cfg.mappings.resetHunk "function() package.loaded.gitsigns.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end" {
            desc = mappings.resetHunk.description;
            lua = true;
          })
        ];

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
