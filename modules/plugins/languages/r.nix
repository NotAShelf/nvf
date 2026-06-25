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
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf enumWithRename;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.r;

  defaultFormat = ["format_r"];
  formats = {
    styler = {
      command = let
        pkg = pkgs.rWrapper.override {packages = [pkgs.rPackages.styler];};
      in "${pkg}/bin/R";
    };

    format_r = {
      command = let
        pkg = pkgs.rWrapper.override {
          packages = [pkgs.rPackages.formatR];
        };
      in "${pkg}/bin/R";
      stdin = true;
      args = [
        "--slave"
        "--no-restore"
        "--no-save"
        "-s"
        "-e"
        ''formatR::tidy_source(source="stdin")''
      ];
      # TODO: range_args seem to be possible
      # https://github.com/nvimtools/none-ls.nvim/blob/main/lua/null-ls/builtins/formatting/format_r.lua
    };
  };

  defaultServers = ["r-languageserver"];
  servers = ["r-languageserver"];
in {
  options.vim.languages.r = {
    enable = mkEnableOption "R language support";

    treesitter = {
      enable =
        mkEnableOption "R treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "r";
    };

    lsp = {
      enable =
        mkEnableOption "R LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.r.lsp.servers"
          servers
          {
            r_language_server = "r-languageserver";
          });
        default = defaultServers;
        description = "R LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "R formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.r.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "R formatter to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.r = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["r" "rmd" "quarto"];
        });
      };
    })
  ]);
}
