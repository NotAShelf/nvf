{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.toml;
  defaultServers = ["taplo"];
  servers = ["taplo" "tombi"];

  defaultFormat = ["taplo"];
  formats = {
    tombi = {
      command = getExe pkgs.tombi;
      args = [
        "format"
        "--stdin-filepath"
        "$FILENAME"
        "-"
      ];
    };
    taplo = {
      command = getExe pkgs.taplo;
      args = [
        "format"
        "--stdin-filepath"
        "$FILENAME"
        "-"
      ];
    };
  };
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
        type = deprecatedSingleOrListOf "vim.language.toml.format.type" (enum (attrNames formats));
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
        presets = genAttrs cfg.lsp.servers (_: {
          enable = [
            {
              value = true;
              src = ["vim" "languages" "toml" "lsp" "servers"];
            }
          ];
        });
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["toml"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.toml = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
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
