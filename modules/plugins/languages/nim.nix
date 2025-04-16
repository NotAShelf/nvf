{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.languages) lspOptions;

  cfg = config.vim.languages.nim;

  defaultServer = "nimlsp";
  servers = {
    nimlsp = {
      package = pkgs.nimlsp;
      options = {
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''
            {"${cfg.lsp.package}/bin/nimlsp"}
          '';
      };
    };
  };

  defaultFormat = "nimpretty";
  formats = {
    nimpretty = {
      package = pkgs.nim;
      config = {
        command = "${cfg.format.package}/bin/nimpretty";
      };
    };
  };
in {
  options.vim.languages.nim = {
    enable = mkEnableOption "Nim language support";

    treesitter = {
      enable = mkEnableOption "Nim treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "nim";
    };

    lsp = {
      enable = mkEnableOption "Nim LSP support" // {default = config.vim.languages.enableLSP;};
      server = mkOption {
        type = listOf (enum (attrNames servers));
        default = [defaultServer];
        description = "Nim LSP server to use";
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        example = ''[lib.getExe pkgs.nimlsp]'';
        description = "Nim LSP server package, or the command to run as a list of strings";
      };
    };

    format = {
      enable = mkEnableOption "Nim formatting" // {default = config.vim.languages.enableFormat;};
      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Nim formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Nim formatter package";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = !pkgs.stdenv.isDarwin;
          message = "Nim language support is only available on Linux";
        }
      ];
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.nim-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.nim = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = formats.${cfg.format.type}.config;
      };
    })
  ]);
}
