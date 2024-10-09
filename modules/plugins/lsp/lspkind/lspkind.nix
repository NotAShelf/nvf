{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum nullOr;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.lsp.lspkind = {
    enable = mkEnableOption "vscode-like pictograms for lsp [lspkind]";
    setupOpts = mkPluginSetupOption "lspkind.nvim" {
      mode = mkOption {
        description = "Defines how annotations are shown";
        type = enum ["text" "text_symbol" "symbol_text" "symbol"];
        default = "symbol_text";
      };

      before = mkOption {
        description = "The function that will be called before lspkind's modifications are applied";
        type = nullOr luaInline;
        default = null;
      };
    };
  };
}
