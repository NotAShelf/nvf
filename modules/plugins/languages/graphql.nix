{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum either listOf package str;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.graphql;

  defaultServer = "graphql";
  servers = {
    graphql = {
      package = pkgs.nodePackages.graphql-language-service-cli;
      lspConfig = ''
        lspconfig.graphql.setup {
          capabilities = capabilities;
          on_attach = attach_keymaps,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/graphql-lsp", "server", "-m", "stream"}''
        }
        }
      '';
    };
  };

  defaultFormat = "prettier";
  formats = {
    prettier = {
      package = pkgs.nodePackages.prettier;
    };

    biome = {
      package = pkgs.biome;
    };
  };
in {
  options.vim.languages.graphql = {
    enable = mkEnableOption "Graphql language support";

    treesitter = {
      enable = mkEnableOption "Graphql treesitter" // {default = config.vim.languages.enableTreesitter;};

      graphqlPackage = mkGrammarOption pkgs "graphql";
    };

    lsp = {
      enable = mkEnableOption "Graphql LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Graphql LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Graphql LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };
    format = {
      enable = mkEnableOption "Graphql formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Graphql formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Graphql formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.graphqlPackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.graphql-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.graphql = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })
  ]);
}
