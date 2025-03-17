{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) borderType mkPluginSetupOption;
in {
  options.vim.lsp.lspsaga = {
    enable = mkEnableOption "LSP Saga";

    setupOpts = mkPluginSetupOption "lspsaga" {
      border_style = mkOption {
        type = borderType;
        default = config.vim.ui.borders.globalStyle;
        description = "Border type, see {command}`:help nvim_open_win`";
      };
    };

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
