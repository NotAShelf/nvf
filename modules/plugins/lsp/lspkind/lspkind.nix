{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum;
in {
  options.vim.lsp = {
    lspkind = {
      enable = mkEnableOption "vscode-like pictograms for lsp [lspkind]";

      mode = mkOption {
        description = "Defines how annotations are shown";
        type = enum ["text" "text_symbol" "symbol_text" "symbol"];
        default = "symbol_text";
      };
    };
  };
}
