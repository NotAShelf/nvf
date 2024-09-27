{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.types) package;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.haskell;
in {
  options.vim.languages.haskell = {
    enable = mkEnableOption "Haskell support";

    treesitter = {
      enable = mkEnableOption "Haskell treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "haskell";
    };

    lsp = {
      enable = mkEnableOption "Haskell LSP support (haskell-language-server)" // {default = true;};

      package = mkOption {
        description = "haskell_ls package";
        type = package;
        default = pkgs.haskellPackages.haskell-language-server;
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
      vim.lsp.lspconfig.sources.haskell-ls = ''
        lspconfig.haskell_ls.setup {
          capabilities = capabilities,
          on_attach=default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{" "${cfg.lsp.package}/bin/haskell-language-server", "}''
        },
        }
      '';
    })
  ]);
}
