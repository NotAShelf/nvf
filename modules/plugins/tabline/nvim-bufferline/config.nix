{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap pushDownDefault;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.tabline.nvimBufferline;

  inherit (options.vim.tabline.nvimBufferline) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "bufferline-nvim"
        "bufdelete-nvim"
      ];

      # Soft-dependency for bufferline.
      # Recommended by upstream, so enabled here.
      visuals.nvim-web-devicons.enable = true;

      # See `:help bufferline-hover-events`
      options = mkIf cfg.setupOpts.options.hover.enabled {
        mousemoveevent = true;
      };

      keymaps = [
        (
          mkKeymap "n" cfg.mappings.closeCurrent "require('bufdelete').bufdelete"
          {
            desc = mappings.closeCurrent.description;
            lua = true;
          }
        )
        (mkKeymap "n" cfg.mappings.cycleNext ":BufferLineCycleNext<CR>" {desc = mappings.cycleNext.description;})
        (mkKeymap "n" cfg.mappings.cycleNext ":BufferLineCycleNext<CR>" {desc = mappings.cycleNext.description;})
        (mkKeymap "n" cfg.mappings.cyclePrevious ":BufferLineCyclePrev<CR>" {desc = mappings.cyclePrevious.description;})
        (mkKeymap "n" cfg.mappings.pick ":BufferLinePick<CR>" {desc = mappings.pick.description;})
        (mkKeymap "n" cfg.mappings.sortByExtension ":BufferLineSortByExtension<CR>" {desc = mappings.sortByExtension.description;})
        (mkKeymap "n" cfg.mappings.sortByDirectory ":BufferLineSortByDirectory<CR>" {desc = mappings.sortByDirectory.description;})
        (
          mkKeymap "n" cfg.mappings.sortById
          "function() require('bufferline').sort_buffers_by(function (buf_a, buf_b) return buf_a.id < buf_b.id end) end"
          {
            desc = mappings.sortById.description;
            lua = true;
          }
        )
        (mkKeymap "n" cfg.mappings.moveNext ":BufferLineMoveNext<CR>" {desc = mappings.moveNext.description;})
        (mkKeymap "n" cfg.mappings.movePrevious ":BufferLineMovePrev<CR>" {desc = mappings.movePrevious.description;})
      ];

      binds.whichKey.register = pushDownDefault {
        "<leader>b" = "+Buffer";
        "<leader>bm" = "BufferLineMove";
        "<leader>bs" = "BufferLineSort";
        "<leader>bsi" = "BufferLineSortById";
      };

      pluginRC.nvimBufferline = entryAnywhere ''
        require("bufferline").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
