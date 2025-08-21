{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (builtins) attrNames;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.beancount;

  defaultServers = [ "beancount-language-server" ];
  servers = {
    beancount-language-server = {
      rootmarkers = [ ".git" ];
      filetypes = [
        "beancount"
        "bean"
      ];
      cmd = [
        # Wrap the language server to ensure 'bean-check' and 'bean-format'
        # from 'pkgs.beancount' are in the PATH when the server runs.
        (getExe (
          pkgs.symlinkJoin {
            name = "beancount-language-server-wrapped";
            paths = [ pkgs.beancount-language-server ];
            meta.mainProgram = "beancount-language-server";
            buildInputs = [ pkgs.makeBinaryWrapper ];
            postBuild = ''
              wrapProgram $out/bin/beancount-language-server \
                --suffix PATH : ${pkgs.beancount}/bin
                # suffix add to path to allow users beancount in PATH to take precedence.
            '';
          }
        ))
      ];
    };
  };

  defaultFormat = "bean-format";
  formats = {
    bean-format = {
      package = pkgs.beancount;
    };
  };
in
{
  options.vim.languages.beancount = {
    enable = mkEnableOption "Beancount language support";

    treesitter = {
      enable = mkEnableOption "Beancount treesitter support" // {
        default = config.vim.languages.enableTreesitter;
      };
      package = mkGrammarOption pkgs "beancount";
    };

    lsp = {
      enable = mkEnableOption "Beancount LSP support" // {
        default = config.vim.lsp.enable;
      };

      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.languages.beancount.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Beancount LSP server to use.";
      };
    };

    format = {
      enable = mkEnableOption "Beancount formatting" // {
        default = config.vim.languages.enableFormat;
      };

      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Beancount formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Beancount formatter package";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.package ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers = mapListToAttrs (n: {
        name = n;
        value = servers.${n};
      }) cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.beancount = [ cfg.format.type ];
          formatters.${cfg.format.type} = {
            command = getExe' cfg.format.package cfg.format.type;
          };
        };
      };
    })
  ]);
}
