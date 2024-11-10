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
          (mkSetLznBinding "n" mappings.workspaceDiagnostics "<cmd>Trouble toggle diagnostics<CR>")
          (mkSetLznBinding "n" mappings.documentDiagnostics "<cmd>Trouble toggle diagnostics filter.buf=0<CR>")
          (mkSetLznBinding "n" mappings.lspReferences "<cmd>Trouble toggle lsp_references<CR>")
          (mkSetLznBinding "n" mappings.quickfix "<cmd>Trouble toggle quickfix<CR>")
          (mkSetLznBinding "n" mappings.locList "<cmd>Trouble toggle loclist<CR>")
          (mkSetLznBinding "n" mappings.symbols "<cmd>Trouble toggle symbols<CR>")
        ];
      };

      binds.whichKey.register = pushDownDefault {
        "<leader>x" = "+Trouble";
        "<leader>lw" = "+Workspace";
      };
    };
  };
}
