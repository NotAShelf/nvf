{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib) genAttrs elem;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.pug;

  defaultServers = ["emmet-ls"];
  servers = ["emmet-ls"];

  defaultFormat = ["prettier"];
  formats = ["prettier"];
in {
  options.vim.languages.pug = {
    enable = mkEnableOption "Pug language support";

    treesitter = {
      enable =
        mkEnableOption "Pug treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "pug";
    };

    lsp = {
      enable =
        mkEnableOption "Pug LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Pug LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Pug formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "Pug formatter to use";
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
        servers = genAttrs cfg.lsp.servers (_: {filetypes = ["pug"];});
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.pug = cfg.format.type;
      };
    })

    (mkIf (cfg.format.enable && (elem "prettier" cfg.format.type)) {
      vim.formatter.conform-nvim.presets.prettier.plugins = ["pug"];
    })
  ]);
}
