{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;
in {
  options.vim.notes.quarto-nvim = {
    enable = mkEnableOption ''
      Quarto-nvim, which provides tools for working on Quarto manuscripts in Neovim.
    '';

    setupOpts = mkPluginSetupOption "quarto-nvim" {};

    treesitter = {
      enable = mkEnableOption "Quarto treesitter" // {default = config.vim.languages.enableTreesitter;};
      quartoPackage = mkGrammarOption pkgs "markdown";
      quartoInlinePackage = mkGrammarOption pkgs "markdown-inline";
    };
  };
}
