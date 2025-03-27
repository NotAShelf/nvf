{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) either listOf package str enum;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;

  defaultServer = "fsautocomplete";
  servers = {
    fsautocomplete = {
      package = pkgs.fsautocomplete;
      internalFormatter = false;
      lspConfig = ''
        lspconfig.fsautocomplete.setup {
          capabilities = capabilities;
          on_attach = default_on_attach;
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else "{'${cfg.lsp.package}/bin/fsautocomplete'}"
        },
        }
      '';
    };
  };

  defaultFormat = "fantomas";
  formats = {
    fantomas = {
      package = pkgs.fantomas;
    };
  };

  cfg = config.vim.languages.fsharp;
in {
  options = {
    vim.languages.fsharp = {
      enable = mkEnableOption "F# language support";

      treesitter = {
        enable = mkEnableOption "F# treesitter" // {default = config.vim.languages.enableTreesitter;};
        package = mkGrammarOption pkgs "fsharp";
      };

      lsp = {
        enable = mkEnableOption "F# LSP support" // {default = config.vim.languages.enableLSP;};
        server = mkOption {
          type = enum (attrNames servers);
          default = defaultServer;
          description = "F# LSP server to use";
        };

        package = mkOption {
          type = either package (listOf str);
          default = servers.${cfg.lsp.server}.package;
          example = ''[lib.getExe pkgs.fsautocomplete "--state-directory" "~/.cache/fsautocomplete"]'';
          description = "F# LSP server package, or the command to run as a list of strings";
        };
      };
      format = {
        enable = mkEnableOption "F# formatting" // {default = config.vim.languages.enableFormat;};

        type = mkOption {
          type = enum (attrNames formats);
          default = defaultFormat;
          description = "F# formatter to use";
        };

        package = mkOption {
          type = package;
          default = formats.${cfg.format.type}.package;
          description = "F# formatter package";
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.fsharp-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.fsharp = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })
  ]);
}
