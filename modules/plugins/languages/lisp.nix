{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption mkTreesitterGrammarOption;

  cfg = config.vim.languages.lisp;

  defaultFormat = ["sbcl"];
  formats = ["sbcl" "injected"];
in {
  options.vim.languages.lisp = {
    enable = mkEnableOption "Lisp support";

    treesitter = {
      enable =
        mkEnableOption "Lisp treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      commonLispPackage = mkGrammarOption pkgs "commonlisp";
      emacsLispPackage = mkTreesitterGrammarOption pkgs "elisp";
    };

    format = {
      enable =
        mkEnableOption "Lisp formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "Lisp formatter to use";
        type = listOf (enum formats);
        default = defaultFormat;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [
          cfg.treesitter.commonLispPackage
          cfg.treesitter.emacsLispPackage
        ];
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft = {
          commonlisp = cfg.format.type;
          elisp = cfg.format.type;
        };
      };
    })
  ]);
}
