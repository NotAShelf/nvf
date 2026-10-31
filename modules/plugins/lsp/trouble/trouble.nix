{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  mkMappingOption = config.vim.lib.mkMappingOption "trouble";
in {
  options.vim.lsp = {
    trouble = {
      enable = mkEnableOption "trouble diagnostics viewer";

      setupOpts = mkPluginSetupOption "Trouble" {};

      mappings = {
        workspaceDiagnostics = mkMappingOption "Workspace diagnostics" "<leader>lwd";
        documentDiagnostics = mkMappingOption "Document diagnostics" "<leader>ld";
        lspReferences = mkMappingOption "LSP References" "<leader>lr";
        quickfix = mkMappingOption "QuickFix" "<leader>xq";
        locList = mkMappingOption "LOCList" "<leader>xl";
        symbols = mkMappingOption "Symbols" "<leader>xs";
      };
    };
  };
}
