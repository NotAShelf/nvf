{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum coercedTo listOf;
  inherit (lib.attrsets) genAttrs;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.tsx;

  defaultServers = ["typescript-language-server"];
  servers = ["typescript-language-server" "deno" "typescript-go" "emmet-ls"];

  defaultFormat = ["prettier"];
  formats = ["prettier" "biome" "biome-check" "biome-organize-imports" "deno"];
  formatType = listOf (coercedTo (enum ["prettierd"]) (_:
    lib.warn
    "vim.languages.tsx.format.type: prettierd is deprecated, use prettier instead"
    "prettier")
  (enum formats));

  defaultDiagnosticsProvider = ["biomejs"];
  diagnosticsProviders = ["biomejs"];
in {
  options.vim.languages.tsx = {
    enable = mkEnableOption "Typescript XML (TSX) language support";

    treesitter = {
      enable =
        mkEnableOption "Typescript XML (TSX) treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "tsx";
    };

    lsp = {
      enable =
        mkEnableOption "Typescript XML (TSX) LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Typescript XML (TSX) LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Typescript XML (TSX) formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "Typescript XML (TSX) formatter to use";
        type = formatType;
        default = defaultFormat;
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Typescript XML (TSX) diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Typescript XML (TSX) diagnostics providers";
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

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = [
            "typescriptreact"
            "javascriptreact"
          ];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft = {
          typescriptreact = cfg.format.type;
          javascriptreact = cfg.format.type;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft = {
            typescriptreact = cfg.extraDiagnostics.types;
            javascriptreact = cfg.extraDiagnostics.types;
          };
        };
      };
    })
  ]);
}
