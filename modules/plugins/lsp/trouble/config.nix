{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetLznBinding pushDownDefault;

  cfg = config.vim.lsp;

  mappingDefinitions = options.vim.lsp.trouble.mappings;
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
          (mkSetLznBinding "n" mappings.toggle "<cmd>TroubleToggle<CR>")
          (mkSetLznBinding "n" mappings.workspaceDiagnostics "<cmd>TroubleToggle workspace_diagnostics<CR>")
          (mkSetLznBinding "n" mappings.documentDiagnostics "<cmd>TroubleToggle document_diagnostics<CR>")
          (mkSetLznBinding "n" mappings.lspReferences "<cmd>TroubleToggle lsp_references<CR>")
          (mkSetLznBinding "n" mappings.quickfix "<cmd>TroubleToggle quickfix<CR>")
          (mkSetLznBinding "n" mappings.locList "<cmd>TroubleToggle loclist<CR>")
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
