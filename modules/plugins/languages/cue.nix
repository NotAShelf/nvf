{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) package;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.cue;
in {
  options.vim.languages.cue = {
    enable = mkEnableOption "CUE language support";

    treesitter = {
      enable = mkEnableOption "CUE treesitter" // {default = config.vim.languages.enableTreesitter;};

      package = mkGrammarOption pkgs "cue";
    };

    lsp = {
      enable = mkEnableOption "CUE LSP support" // {default = config.vim.lsp.enable;};

      package = mkOption {
        type = package;
        default = pkgs.cue;
        description = "cue lsp implementation";
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
      vim.lsp.lspconfig.sources.cue-lsp = ''
        lspconfig.cue.setup {
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = {"${cfg.lsp.package}/bin/cue", "lsp"},
        }
      '';
    })
  ]);
}
