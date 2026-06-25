{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib) genAttrs;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf enumWithRename;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.css;

  defaultServer = ["vscode-css-language-server"];
  servers = ["vscode-css-language-server" "emmet-ls"];

  defaultFormat = ["prettier"];
  formats = {
    prettier = {
      command = getExe pkgs.prettier;
    };

    prettierd = {
      command = getExe pkgs.prettierd;
    };

    biome = {
      command = getExe pkgs.biome;
    };
  };
in {
  options.vim.languages.css = {
    enable = mkEnableOption "CSS language support";

    treesitter = {
      enable =
        mkEnableOption "CSS treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      package = mkGrammarOption pkgs "css";
    };

    lsp = {
      enable =
        mkEnableOption "CSS LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.css.lsp.servers"
          servers
          {
            cssls = "vscode-css-language-server";
          });
        default = defaultServer;
        description = "CSS LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "CSS formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "CSS formatter to use";
        type = deprecatedSingleOrListOf "vim.language.css.format.type" (enum (attrNames formats));
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
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = [
            "css"
            # TODO: split in their own modules
            "less"
          ];
        });
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.css = cfg.format.type;
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
