{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap pushDownDefault;

  cfg = config.vim.lsp;

  inherit (options.vim.lsp.trouble) mappings;
in {
  config = mkIf (cfg.enable && cfg.trouble.enable) {
    vim = {
      lazy.plugins.trouble = {
        package = "trouble-nvim";
        setupModule = "trouble";
        inherit (cfg.trouble) setupOpts;

        cmd = "Trouble";
        keys = [
          (mkKeymap "n" cfg.trouble.mappings.workspaceDiagnostics "<cmd>Trouble toggle diagnostics<CR>" {desc = mappings.workspaceDiagnostics.description;})
          (mkKeymap "n" cfg.trouble.mappings.documentDiagnostics "<cmd>Trouble toggle diagnostics filter.buf=0<CR>" {desc = mappings.documentDiagnostics.description;})
          (mkKeymap "n" cfg.trouble.mappings.lspReferences "<cmd>Trouble toggle lsp_references<CR>" {desc = mappings.lspReferences.description;})
          (mkKeymap "n" cfg.trouble.mappings.quickfix "<cmd>Trouble toggle quickfix<CR>" {desc = mappings.quickfix.description;})
          (mkKeymap "n" cfg.trouble.mappings.locList "<cmd>Trouble toggle loclist<CR>" {desc = mappings.locList.description;})
          (mkKeymap "n" cfg.trouble.mappings.symbols "<cmd>Trouble toggle symbols<CR>" {desc = mappings.symbols.description;})
        ];
      };

      binds.whichKey.register = pushDownDefault {
        "<leader>x" = "+Trouble";
        "<leader>lw" = "+Workspace";
      };
    };
  };
}
