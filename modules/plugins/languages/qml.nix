{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.lists) isList;
  inherit (lib.strings) optionalString;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool enum package either listOf str nullOr;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.qml;

  packageToCmd = package: defaultCmd:
    if isList cfg.lsp.package
    then expToLua cfg.lsp.package
    else ''{ "${cfg.lsp.package}/bin/${defaultCmd}" }'';

  defaultServer = "qmlls";
  servers = {
    qmlls = {
      package = pkgs.kdePackages.qtdeclarative;
      lspConfig = ''
        lspconfig.qmlls.setup{
          capabilities = capabilities;
          on_attach=default_on_attach;
          cmd = ${packageToCmd cfg.lsp.package "qmlls"};
          ${optionalString (cfg.lsp.opts != null) "init_options = ${cfg.lsp.opts}"}
        }
      '';
    };
  };

  defaultFormat = "qmlformat";
  formats = {
    qmlformat = {
      package = pkgs.kdePackages.qtdeclarative;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.qmlformat.with({
            command = "${cfg.format.package}/bin/qmlformat",
          })
        )
      '';
    };
  };
in {
  options.vim.languages.qml = {
    enable = mkEnableOption "QML language support";

    treesitter = {
      enable = mkEnableOption "QML treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "qmljs";
    };

    lsp = {
      enable = mkEnableOption "QML LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "The QML LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "QML LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server " - data " " ~/.cache/jdtls/workspace "]'';
        type = either package (listOf str);
        default = ["${servers.${cfg.lsp.server}.package}/bin/qmlls" "-E"];
      };

      opts = mkOption {
        description = "Options to pass to QML LSP server";
        type = nullOr str;
        default = null;
      };
    };

    format = {
      enable = mkEnableOption "QML formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "QML formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "QML formatter package";
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
      vim.lsp.lspconfig.enable = true;

      vim.lsp.lspconfig.sources.qml = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.qml = formats.${cfg.format.type}.nullConfig;
    })
  ]);
}
