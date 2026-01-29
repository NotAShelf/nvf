{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.jinja;
  defaultServers = ["jinja-lsp"];
  servers = {
    jinja-lsp = {
      enable = true;
      cmd = [(getExe pkgs.jinja-lsp)];
      filetypes = ["jinja"];
      root_markers = [
        ".git"
      ];
    };
  };
in {
  options.vim.languages.jinja = {
    enable = mkEnableOption "Jinja template language support";

    treesitter = {
      enable = mkEnableOption "Jinja treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "jinja";
      inlinePackage = mkGrammarOption pkgs "jinja_inline";
    };

    lsp = {
      enable = mkEnableOption "Jinja LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        description = "Jinja LSP server to use";
        type = listOf (enum (attrNames servers));
        default = defaultServers;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.package
        cfg.treesitter.inlinePackage
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })
  ]);
}
