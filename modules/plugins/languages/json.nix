{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum coercedTo listOf;
  inherit (lib) genAttrs;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf enumWithRename;

  cfg = config.vim.languages.json;

  defaultServers = ["vscode-json-language-server"];
  servers = ["vscode-json-language-server"];

  defaultFormat = ["jsonfmt"];
  formats = ["jsonfmt" "prettier" "biome" "deno"];

  formatType =
    deprecatedSingleOrListOf
    "vim.languages.json.format.type"
    (coercedTo (enum ["prettierd"]) (_:
      lib.warn
      "vim.languages.json.format.type: prettierd is deprecated, use prettier instead"
      "prettier")
    (enum formats));
in {
  options.vim.languages.json = {
    enable = mkEnableOption "JSON language support";

    treesitter = {
      enable =
        mkEnableOption "JSON treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      jsonPackage = mkGrammarOption pkgs "json";
      json5Package = mkGrammarOption pkgs "json5";
    };

    lsp = {
      enable =
        mkEnableOption "JSON LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.json.lsp.servers"
          servers
          {
            jsonls = "vscode-json-language-server";
          });
        default = defaultServers;
        description = "JSON LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "JSON formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "JSON formatter to use";
        type = formatType;
        default = defaultFormat;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [
        cfg.treesitter.jsonPackage
        cfg.treesitter.json5Package
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["json" "jsonc" "json5"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft = {
          json = cfg.format.type;
          jsonc = cfg.format.type;
          json5 = cfg.format.type;
        };
      };
    })
  ]);
}
