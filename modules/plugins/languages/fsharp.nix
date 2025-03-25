{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) either listOf package str enum;
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
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.fantomas.with({
            command = "${cfg.format.package}/bin/fantomas",
          })
        )
      '';
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
          description = "F# LSP server to use";
          default = defaultServer;
        };

        package = mkOption {
          type = either package (listOf str);
          description = "F# LSP server package, or the command to run as a list of strings";
          default = servers.${cfg.lsp.server}.package;
        };
      };
      format = {
        enable = mkEnableOption "F# formatting" // {default = config.vim.languages.enableFormat;};

        type = mkOption {
          type = enum (attrNames formats);
          description = "F# formatter to use";
          default = defaultFormat;
        };

        package = mkOption {
          type = package;
          description = "F# formatter package";
          default = formats.${cfg.format.type}.package;
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
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.fsharp-format = formats.${cfg.format.type}.nullConfig;
    })
  ]);
}
