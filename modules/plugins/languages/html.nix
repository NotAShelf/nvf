{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) bool enum listOf;
  inherit (lib) genAttrs;
  inherit (lib.lists) optional;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.html;

  defaultServers = ["superhtml"];
  servers = ["superhtml" "emmet-ls" "angular-language-server" "stimulus-language-server"];

  defaultFormat = ["superhtml"];
  formats = ["superhtml" "biome" "prettier" "deno"];

  defaultDiagnosticsProvider = ["htmlhint"];
  diagnosticsProviders = ["htmlhint"];
in {
  options.vim.languages.html = {
    enable = mkEnableOption "HTML language support";
    treesitter = {
      enable =
        mkEnableOption "HTML treesitter support"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "html";
      autotagHtml = mkOption {
        type = bool;
        default = true;
        description = "Enable autoclose/autorename of html tags (nvim-ts-autotag)";
      };
    };

    lsp = {
      enable =
        mkEnableOption "HTML LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "HTML LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "HTML formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.html.format.type" (enum formats);
        default = defaultFormat;
        description = "HTML formatter to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra HTML diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra HTML diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim = {
        startPlugins = optional cfg.treesitter.autotagHtml "nvim-ts-autotag";

        treesitter = {
          enable = true;
          grammars = [cfg.treesitter.package];
        };

        pluginRC.html-autotag = mkIf cfg.treesitter.autotagHtml (entryAnywhere ''
          require('nvim-ts-autotag').setup()
        '');
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["html" "xhtml"];
        });
      };
    })

    (mkIf (cfg.format.enable && !cfg.lsp.enable) {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.html = cfg.format.type;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.html = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
