{lib, ...}: let
  inherit (lib) mkEnableOption mkMappingOption;
in {
  options.vim.lsp = {
    trouble = {
      enable = mkEnableOption "trouble diagnostics viewer";

      mappings = {
        toggle = mkMappingOption "Toggle trouble [trouble]" "<leader>xx";
        workspaceDiagnostics = mkMappingOption "Workspace diagnostics [trouble]" "<leader>lwd";
        documentDiagnostics = mkMappingOption "Document diagnostics [trouble]" "<leader>ld";
        lspReferences = mkMappingOption "LSP References [trouble]" "<leader>lr";
        quickfix = mkMappingOption "QuickFix [trouble]" "<leader>xq";
        locList = mkMappingOption "LOCList [trouble]" "<leader>xl";
      };
    };
  };
}
