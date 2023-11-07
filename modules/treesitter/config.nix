{
  config,
  lib,
  ...
}: let
  inherit (lib) addDescriptionsToMappings mkIf optional mkSetBinding mkMerge nvim;

  cfg = config.vim.treesitter;
  usingNvimCmp = config.vim.autocomplete.enable && config.vim.autocomplete.type == "nvim-cmp";

  self = import ./treesitter.nix {inherit lib;};

  mappingDefinitions = self.options.vim.treesitter.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim.startPlugins =
      ["nvim-treesitter"]
      ++ optional usingNvimCmp "cmp-treesitter";

    vim.autocomplete.sources = {"treesitter" = "[Treesitter]";};

    # For some reason, using mkSetLuaBinding and putting the lua code does not work. It just selects the whole file.
    # This works though, and if it ain't broke, don't fix it.
    vim.maps.normal = mkSetBinding mappings.incrementalSelection.init ":lua require('nvim-treesitter.incremental_selection').init_selection()<CR>";

    vim.maps.visualOnly = mkMerge [
      (mkSetBinding mappings.incrementalSelection.incrementByNode ":lua require('nvim-treesitter.incremental_selection').node_incremental()<CR>")
      (mkSetBinding mappings.incrementalSelection.incrementByScope ":lua require('nvim-treesitter.incremental_selection').scope_incremental()<CR>")
      (mkSetBinding mappings.incrementalSelection.decrementByNode ":lua require('nvim-treesitter.incremental_selection').node_decremental()<CR>")
    ];

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
            init_selection = false,
            node_incremental = false,
            scope_incremental = false,
            node_decremental = false,
          },
        },
      }
    '';
  };
}
