{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.meta) getExe';
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.qml;

  qmlPackage = pkgs.kdePackages.qtdeclarative;

  defaultServers = ["qmlls"];
  servers = {
    qmlls = {
      cmd = [(getExe' qmlPackage "qmlls")];
      filetypes = ["qml" "qmljs"];
      rootmarkers = [".git"];
    };
  };

  defaultFormat = ["qmlformat"];
  formats = {
    qmlformat = {
      command = "${qmlPackage}/bin/qmlformat";
      args = ["-i" "$FILENAME"];
      stdin = false;
    };
  };
in {
  options.vim.languages.qml = {
    enable = mkEnableOption "QML language support";
    treesitter = {
      enable = mkEnableOption "QML treesitter support" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "qmljs";
    };

    lsp = {
      enable = mkEnableOption "QML LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.qml.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "QML LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "QML formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.qml.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "QML formatter to use";
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

    (mkIf (cfg.format.enable && !cfg.lsp.enable) {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.qml = cfg.format.type;
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
