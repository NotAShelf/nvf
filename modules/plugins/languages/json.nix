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
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
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

  defaultFormat = ["jsonfmt"];

  formats = {
    jsonfmt = {
      command = getExe pkgs.jsonfmt;
      args = ["-w" "-"];
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
        type = deprecatedSingleOrListOf "vim.language.json.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "JSON LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "JSON formatting" // {default = config.vim.languages.enableFormat;};

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
        setupOpts = {
          formatters_by_ft.json = cfg.format.type;
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
