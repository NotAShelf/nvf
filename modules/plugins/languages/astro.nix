{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum coercedTo listOf;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf enumWithRename;
  inherit (lib) genAttrs elem;

  cfg = config.vim.languages.astro;

  defaultServers = ["astro-language-server"];
  servers = ["astro-language-server" "emmet-ls"];

  defaultFormat = ["prettier"];
  formats = ["prettier" "biome" "biome-check" "biome-organize-imports" "astro"];

  defaultDiagnosticsProvider = ["eslint_d"];
  diagnosticsProviders = ["eslint_d"];

  formatType =
    deprecatedSingleOrListOf
    "vim.languages.astro.format.type"
    (coercedTo (enum ["prettierd"]) (_:
      lib.warn
      "vim.languages.astro.format.type: prettierd is deprecated, use prettier instead"
      "prettier")
    (enum formats));
in {
  options.vim.languages.astro = {
    enable = mkEnableOption "Astro language support";

    treesitter = {
      enable =
        mkEnableOption "Astro treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      astroPackage = mkGrammarOption pkgs "astro";
    };

    lsp = {
      enable =
        mkEnableOption "Astro LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.astro.lsp.servers"
          servers
          {
            astro = "astro-language-server";
          });
        default = defaultServers;
        description = "Astro LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Astro formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = formatType;
        default = defaultFormat;
        description = "Astro formatter to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Astro diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Astro diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.astroPackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["astro"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets =
          genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.astro = cfg.format.type;
      };
    })

    (mkIf (cfg.format.enable && (elem "prettier" cfg.format.type)) {
      vim.formatter.conform-nvim.presets.prettier.plugins = ["astro"];
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.astro = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
