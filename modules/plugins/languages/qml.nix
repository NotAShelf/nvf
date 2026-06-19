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
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;

  cfg = config.vim.languages.qml;

  defaultServers = ["qmlls"];
  servers = ["qmlls"];

  defaultFormat = ["qmlformat"];
  formats = ["qmlformat"];
in {
  options.vim.languages.qml = {
    enable = mkEnableOption "QML language support";
    treesitter = {
      enable =
        mkEnableOption "QML treesitter support"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "qmljs";
    };

    lsp = {
      enable =
        mkEnableOption "QML LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "QML LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "QML formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.qml.format.type" (enum formats);
        default = defaultFormat;
        description = "QML formatter to use";
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
          filetypes = ["qml"];
        });
      };
    })

    (mkIf (cfg.format.enable && !cfg.lsp.enable) {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.qml = cfg.format.type;
      };
    })
  ]);
}
