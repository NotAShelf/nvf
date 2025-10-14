{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.beancount;

  defaultServers = "beancount-language-server";
  servers = {
    beancount-language-server = {
      rootmarkers = [".git"];
      filetypes = ["beancount" "bean"];
      cmd = [(getExe' pkgs.beancount-language-server "beancount-language-server")];
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

      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
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
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
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
