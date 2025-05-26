{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.lists) isList;
  inherit (lib.types) either listOf package str;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.clojure;
in {
  options.vim.languages.clojure = {
    enable = mkEnableOption "Clojure language support";

    treesitter = {
      enable = mkEnableOption "Clojure treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "clojure";
    };

    lsp = {
      enable = mkEnableOption "Clojure LSP support" // {default = config.vim.lsp.enable;};
      package = mkOption {
        type = either package (listOf str);
        default = pkgs.clojure-lsp;
        description = "Clojure LSP";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.clojure-lsp = ''
        lspconfig.clojure_lsp.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${getExe cfg.lsp.package}"}''
        };
        }
      '';
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })
  ]);
}
