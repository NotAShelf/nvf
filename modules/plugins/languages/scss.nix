{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum coercedTo listOf;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.scss;

  defaultServer = ["some-sass-language-server"];
  servers = ["some-sass-language-server" "vscode-css-language-server" "emmet-ls"];

  defaultFormat = ["prettier"];
  formats = ["prettier" "deno"];

  formatType = listOf (coercedTo (enum ["prettierd"]) (_:
    lib.warn
    "vim.languages.scss.format.type: prettierd is deprecated, use prettier instead"
    "prettier")
  (enum formats));

  defaultDiagnosticsProvider = ["stylelint"];
  diagnosticsProviders = ["stylelint"];
in {
  options.vim.languages.scss = {
    enable = mkEnableOption "SCSS/SASS language support";

    treesitter = {
      enable =
        mkEnableOption "SCSS/SASS treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "scss";
    };

    lsp = {
      enable =
        mkEnableOption "SCSS/SASS LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServer;
        description = "SCSS/SASS LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "SCSS/SASS formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };
      type = mkOption {
        description = "SCSS/SASS formatter to use";
        type = formatType;
        default = defaultFormat;
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra SCSS/SASS diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };
      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra SCSS/SASS diagnostics providers";
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
          filetypes = [
            "scss"
            "sass"
          ];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft = {
          scss = cfg.format.type;
          sass = cfg.format.type;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft = {
            scss = cfg.extraDiagnostics.types;
            sass = cfg.extraDiagnostics.types;
          };
        };
      };
    })
  ]);
}
