{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.just;

  defaultServers = ["just-lsp"];
  servers = {
    just-lsp = {
      enable = true;
      cmd = [(getExe pkgs.just-lsp)];
      filetypes = ["just"];
      root_markers = [".git" "justfile"];
    };
  };

  defaultFormat = ["just"];

  formats = {
    just = {
      command = getExe pkgs.just;
      args = [
        "--unstable"
        "--fmt"
      ];
    };
  };
in {
  options.vim.languages.just = {
    enable = mkEnableOption "Just support";

    treesitter = {
      enable =
        mkEnableOption "Just treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "just";
    };

    lsp = {
      enable =
        mkEnableOption "Just LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Just LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Justfile formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Justfile formatter to use";
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
          formatters_by_ft.just = cfg.format.type;
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
