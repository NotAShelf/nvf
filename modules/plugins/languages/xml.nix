{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.xml;

  defaultServers = ["lemminx"];
  servers = {
    lemminx = {
      enable = true;
      cmd = [
        (getExe pkgs.lemminx)
      ];
      filetypes = ["xml"];
      root_markers = [".git"];
    };
  };
in {
  options.vim.languages.xml = {
    enable = mkEnableOption "XML language support";

    treesitter = {
      enable = mkEnableOption "XML treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "xml";
    };

    lsp = {
      enable = mkEnableOption "XML LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "XML LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (name: {
          inherit name;
          value = servers.${name};
        })
        cfg.lsp.servers;
    })
  ]);
}
