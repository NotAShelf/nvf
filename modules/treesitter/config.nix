{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.treesitter;
  usingNvimCmp = config.vim.autocomplete.enable && config.vim.autocomplete.type == "nvim-cmp";
in {
  config = mkIf cfg.enable {
    vim.startPlugins =
      ["nvim-treesitter"]
      ++ optional usingNvimCmp "cmp-treesitter";

    vim.autocomplete.sources = {"treesitter" = "[Treesitter]";};

    # For some reason treesitter highlighting does not work on start if this is set before syntax on
    vim.configRC.treesitter-fold = mkIf cfg.fold (nvim.dag.entryBefore ["basic"] ''
      set foldmethod=expr
      set foldexpr=nvim_treesitter#foldexpr()
      set nofoldenable
    '');

    vim.luaConfigRC.treesitter = nvim.dag.entryAnywhere ''
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
      }
    '';
  };
}
