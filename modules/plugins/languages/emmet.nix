{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) package;

  cfg = config.vim.languages.emmet;
in {
  options.vim.languages.emmet = {
    enable = mkEnableOption "Emmet support";
    # No treesitter options, as this lsp only adds completions

    lsp = {
      enable = mkEnableOption "Emmet LSP support (emmet-language-server)" // {default = config.vim.languages.enableLSP;};

      package = mkOption {
        type = package;
        default = pkgs.emmet-language-server;
        description = "emmet-language-server package";
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.emmet_language_server = ''
        lspconfig.emmet_language_server.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = { "${cfg.lsp.package}/bin/emmet-language-server", "--stdio" }
        }
      '';
    })
  ]);
}
