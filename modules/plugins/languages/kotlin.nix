{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.kotlin;

  defaultServers = ["kotlin-language-server"];
  servers = ["kotlin-language-server"];

  defaultDiagnosticsProvider = ["ktlint"];
  diagnosticsProviders = ["ktlint"];
in {
  options.vim.languages.kotlin = {
    enable = mkEnableOption "Kotlin/HCL support";

    treesitter = {
      enable =
        mkEnableOption "Kotlin treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "kotlin";
    };

    lsp = {
      enable =
        mkEnableOption "Kotlin LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Kotlin LSP server to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Kotlin diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Kotlin diagnostics providers";
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.kotlin = cfg.extraDiagnostics.types;
        };
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {
          enable = [
            {
              value = true;
              src = ["vim" "languages" "kotlin" "lsp" "servers"];
            }
          ];
        });
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["kotlin"];
        });
      };
    })
  ]);
}
