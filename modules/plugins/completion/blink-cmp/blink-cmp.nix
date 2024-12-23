{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) listOf string;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.autocomplete.blink-cmp = {
    enable = mkEnableOption "blink.cmp";
    setupOpts = mkPluginSetupOption "blink.cmp" {
      sources = mkOption {
        type = listOf string;
        description = "List of sources to enable for completion.";
        default = ["lsp" "path" "snippets" "buffer"];
      };
    };
  };
}
