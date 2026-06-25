{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) enum listOf;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  defaultServer = ["fsautocomplete"];
  servers = ["fsautocomplete"];

  defaultFormat = ["fantomas"];
  formats = {
    fantomas = {
      command = getExe pkgs.fantomas;
    };
  };

  cfg = config.vim.languages.fsharp;
in {
  options = {
    vim.languages.fsharp = {
      enable = mkEnableOption "F# language support";

      treesitter = {
        enable =
          mkEnableOption "F# treesitter"
          // {
            default = config.vim.languages.enableTreesitter;
            defaultText = literalExpression "config.vim.languages.enableTreesitter";
          };
        package = mkGrammarOption pkgs "fsharp";
      };

      lsp = {
        enable =
          mkEnableOption "F# LSP support"
          // {
            default = config.vim.lsp.enable;
            defaultText = literalExpression "config.vim.lsp.enable";
          };
        servers = mkOption {
          type = listOf (enum servers);
          default = defaultServer;
          description = "F# LSP server to use";
        };
      };
      format = {
        enable = mkEnableOption "F# formatting" // {default = config.vim.languages.enableFormat;};

        type = mkOption {
          type = deprecatedSingleOrListOf "vim.language.fsharp.format.type" (enum (attrNames formats));
          default = defaultFormat;
          description = "F# formatter to use";
        };
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
          filetypes = ["fsharp"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.fsharp = cfg.format.type;
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
