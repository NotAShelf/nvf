{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.attrsets) genAttrs;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.json5;

  defaultFormat = ["prettier"];
  formats = ["prettier" "injected"];
in {
  options.vim.languages.json5 = {
    enable = mkEnableOption "JSON5 language support";

    treesitter = {
      enable =
        mkEnableOption "JSON5 treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      package = mkGrammarOption pkgs "json5";
    };

    format = {
      enable =
        mkEnableOption "JSON5 formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "JSON5 formatter to use";
        type = listOf (enum formats);
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

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft = {json5 = cfg.format.type;};
      };
    })
  ]);
}
