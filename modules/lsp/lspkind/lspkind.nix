{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;

  cfg = config.vim.lsp;
in {
  options.vim.lsp = {
    lspkind = {
      enable = mkEnableOption "vscode-like pictograms for lsp [lspkind]";

      mode = mkOption {
        description = "Defines how annotations are shown";
        type = with types; enum ["text" "text_symbol" "symbol_text" "symbol"];
        default = "symbol_text";
      };
    };
  };
}
