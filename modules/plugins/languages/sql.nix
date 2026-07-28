{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package listOf;

  cfg = config.vim.languages.sql;

  defaultServers = ["sqls"];
  servers = ["sqls"];

  defaultFormat = ["sqlfluff"];
  formats = ["sqlfluff" "sqruff" "injected"];

  defaultDiagnosticsProvider = ["sqlfluff"];
  diagnosticsProviders = ["sqlfluff" "sqruff"];
in {
  options.vim.languages.sql = {
    enable = mkEnableOption "SQL language support";

    treesitter = {
      enable =
        mkEnableOption "SQL treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      package = mkOption {
        type = package;
        default = pkgs.vimPlugins.nvim-treesitter.grammarPlugins.sql;
        description = "SQL treesitter grammar to use";
      };
    };

    lsp = {
      enable =
        mkEnableOption "SQL LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "SQL LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "SQL formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "SQL formatter to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra SQL diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra SQL diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
        queries = [
          # Sets some common highlight groups, ensuring that SQL looks correct in more injections
          {
            type = "highlights";
            filetypes = ["sql"];
            loadtype = "extends";
            query = ''
              (identifier) @variable

              (parameter) @attribute
              (#eq? @attribute "?")
            '';
          }
          # Special comments for some SQL tools
          {
            type = "highlights";
            filetypes = ["sql"];
            loadtype = "extends";
            query = ''
              ((comment) @attribute
                (#match? @attribute "^--(bun:split| \\+goose)"))
            '';
          }
        ];
      };
    })

    (mkIf cfg.lsp.enable {
      vim = {
        lsp = {
          presets = genAttrs cfg.lsp.servers (_: {enable = true;});
          servers = genAttrs cfg.lsp.servers (_: {
            filetypes = ["sql" "mysql" "msql" "plsql"];
          });
        };
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.sql = cfg.format.type;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {
          enable = true;
        });
        nvim-lint = {
          enable = true;
          linters_by_ft.sql = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
