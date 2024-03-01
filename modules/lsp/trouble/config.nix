{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetBinding pushDownDefault;

  cfg = config.vim.lsp;

  self = import ./trouble.nix {inherit lib;};
  mappingDefinitions = self.options.vim.lsp.trouble.mappings;
  mappings = addDescriptionsToMappings cfg.trouble.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable && cfg.trouble.enable) {
    vim = {
      startPlugins = ["trouble"];

      maps.normal = mkMerge [
        (mkSetBinding mappings.toggle "<cmd>TroubleToggle<CR>")
        (mkSetBinding mappings.workspaceDiagnostics "<cmd>TroubleToggle workspace_diagnostics<CR>")
        (mkSetBinding mappings.documentDiagnostics "<cmd>TroubleToggle document_diagnostics<CR>")
        (mkSetBinding mappings.lspReferences "<cmd>TroubleToggle lsp_references<CR>")
        (mkSetBinding mappings.quickfix "<cmd>TroubleToggle quickfix<CR>")
        (mkSetBinding mappings.locList "<cmd>TroubleToggle loclist<CR>")
      ];

      binds.whichKey.register = pushDownDefault {
        "<leader>l" = "Trouble";
        "<leader>x" = "+Trouble";
        "<leader>lw" = "Workspace";
      };

      luaConfigRC.trouble = entryAnywhere ''
        -- Enable trouble diagnostics viewer
        require("trouble").setup {}
      '';
    };
  };
}
