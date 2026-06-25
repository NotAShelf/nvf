{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.just;

  defaultServers = ["just-lsp"];
  servers = ["just-lsp"];
in {
  options.vim.languages.just = {
    enable = mkEnableOption "Just support";

    treesitter = {
      enable =
        mkEnableOption "Just treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "just";
    };

    lsp = {
      enable =
        mkEnableOption "Just LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Just LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["just"];
        });
      };
    })
  ]);
}
