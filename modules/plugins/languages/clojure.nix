{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.clojure;

  defaultServers = ["clojure-lsp"];
  servers = {
    clojure-lsp = {
      enable = true;
      cmd = [(getExe pkgs.clojure-lsp)];
      filetypes = ["clojure" "edn"];
      root_markers = ["project.clj" "deps.edn" "build.boot" "shadow-cljs.edn" ".git" "bb.edn"];
    };
  };
in {
  options.vim.languages.clojure = {
    enable = mkEnableOption "Clojure language support";

    treesitter = {
      enable = mkEnableOption "Clojure treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "clojure";
    };

    lsp = {
      enable = mkEnableOption "Clojure LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Clojure LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })
  ]);
}
