{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.lsp = {
    lightbulb = {
      enable = mkEnableOption "lightbulb for code actions. Requires emoji font";
    };
  };
}
