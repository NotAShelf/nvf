{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption;

  mkEnableTreesitterOption = lib.nvim.types.mkEnableTreesitterOption config.vim.languages.enableTreesitter;

  cfg = config.vim.languages.tex;
in {
  options.vim.languages.tex.treesitter = {
    latex = {
      enable = mkEnableTreesitterOption "latex";
      package = mkGrammarOption pkgs "latex";
    };
    bibtex = {
      enable = mkEnableTreesitterOption "bibtex";
      package = mkGrammarOption pkgs "bibtex";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.latex.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.latex.package];
    })
    (mkIf cfg.treesitter.bibtex.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.bibtex.package];
    })
  ]);
}
