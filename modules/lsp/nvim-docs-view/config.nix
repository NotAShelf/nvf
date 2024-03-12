{
  config,
  lib,
  ...
}: let
  inherit (builtins) toString;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetBinding;

  cfg = config.vim.lsp.nvim-docs-view;
  self = import ./nvim-docs-view.nix {inherit lib;};

  mappingDefinitions = self.options.vim.lsp.nvim-docs-view.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim = {
      lsp.enable = true;
      startPlugins = ["nvim-docs-view"];

      luaConfigRC.nvim-docs-view = entryAnywhere ''
        require("docs-view").setup {
          position = "${cfg.position}",
          width = ${toString cfg.width},
          height = ${toString cfg.height},
          update_mode = "${cfg.updateMode}",
        }
      '';

      maps.normal = mkMerge [
        (mkSetBinding mappings.viewToggle "<cmd>DocsViewToggle<CR>")
        (mkSetBinding mappings.viewUpdate "<cmd>DocsViewUpdate<CR>")
      ];
    };
  };
}
