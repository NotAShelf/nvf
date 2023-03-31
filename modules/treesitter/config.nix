{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.treesitter;
in {
  config = mkIf cfg.enable (
    let
      writeIf = cond: msg:
        if cond
        then msg
        else "";
    in {
      vim.startPlugins = [
        "nvim-treesitter"
        (
          if cfg.autotagHtml
          then "nvim-ts-autotag"
          else null
        )
      ];

      # For some reason treesitter highlighting does not work on start if this is set before syntax on
      vim.configRC.treesitter = writeIf cfg.fold (nvim.dag.entryBefore ["basic"] ''
        " Tree-sitter based folding
        set foldmethod=expr
        set foldexpr=nvim_treesitter#foldexpr()
        set nofoldenable
      '');

      vim.luaConfigRC.treesitter = nvim.dag.entryAnywhere ''
        -- Treesitter config
        require'nvim-treesitter.configs'.setup {
          highlight = {
            enable = true,
            disable = {},
          },

          auto_install = false,
          ensure_installed = {},

          incremental_selection = {
            enable = true,
            keymaps = {
              init_selection = "gnn",
              node_incremental = "grn",
              scope_incremental = "grc",
              node_decremental = "grm",
            },
          },

          ${writeIf cfg.autotagHtml ''
          autotag = {
            enable = true,
          },
        ''}
        }
      '';
    }
  );
}
