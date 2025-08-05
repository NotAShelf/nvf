{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) package;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.assembly;
in {
  options.vim.languages.assembly = {
    enable = mkEnableOption "Assembly support";

    treesitter = {
      enable = mkEnableOption "Assembly treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "asm";
    };

    lsp = {
      enable = mkEnableOption "Assembly LSP support (asm-lsp)" // {default = config.vim.lsp.enable;};

      package = mkOption {
        type = package;
        default = pkgs.asm-lsp;
        description = "asm-lsp package";
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.asm-lsp = ''
        lspconfig.asm_lsp.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = {"${cfg.lsp.package}/bin/asm-lsp"},
        }
      '';
    })
  ]);
}
