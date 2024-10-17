{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetLznBinding pushDownDefault;

  cfg = config.vim.lsp;

  self = import ./trouble.nix {inherit lib;};
  mappingDefinitions = self.options.vim.lsp.trouble.mappings;
  mappings = addDescriptionsToMappings cfg.trouble.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable && cfg.trouble.enable) {
    vim = {
      lazy.plugins.trouble = {
        package = "trouble";
        setupModule = "trouble";
        inherit (cfg.trouble) setupOpts;

        cmd = "Trouble";
        keys = [
          (mkSetLznBinding mappings.toggle "<cmd>TroubleToggle<CR>")
          (mkSetLznBinding mappings.workspaceDiagnostics "<cmd>TroubleToggle workspace_diagnostics<CR>")
          (mkSetLznBinding mappings.documentDiagnostics "<cmd>TroubleToggle document_diagnostics<CR>")
          (mkSetLznBinding mappings.lspReferences "<cmd>TroubleToggle lsp_references<CR>")
          (mkSetLznBinding mappings.quickfix "<cmd>TroubleToggle quickfix<CR>")
          (mkSetLznBinding mappings.locList "<cmd>TroubleToggle loclist<CR>")
        ];
      };

      binds.whichKey.register = pushDownDefault {
        "<leader>l" = "Trouble";
        "<leader>x" = "+Trouble";
        "<leader>lw" = "Workspace";
      };
    };
  };
}
