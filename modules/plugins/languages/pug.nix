{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib.attrsets) attrNames genAttrs;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.pug;

  defaultServers = ["emmet-ls"];
  servers = ["emmet-ls"];

  defaultFormat = ["prettier"];
  formats = {
    prettier = {
      command = getExe pkgs.prettier;
      options.ft_parsers.pug = "pug";
      prepend_args = let
        parser = "${inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.prettier-plugin-pug}/index.js";
      in ["--plugin=${parser}"];
    };
  };
in {
  options.vim.languages.pug = {
    enable = mkEnableOption "Pug language support";

    treesitter = {
      enable =
        mkEnableOption "Pug treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "pug";
    };

    lsp = {
      enable =
        mkEnableOption "Pug LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Pug LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Pug formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
        description = "Pug formatter to use";
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
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {filetypes = ["pug"];});
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.pug = cfg.format.type;
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
