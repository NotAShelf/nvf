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

  cfg = config.vim.git.gitsigns;

  inherit (options.vim.git.gitsigns) mappings;
in {
  config = mkIf cfg.enable (mkMerge [
    {
      vim = {
        lazy.plugins.gitsigns-nvim = {
          package = "gitsigns-nvim";
          setupModule = "gitsigns";
          inherit (cfg) setupOpts;
          event = [
            {
              event = "User";
              pattern = "LazyFile";
            }
          ];
          cmd = ["Gitsigns"];
          keys = [
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

            (mkKeymap "n" cfg.mappings.stageHunk "function() package.loaded.gitsigns.stage_hunk() end" {
              desc = mappings.stageHunk.description;
              lua = true;
            })
            (mkKeymap "n" cfg.mappings.resetHunk "function() package.loaded.gitsigns.reset_hunk() end" {
              desc = mappings.resetHunk.description;
              lua = true;
            })
            (mkKeymap "n" cfg.mappings.undoStageHunk "function() package.loaded.gitsigns.undo_stage_hunk() end" {
              desc = mappings.undoStageHunk.description;
              lua = true;
            })

            (mkKeymap "n" cfg.mappings.stageBuffer "function() package.loaded.gitsigns.stage_buffer() end" {
              desc = mappings.stageBuffer.description;
              lua = true;
            })
            (mkKeymap "n" cfg.mappings.resetBuffer "function() package.loaded.gitsigns.reset_buffer() end" {
              desc = mappings.resetBuffer.description;
              lua = true;
            })

            (mkKeymap "n" cfg.mappings.previewHunk "function() package.loaded.gitsigns.preview_hunk() end" {
              desc = mappings.previewHunk.description;
              lua = true;
            })

            (mkKeymap "n" cfg.mappings.blameLine "function() package.loaded.gitsigns.blame_line{full=true} end" {
              desc = mappings.blameLine.description;
              lua = true;
            })
            (mkKeymap "n" cfg.mappings.toggleBlame "function() package.loaded.gitsigns.toggle_current_line_blame() end" {
              desc = mappings.toggleBlame.description;
              lua = true;
            })

            (mkKeymap "n" cfg.mappings.diffThis "function() package.loaded.gitsigns.diffthis() end" {
              desc = mappings.diffThis.description;
              lua = true;
            })
            (mkKeymap "n" cfg.mappings.diffProject "function() package.loaded.gitsigns.diffthis('~') end" {
              desc = mappings.diffProject.description;
              lua = true;
            })

            (mkKeymap "n" cfg.mappings.toggleDeleted "function() package.loaded.gitsigns.toggle_deleted() end" {
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
        };

        binds.whichKey.register = pushDownDefault {
          "<leader>h" = "+Gitsigns";
        };
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
