{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.tex;

  mkEnableTreesitterOption = description: mkEnableOption description // {default = config.vim.languages.enableTreesitter;};
in {
  options.vim.languages.tex.treesitter = {
    latex = {
      enable = mkEnableTreesitterOption "Whether to enable Latex treesitter";
      package = mkGrammarOption pkgs "latex";
    };
    bibtex = {
      enable = mkEnableTreesitterOption "Whether to enable Bibtex treesitter";
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
