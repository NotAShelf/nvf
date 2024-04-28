{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.lsp = {
    lspSignature = {
      enable = mkEnableOption "lsp signature viewer";
      setupOpts = mkPluginSetupOption "lsp-signature" {};
    };
  };
}
