{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib) genAttrs;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.nim;

  defaultServers = ["nimlsp"];
  servers = ["nimlsp"];

  defaultFormat = ["nimpretty"];
  formats = {
    nimpretty = {
      command = "${pkgs.nim}/bin/nimpretty";
    };
  };
in {
  options.vim.languages.nim = {
    enable = mkEnableOption "Nim language support";

    treesitter = {
      enable =
        mkEnableOption "Nim treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "nim";
    };

    lsp = {
      enable =
        mkEnableOption "Nim LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Nim LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Nim formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };
      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.nim.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "Nim formatter to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = !pkgs.stdenv.isDarwin;
          message = "Nim language support is only available on Linux";
        }
      ];
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["nim"];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.nim = cfg.format.type;
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
