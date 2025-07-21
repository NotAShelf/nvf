{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.types) mkGrammarOption mkServersOption;
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
      servers = mkServersOption "Clojure" servers defaultServers;
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
