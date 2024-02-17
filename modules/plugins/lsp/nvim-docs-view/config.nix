{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim addDescriptionsToMappings mkSetBinding mkMerge;

  cfg = config.vim.lsp.nvim-docs-view;
  self = import ./nvim-docs-view.nix {inherit lib;};

  mappingDefinitions = self.options.vim.lsp.nvim-docs-view.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim = {
      lsp.enable = true;
      startPlugins = ["nvim-docs-view"];

      luaConfigRC.nvim-docs-view = nvim.dag.entryAnywhere ''
        require("docs-view").setup ${nvim.lua.expToLua cfg.setupOpts}
      '';

      maps.normal = mkMerge [
        (mkSetBinding mappings.viewToggle "<cmd>DocsViewToggle<CR>")
        (mkSetBinding mappings.viewUpdate "<cmd>DocsViewUpdate<CR>")
      ];
    };
  };
}
