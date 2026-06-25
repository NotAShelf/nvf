{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) listOf;
  inherit (lib.nvim.types) mkGrammarOption enumWithRename;

  cfg = config.vim.languages.vala;

  defaultServers = ["vala-language-server"];
  servers = ["vala-language-server"];
in {
  options.vim.languages.vala = {
    enable = mkEnableOption "Vala language support";

    treesitter = {
      enable =
        mkEnableOption "Vala treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "vala";
    };

    lsp = {
      enable =
        mkEnableOption "Vala LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.vala.lsp.servers"
          servers
          {
            vala_ls = "vala-language-server";
          });
        default = defaultServers;
        description = "Vala LSP server to use";
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
          filetypes = ["vala"];
        });
      };
    })
  ]);
}
