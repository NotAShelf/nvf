{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption literalExpression mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.types) enum listOf;
  inherit (lib) genAttrs;

  defaultServers = ["cue"];
  servers = ["cue"];

  cfg = config.vim.languages.cue;
in {
  options.vim.languages.cue = {
    enable = mkEnableOption "CUE language support";

    treesitter = {
      enable =
        mkEnableOption "CUE treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      package = mkGrammarOption pkgs "cue";
    };

    lsp = {
      enable =
        mkEnableOption "CUE LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "CUE LSP server to use";
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
          filetypes = ["cue"];
        });
      };
    })
  ]);
}
