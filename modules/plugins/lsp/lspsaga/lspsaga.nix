{lib, ...}: let
  inherit (lib) mkEnableOption mkMappingOption;
in {
  options.vim.lsp.lspsaga = {
    enable = mkEnableOption "LSP Saga";

    mappings = {
      lspFinder = mkMappingOption "LSP Finder [LSPSaga]" "<leader>lf";
      renderHoveredDoc = mkMappingOption "Rendered hovered docs [LSPSaga]" "<leader>lh";

      smartScrollUp = mkMappingOption "Smart scroll up [LSPSaga]" "<C-f>";
      smartScrollDown = mkMappingOption "Smart scroll up [LSPSaga]" "<C-b>";

      rename = mkMappingOption "Rename [LSPSaga]" "<leader>lr";
      previewDefinition = mkMappingOption "Preview definition [LSPSaga]" "<leader>ld";

      showLineDiagnostics = mkMappingOption "Show line diagnostics [LSPSaga]" "<leader>ll";
      showCursorDiagnostics = mkMappingOption "Show cursor diagnostics [LSPSaga]" "<leader>lc";

      nextDiagnostic = mkMappingOption "Next diagnostic [LSPSaga]" "<leader>ln";
      previousDiagnostic = mkMappingOption "Previous diagnostic [LSPSaga]" "<leader>lp";

      codeAction = mkMappingOption "Code action [LSPSaga]" "<leader>ca";

      signatureHelp = mkMappingOption "Signature help [LSPSaga]" "<leader>ls";
    };
  };
}
