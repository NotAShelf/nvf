{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.lsp = {
    trouble = {
      enable = mkEnableOption "Enable trouble diagnostics viewer";
    };
  };
}
