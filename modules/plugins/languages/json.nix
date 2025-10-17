{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.meta) getExe' getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.json;

  defaultServers = ["jsonls"];
  servers = {
    jsonls = {
      cmd = [(getExe' pkgs.vscode-langservers-extracted "vscode-json-language-server") "--stdio"];
      filetypes = ["json" "jsonc"];
      init_options = {provideFormatter = true;};
      root_markers = [".git"];
    };
  };

  defaultFormat = "jsonfmt";

  formats = {
    jsonfmt = {
      package = pkgs.writeShellApplication {
        name = "jsonfmt";
        runtimeInputs = [pkgs.jsonfmt];
        text = "jsonfmt -w -";
      };
    };
  };
in {
  options.vim.languages.json = {
    enable = mkEnableOption "JSON language support";

    treesitter = {
      enable = mkEnableOption "JSON treesitter" // {default = config.vim.languages.enableTreesitter;};

      package = mkGrammarOption pkgs "json";
    };

    lsp = {
      enable = mkEnableOption "JSON LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "JSON LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "JSON formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "JSON formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "JSON formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (name: {
          inherit name;
          value = servers.${name};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.json = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })
  ]);
}
