{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.lsp = {
    lspSignature = {
      enable = mkEnableOption "lsp signature viewer";
    };
  };
}
