{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.comments.comment-nvim;
  inherit (options.vim.comments.comment-nvim) mappings;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.comment-nvim = {
      package = "comment-nvim";
      setupModule = "Comment";
      inherit (cfg) setupOpts;
      keys = [
        (mkKeymap "n" cfg.mappings.toggleOpLeaderLine "<Plug>(comment_toggle_linewise)" {desc = mappings.toggleOpLeaderLine.description;})
        (mkKeymap "n" cfg.mappings.toggleOpLeaderBlock "<Plug>(comment_toggle_blockwise)" {desc = mappings.toggleOpLeaderBlock.description;})
        (mkKeymap "n" cfg.mappings.toggleCurrentLine ''
            function()
              return vim.api.nvim_get_vvar('count') == 0 and '<Plug>(comment_toggle_linewise_current)'
                      or '<Plug>(comment_toggle_linewise_count)'
            end
          '' {
            lua = true;
            expr = true;
            desc = mappings.toggleCurrentLine.description;
          })
        (mkKeymap ["n"] cfg.mappings.toggleCurrentBlock ''
            function()
              return vim.api.nvim_get_vvar('count') == 0 and '<Plug>(comment_toggle_blockwise_current)'
                      or '<Plug>(comment_toggle_blockwise_count)'
            end
          '' {
            lua = true;
            expr = true;
            desc = mappings.toggleCurrentBlock.description;
          })
        (mkKeymap "x" cfg.mappings.toggleSelectedLine "<Plug>(comment_toggle_linewise_visual)" {desc = mappings.toggleSelectedLine.description;})
        (mkKeymap "x" cfg.mappings.toggleSelectedBlock "<Plug>(comment_toggle_blockwise_visual)" {desc = mappings.toggleSelectedBlock.description;})
      ];
    };
  };
}
