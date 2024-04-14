{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) attrsOf str;
in {
  options.vim.lsp.lspconfig = {
    enable = mkEnableOption "nvim-lspconfig, also enabled automatically";

    sources = mkOption {
      description = "nvim-lspconfig sources";
      type = attrsOf str;
      default = {};
    };
  };
}
