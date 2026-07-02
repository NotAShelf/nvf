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
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;

  cfg = config.vim.languages.toml;
  defaultServers = ["taplo"];
  servers = ["taplo" "tombi"];

  defaultFormat = ["taplo"];
  formats = ["taplo" "tombi"];

  defaultDiagnosticsProvider = ["tombi"];
  diagnosticsProviders = ["tombi" "taplo"];
in {
  options.vim.languages.toml = {
    enable = mkEnableOption "TOML configuration language support";

    treesitter = {
      enable =
        mkEnableOption "TOML treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "toml";
    };

    lsp = {
      enable =
        mkEnableOption "TOML LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        description = "TOML LSP server to use";
        type = listOf (enum servers);
        default = defaultServers;
      };
    };

    format = {
      enable =
        mkEnableOption "TOML formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.toml.format.type" (enum formats);
        default = defaultFormat;
        description = "TOML formatter to use.";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra TOML diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };
      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra TOML diagnostics providers";
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
          filetypes = ["toml"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.toml = cfg.format.type;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.toml = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
