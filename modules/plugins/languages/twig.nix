{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) listOf enum;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.twig;

  defaultServers = ["twig-language-server"];
  servers = ["twig-language-server" "emmet-ls" "stimulus-language-server"];

  defaultFormat = ["djlint"];
  formats = ["djlint"];

  defaultDiagnosticsProvider = ["djlint"];
  # TODO: if curlylint gets packaged for nix, add it.
  diagnosticsProviders = ["djlint"];
in {
  options.vim.languages.twig = {
    enable = mkEnableOption "Twig templating language support";

    treesitter = {
      enable =
        mkEnableOption "Twig treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "twig";
    };

    lsp = {
      enable =
        mkEnableOption "Twig LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Twig LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "PHP formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };
      type = mkOption {
        description = "Twig formatter to use";
        type = listOf (enum formats);
        default = defaultFormat;
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Twig diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };
      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Twig diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["twig"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.twig = cfg.format.type;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.twig = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
