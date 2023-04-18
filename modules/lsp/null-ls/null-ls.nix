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
  options.vim.lsp.null-ls = {
    enable = mkEnableOption "null-ls, also enabled automatically";

    sources = mkOption {
      description = "null-ls sources";
      type = with types; attrsOf str;
      default = {};
    };
  };
}
