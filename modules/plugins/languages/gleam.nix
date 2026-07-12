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

  cfg = config.vim.languages.gleam;

  defaultServers = ["gleam"];
  servers = ["gleam"];
in {
  options.vim.languages.gleam = {
    enable = mkEnableOption "Gleam language support";

    treesitter = {
      enable =
        mkEnableOption "Gleam treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "gleam";
    };

    lsp = {
      enable = mkLanguageLspEnableOption {
        option = "gleam";
        display = "Gleam";
      };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Gleam LSP server to use";
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
          filetypes = ["gleam"];
        });
      };
    })
  ]);
}
