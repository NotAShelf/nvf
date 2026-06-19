{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) genAttrs;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.docker;

  defaultServers = ["docker-language-server"];
  servers = ["docker-language-server"];

  defaultFormat = ["dockerfmt"];
  formats = ["dockerfmt"];

  defaultDiagnosticsProvider = ["hadolint"];
  diagnosticsProviders = ["hadolint"];
in {
  options.vim.languages.docker = {
    enable = mkEnableOption "Docker language support";
    treesitter = {
      enable =
        mkEnableOption "Docker treesitter support"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "dockerfile";
    };

    lsp = {
      enable =
        mkEnableOption "Docker LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Docker LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Dockerfile formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "Dockerfile formatter to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Docker diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostic";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Docker diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # Without this the LSP doesn't understand them correctly
      # and there are conflicts with the YAML LSP,
      # thus this module is "stealing" those files.
      vim.filetype.pattern = {
        "compose%.ya?ml" = "dockercompose";
        "docker%-compose%.ya?ml" = "dockercompose";
      };
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
        filetypeMappings = {
          yaml = ["dockercompose"];
        };
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = [
            "dockerfile"
            "dockercompose"
          ];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.dockerfile = cfg.format.type;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.dockerfile = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
