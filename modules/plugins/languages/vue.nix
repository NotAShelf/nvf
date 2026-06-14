{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.vue;

  defaultServers = ["vue-language-server" "vtsls"];
  servers = ["vue-language-server" "vtsls" "typescript-language-server" "emmet-ls"];

  defaultFormat = ["biome" "biome-check" "biome-organize-imports"];
  formats = ["biome" "biome-check" "biome-organize-imports" "prettier" "deno"];

  defaultDiagnosticsProvider = ["biomejs"];
  diagnosticsProviders = ["biomejs"];
in {
  options.vim.languages.vue = {
    enable = mkEnableOption "Vue.js language support";

    treesitter = {
      enable =
        mkEnableOption "Vue.js treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      package = mkGrammarOption pkgs "vue";
    };

    lsp = {
      enable =
        mkEnableOption "Vue.js LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Vue.js LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Vue.js formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum formats);
        default = defaultFormat;
        description = "Vue.js formatter to use.";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Vue.js diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Vue.js diagnostics providers";
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
          filetypes = ["vue"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.vue = cfg.format.type;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.vue = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
