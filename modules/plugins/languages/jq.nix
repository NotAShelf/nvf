{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.jq;

  defaultServers = ["jq-lsp"];
  servers = {
    jq-lsp = {
      enable = true;
      cmd = [(getExe pkgs.jq-lsp)];
      filetypes = ["jq"];
      root_markers = [".git"];
    };
  };

  defaultFormat = ["jqfmt"];
  formats = {
    jqfmt = {
      command = getExe pkgs.jqfmt;
      args = [
        "-ob"
        "-ar"
        "-op=pipe"
      ];
    };
  };
in {
  options.vim.languages.jq = {
    enable = mkEnableOption "JQ support";

    treesitter = {
      enable =
        mkEnableOption "JQ treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "jq";
    };

    lsp = {
      enable =
        mkEnableOption "JQ LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "JQ LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "JQ formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "JQ formatter to use";
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
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
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.jq = cfg.format.type;
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
