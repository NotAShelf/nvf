{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
in {
  options.vim.lsp = {
    lspSignature = {
      enable = mkEnableOption "lsp signature viewer";
    };
  };
}
