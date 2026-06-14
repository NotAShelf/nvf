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
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf enumWithRename;

  cfg = config.vim.languages.css;

  defaultServer = ["vscode-css-language-server"];
  servers = ["vscode-css-language-server" "emmet-ls"];

  defaultFormat = ["prettier"];
  formats = ["prettier" "biome" "biome-check" "biome-organize-imports" "deno"];

  formatType =
    deprecatedSingleOrListOf
    "vim.languages.css.format.type"
    (coercedTo (enum ["prettierd"]) (_:
      lib.warn
      "vim.languages.css.format.type: prettierd is deprecated, use prettier instead"
      "prettier")
    (enum formats));
in {
  options.vim.languages.css = {
    enable = mkEnableOption "CSS language support";

    treesitter = {
      enable =
        mkEnableOption "CSS treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      package = mkGrammarOption pkgs "css";
    };

    lsp = {
      enable =
        mkEnableOption "CSS LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.css.lsp.servers"
          servers
          {
            cssls = "vscode-css-language-server";
          });
        default = defaultServer;
        description = "CSS LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "CSS formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "CSS formatter to use";
        type = formatType;
        default = defaultFormat;
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
            "css"
            # TODO: split in their own modules
            "less"
          ];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.css = cfg.format.type;
      };
    })
  ]);
}
