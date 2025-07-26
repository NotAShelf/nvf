{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.lsp = {
    trouble = {
      enable = mkEnableOption "trouble diagnostics viewer";

      setupOpts = mkPluginSetupOption "Trouble" {};

      mappings = {
        workspaceDiagnostics = mkMappingOption config.vim.enableNvfKeymaps "Workspace diagnostics [trouble]" "<leader>lwd";
        documentDiagnostics = mkMappingOption config.vim.enableNvfKeymaps "Document diagnostics [trouble]" "<leader>ld";
        lspReferences = mkMappingOption config.vim.enableNvfKeymaps "LSP References [trouble]" "<leader>lr";
        quickfix = mkMappingOption config.vim.enableNvfKeymaps "QuickFix [trouble]" "<leader>xq";
        locList = mkMappingOption config.vim.enableNvfKeymaps "LOCList [trouble]" "<leader>xl";
        symbols = mkMappingOption config.vim.enableNvfKeymaps "Symbols [trouble]" "<leader>xs";
      };
    };
  };
}
