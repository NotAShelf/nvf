{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkLznExprBinding mkLznBinding;

  cfg = config.vim.comments.comment-nvim;
  self = import ./comment-nvim.nix {inherit lib;};
  inherit (self.options.vim.comments.comment-nvim) mappings;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "comment-nvim"
    ];

    vim.lazy.plugins = [
      {
        package = "comment-nvim";
        setupModule = "Comment";
        inherit (cfg) setupOpts;
        keys = [
          (mkLznBinding ["n"] cfg.mappings.toggleOpLeaderLine "<Plug>(comment_toggle_linewise)" mappings.toggleOpLeaderLine.description)
          (mkLznBinding ["n"] cfg.mappings.toggleOpLeaderBlock "<Plug>(comment_toggle_blockwise)" mappings.toggleOpLeaderBlock.description)

          (mkLznExprBinding ["n"] cfg.mappings.toggleCurrentLine ''
              function()
                return vim.api.nvim_get_vvar('count') == 0 and '<Plug>(comment_toggle_linewise_current)'
                        or '<Plug>(comment_toggle_linewise_count)'
              end
            ''
            mappings.toggleCurrentLine.description)
          (mkLznExprBinding ["n"] cfg.mappings.toggleCurrentBlock ''
              function()
                return vim.api.nvim_get_vvar('count') == 0 and '<Plug>(comment_toggle_blockwise_current)'
                        or '<Plug>(comment_toggle_blockwise_count)'
              end
            ''
            mappings.toggleCurrentBlock.description)
          (mkLznBinding ["x"] cfg.mappings.toggleSelectedLine "<Plug>(comment_toggle_linewise_visual)" mappings.toggleSelectedLine.description)
          (mkLznBinding ["x"] cfg.mappings.toggleSelectedBlock "<Plug>(comment_toggle_blockwise_visual)" mappings.toggleSelectedBlock.description)
        ];
      }
    ];
  };
}
