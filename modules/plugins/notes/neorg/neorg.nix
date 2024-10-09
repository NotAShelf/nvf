{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;
in {
  options.vim.notes.neorg = {
    enable = mkEnableOption "neorg: Neovim plugin for Neorg";

    setupOpts = mkPluginSetupOption "Neorg" {};

    treesitter = {
      enable = mkEnableOption "Neorg treesitter" // {default = config.vim.languages.enableTreesitter;};
      norgPackage = mkGrammarOption pkgs "norg";
    };
  };
}
