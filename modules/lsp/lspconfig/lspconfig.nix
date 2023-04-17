{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.lsp.lspconfig = {
    enable = mkEnableOption "nvim-lspconfig, also enabled automatically";

    sources = mkOption {
      description = "nvim-lspconfig sources";
      type = with types; attrsOf str;
      default = {};
    };
  };
}
