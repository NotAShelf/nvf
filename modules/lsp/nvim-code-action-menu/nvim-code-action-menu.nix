{lib, ...}:
with lib; {
  options.vim.lsp = {
    nvimCodeActionMenu = {
      enable = mkEnableOption "Enable nvim code action menu";

      mappings = {
        open = mkMappingOption "Open code action menu [nvim-code-action-menu]" "<leader>ca";
      };
    };
  };
}
