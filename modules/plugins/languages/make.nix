{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.types) listOf enum;
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption enumWithRename;

  cfg = config.vim.languages.make;

  defaultFormat = ["mbake"];
  formats = ["mbake"];

  defaultDiagnosticsProvider = ["checkmake"];
  diagnosticsProviders = ["checkmake"];
in {
  options.vim.languages.make = {
    enable = mkEnableOption "Make support";

    treesitter = {
      enable =
        mkEnableOption "Make treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "make";
    };

    format = {
      enable =
        mkEnableOption "Make formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };
      type = mkOption {
        description = "make formatter to use";
        type = listOf (enumWithRename
          "vim.languages.make.format.type"
          formats
          {
            bake = "mbake";
          });
        default = defaultFormat;
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Make diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };
      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Make diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.make = cfg.format.type;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.make = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
