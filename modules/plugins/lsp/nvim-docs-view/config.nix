{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetBinding;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.lsp.nvim-docs-view;

  mappingDefinitions = options.vim.lsp.nvim-docs-view.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim = {
      lsp.enable = true;
      startPlugins = ["nvim-docs-view"];

      pluginRC.nvim-docs-view = entryAnywhere ''
        require("docs-view").setup ${toLuaObject cfg.setupOpts}
      '';

      maps.normal = mkMerge [
        (mkSetBinding mappings.viewToggle "<cmd>DocsViewToggle<CR>")
        (mkSetBinding mappings.viewUpdate "<cmd>DocsViewUpdate<CR>")
      ];
    };
  };
}
