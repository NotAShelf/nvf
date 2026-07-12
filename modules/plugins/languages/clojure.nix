{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (config.vim.lib) mkLanguageLspEnableOption;

  cfg = config.vim.languages.clojure;

  defaultServers = ["clojure-lsp"];
  servers = ["clojure-lsp"];
in {
  options.vim.languages.clojure = {
    enable = mkEnableOption "Clojure language support";

    treesitter = {
      enable =
        mkEnableOption "Clojure treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "clojure";
    };

    lsp = {
      enable = mkLanguageLspEnableOption {
        option = "clojure";
        display = "Clojure";
      };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Clojure LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["clojure" "edn"];
          root_markers = ["deps.edn" "build.boot" "shadow-cljs.edn" "bb.edn"];
        });
      };
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })
  ]);
}
