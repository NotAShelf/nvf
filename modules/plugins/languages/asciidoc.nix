{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: let
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.attrsets) genAttrs;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkCustomGrammarOption;

  cfg = config.vim.languages.asciidoc;

  defaultFormat = ["injected"];
  formats = ["injected"];
in {
  options.vim.languages.asciidoc = {
    enable = mkEnableOption "AsciiDoc support";

    treesitter = {
      enable =
        mkEnableOption "AsciiDoc treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      blockPackage = mkCustomGrammarOption inputs pkgs "asciidoc";
      inlinePackage = mkCustomGrammarOption inputs pkgs "asciidoc-inline";
    };

    format = {
      enable =
        mkEnableOption "AsciiDoc formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "AsciiDoc formatter to use";
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
          cfg.treesitter.blockPackage
          cfg.treesitter.inlinePackage
        ];
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.asciidoc = cfg.format.type;
      };
    })
  ]);
}
