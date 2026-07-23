{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.beancount;

  defaultServers = ["beancount-language-server"];
  servers = ["beancount-language-server"];

  defaultFormat = ["bean-format"];
  formats = ["bean-format"];
in {
  options.vim.languages.beancount = {
    enable = mkEnableOption "Beancount language support";

    treesitter = {
      enable =
        mkEnableOption "Beancount treesitter support"
        // {
          default = config.vim.languages.enableTreesitter;
        };
      package = mkGrammarOption pkgs "beancount";
    };

    lsp = {
      enable =
        mkEnableOption "Beancount LSP support"
        // {
          default = config.vim.lsp.enable;
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Beancount LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Beancount formatting"
        // {
          default = config.vim.languages.enableFormat;
        };

      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "Beancount formatter to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      vim.filetype.extension.bean = "beancount";
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["beancount"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.beancount = cfg.format.type;
      };
    })
  ]);
}
