{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) attrsOf str;
in {
  options.vim.lsp.null-ls = {
    enable = mkEnableOption "null-ls, also enabled automatically";

    sources = mkOption {
      description = "null-ls sources";
      type = attrsOf str;
      default = {};
    };
  };
}
