{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib) genAttrs;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf enumWithRename;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.json;

  defaultServers = ["vscode-json-language-server"];
  servers = ["vscode-json-language-server"];

  defaultFormat = ["jsonfmt"];

  formats = {
    jsonfmt = {
      command = getExe pkgs.jsonfmt;
      args = ["-w" "-"];
    };

    prettier = {
      command = getExe pkgs.prettier;
    };

    prettierd = {
      command = getExe pkgs.prettierd;
    };
  };
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
        type = deprecatedSingleOrListOf "vim.language.json.format.type" (enum (attrNames formats));
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
        setupOpts = {
          formatters_by_ft.json = cfg.format.type;
          formatters_by_ft.json5 = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })
  ]);
}
