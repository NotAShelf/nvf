{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs elem;
  inherit (lib.types) enum coercedTo listOf;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;

  cfg = config.vim.languages.svelte;

  defaultServers = ["svelte-language-server"];
  servers = ["svelte-language-server" "emmet-ls"];

  defaultFormat = ["prettier"];
  formats = ["prettier" "biome" "biome-check" "biome-organize-imports" "deno"];

  defaultDiagnosticsProvider = ["eslint_d"];
  diagnosticsProviders = ["eslint_d"];

  formatType =
    deprecatedSingleOrListOf
    "vim.languages.svelte.format.type"
    (coercedTo (enum ["prettierd"]) (_:
      lib.warn
      "vim.languages.svelte.format.type: prettierd is deprecated, use prettier instead"
      "prettier")
    (enum formats));
in {
  options.vim.languages.svelte = {
    enable = mkEnableOption "Svelte language support";

    treesitter = {
      enable =
        mkEnableOption "Svelte treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      sveltePackage = mkGrammarOption pkgs "svelte";
    };

    lsp = {
      enable =
        mkEnableOption "Svelte LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Svelte LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Svelte formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = formatType;
        default = defaultFormat;
        description = "Svelte formatter to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Svelte diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Svelte diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.sveltePackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["svelte"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.svelte = cfg.format.type;
      };
    })

    (mkIf (cfg.format.enable && (elem "prettier" cfg.format.type)) {
      vim.formatter.conform-nvim.presets.prettier.plugins = ["svelte"];
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.svelte = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
