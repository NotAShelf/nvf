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
    lightbulb = {
      enable = mkEnableOption "lightbulb for code actions. Requires emoji font";
    };
  };
}
