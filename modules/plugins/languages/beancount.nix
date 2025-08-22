{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) anything attrsOf either enum listOf package nullOr str;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.beancount;

  defaultServer = "beancount-language-server";
  servers = {
    beancount-language-server = {
      rootmarkers = [".git"];
      filetypes = ["beancount" "bean"];
      init_options = mkIf (null != cfg.lsp.initOptions) cfg.lsp.initOptions;
      cmd =
        if (isList cfg.lsp.package)
        then cfg.lsp.package
        else [(getExe' cfg.lsp.package cfg.lsp.server)];
    };
  };

  defaultFormat = "bean-format";
  formats = {
    bean-format = {
      package = pkgs.beancount;
    };
  };
in {
  options.vim.languages.beancount = {
    enable = mkEnableOption "Beancount language support";

    treesitter = {
      enable = mkEnableOption "Beancount treesitter support" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "beancount";
    };

    lsp = {
      enable = mkEnableOption "Beancount LSP support" // {default = config.vim.lsp.enable;};

      server = mkOption {
        type = enum (attrNames servers);
        default = defaultServer;
        description = ''
          Beancount LSP server to use.

          ::: {.note}
          'beancount-language-server' requires 'bean-check' and 'bean-format'.
          Both are provided by 'pkgs.beancount'. These binaries must be in
          your PATH or in 'vim.extraPackages'. There are no additional checks
          to verify if this requirement is met.
          :::
        '';
      };

      package = mkOption {
        type = either package (listOf str);
        default = pkgs.beancount-language-server;
        example = literalExpression ''[lib.getExe pkgs.beancount-language-server]'';
        description = "Beancount LSP package, or the command to run as a list of strings";
      };

      initOptions = mkOption {
        type = nullOr (attrsOf anything);
        default = null;
        example = ''
          journal_file = "/path/to/main.beancount";
          formatting = {
            prefix_width = 30;
            currency_column = 60;
            number_currency_spacing = 1;
          };
        '';
        description = "Init options to pass to beancount-language-server";
      };
    };

    format = {
      enable = mkEnableOption "Beancount formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Beancount formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Beancount formatter package";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers.${cfg.lsp.server} = servers.${cfg.lsp.server};
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.beancount = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe' cfg.format.package cfg.format.type;
        };
      };
    })
  ]);
}
