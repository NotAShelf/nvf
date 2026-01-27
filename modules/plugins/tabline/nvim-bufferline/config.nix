{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) mkLuaBinding mkBinding pushDownDefault;
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

      maps.normal = mkMerge [
        (
          mkLuaBinding cfg.mappings.closeCurrent "require(\"bufdelete\").bufdelete"
          mappings.closeCurrent.description
        )
        (mkBinding cfg.mappings.cycleNext ":BufferLineCycleNext<CR>" mappings.cycleNext.description)
        (mkBinding cfg.mappings.cycleNext ":BufferLineCycleNext<CR>" mappings.cycleNext.description)
        (mkBinding cfg.mappings.cyclePrevious ":BufferLineCyclePrev<CR>" mappings.cyclePrevious.description)
        (mkBinding cfg.mappings.pick ":BufferLinePick<CR>" mappings.pick.description)
        (
          mkBinding cfg.mappings.sortByExtension ":BufferLineSortByExtension<CR>"
          mappings.sortByExtension.description
        )
        (
          mkBinding cfg.mappings.sortByDirectory ":BufferLineSortByDirectory<CR>"
          mappings.sortByDirectory.description
        )
        (
          mkLuaBinding cfg.mappings.sortById
          "function() require(\"bufferline\").sort_buffers_by(function (buf_a, buf_b) return buf_a.id < buf_b.id end) end"
          mappings.sortById.description
        )
        (mkBinding cfg.mappings.moveNext ":BufferLineMoveNext<CR>" mappings.moveNext.description)
        (mkBinding cfg.mappings.movePrevious ":BufferLineMovePrev<CR>" mappings.movePrevious.description)
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
