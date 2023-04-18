{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with builtins; {
  options.vim.lsp = {
    enable = mkEnableOption "LSP, also enabled automatically through null-ls and lspconfig options";
    formatOnSave = mkEnableOption "format on save";
  };
}
