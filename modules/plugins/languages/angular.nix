{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib) genAttrs elem;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.angular;

  defaultServers = ["angular-language-server"];
  servers = ["angular-language-server" "emmet-ls"];

  defaultFormat = ["prettier"];
  formats = ["prettier" "deno"];
in {
  options.vim.languages.angular = {
    enable = mkEnableOption "Angular language support";
    treesitter = {
      enable =
        mkEnableOption "Angular treesitter support"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "angular";
    };

    lsp = {
      enable =
        mkEnableOption "Angular LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Angular LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Angular formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "Angular formatter to use";
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
          filetypes = ["htmlangular"];
        });
      };
    })

    (mkIf (cfg.lsp.enable && elem "angular-language-server" cfg.lsp.servers) {
      vim.lsp.servers.angular-language-serve.filetypes = ["typescript"];
    })

    (mkIf (cfg.format.enable && !cfg.lsp.enable) {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.htmlangular = cfg.format.type;
      };
    })
  ]);
}
