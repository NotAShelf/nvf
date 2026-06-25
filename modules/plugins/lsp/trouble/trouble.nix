{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.lsp = {
    trouble = {
      enable = mkEnableOption "trouble diagnostics viewer";

      setupOpts = mkPluginSetupOption "Trouble" {};

      mappings = {
        workspaceDiagnostics = mkMappingOption "Workspace diagnostics [trouble]" "<leader>lwd";
        documentDiagnostics = mkMappingOption "Document diagnostics [trouble]" "<leader>ld";
        lspReferences = mkMappingOption "LSP References [trouble]" "<leader>lr";
        quickfix = mkMappingOption "QuickFix [trouble]" "<leader>xq";
        locList = mkMappingOption "LOCList [trouble]" "<leader>xl";
        symbols = mkMappingOption "Symbols [trouble]" "<leader>xs";
      };
    };
  };
}
