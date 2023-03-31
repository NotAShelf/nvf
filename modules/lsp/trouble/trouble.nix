{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.lsp = {
    trouble = {
      enable = mkEnableOption "trouble diagnostics viewer";
    };
  };
}
