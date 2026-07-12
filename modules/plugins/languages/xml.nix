{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib) genAttrs;
  inherit (config.vim.lib) mkLanguageLspEnableOption;

  cfg = config.vim.languages.xml;

  defaultServers = ["lemminx"];
  servers = ["lemminx"];
in {
  options.vim.languages.xml = {
    enable = mkEnableOption "XML language support";

    treesitter = {
      enable =
        mkEnableOption "XML treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "xml";
    };

    lsp = {
      enable = mkLanguageLspEnableOption {
        option = "xml";
        display = "XML";
      };
      servers = mkOption {
        type = listOf (enum servers);
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
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["xml"];
        });
      };
    })
  ]);
}
