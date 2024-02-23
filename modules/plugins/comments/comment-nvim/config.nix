{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkMerge mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) mkExprBinding mkBinding;

  cfg = config.vim.comments.comment-nvim;
  self = import ./comment-nvim.nix {inherit lib;};
  inherit (self.options.vim.comments.comment-nvim) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "comment-nvim"
      ];

      maps = {
        normal = mkMerge [
          (mkBinding cfg.mappings.toggleOpLeaderLine "<Plug>(comment_toggle_linewise)" mappings.toggleOpLeaderLine.description)
          (mkBinding cfg.mappings.toggleOpLeaderBlock "<Plug>(comment_toggle_blockwise)" mappings.toggleOpLeaderBlock.description)

          (mkExprBinding cfg.mappings.toggleCurrentLine ''
              function()
                return vim.api.nvim_get_vvar('count') == 0 and '<Plug>(comment_toggle_linewise_current)'
                        or '<Plug>(comment_toggle_linewise_count)'
              end
            ''
            mappings.toggleCurrentLine.description)
          (mkExprBinding cfg.mappings.toggleCurrentBlock ''
              function()
                return vim.api.nvim_get_vvar('count') == 0 and '<Plug>(comment_toggle_blockwise_current)'
                        or '<Plug>(comment_toggle_blockwise_count)'
              end
            ''
            mappings.toggleCurrentBlock.description)
        ];

        visualOnly = mkMerge [
          (mkBinding cfg.mappings.toggleSelectedLine "<Plug>(comment_toggle_linewise_visual)" mappings.toggleSelectedLine.description)
          (mkBinding cfg.mappings.toggleSelectedBlock "<Plug>(comment_toggle_blockwise_visual)" mappings.toggleSelectedBlock.description)
        ];
      };

      luaConfigRC.comment-nvim = entryAnywhere ''
        require('Comment').setup({
          mappings = { basic = false, extra = false, },
        })
      '';
    };
  };
}
