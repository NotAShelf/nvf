{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.protobuf;
  defaultServers = ["buf"];
  servers = ["buf" "protols"];

  defaultFormat = ["buf"];
  formats = ["buf" "injected"];

  defaultDiagnosticsProvider = ["buf_lint"];
  diagnosticsProviders = ["buf_lint" "protolint"];
in {
  options.vim.languages.protobuf = {
    enable = mkEnableOption "Protobuf configuration language support";

    treesitter = {
      enable =
        mkEnableOption "Protobuf treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "proto";
    };

    lsp = {
      enable =
        mkEnableOption "Protobuf LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        description = "Protobuf LSP server to use";
        type = listOf (enum servers);
        default = defaultServers;
      };
    };

    format = {
      enable =
        mkEnableOption "Protobuf formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "Protobuf formatter to use.";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Protobuf diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };
      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Protobuf diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.package
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["proto"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.proto = cfg.format.type;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.proto = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
