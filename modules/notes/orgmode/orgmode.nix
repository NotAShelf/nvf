{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) str;
  inherit (lib.nvim.types) mkGrammarOption;
in {
  options.vim.notes.orgmode = {
    enable = mkEnableOption "nvim-orgmode: Neovim plugin for Emac Orgmode. Get the best of both worlds";

    orgAgendaFiles = mkOption {
      type = str;
      default = "{'~/Documents/org/*', '~/my-orgs/**/*'}";
      description = "List of org files to be used as agenda files.";
    };

    orgDefaultNotesFile = mkOption {
      type = str;
      default = "~/Documents/org/refile.org";
      description = "Default org file to be used for notes.";
    };

    treesitter = {
      enable = mkEnableOption "Orgmode treesitter" // {default = config.vim.languages.enableTreesitter;};
      orgPackage = mkGrammarOption pkgs "org";
    };
  };
}
