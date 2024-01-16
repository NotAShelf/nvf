{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption types mkOption nvim;
in {
  options.vim.notes.orgmode = {
    enable = mkEnableOption "nvim-orgmode: Neovim plugin for Emac Orgmode. Get the best of both worlds";

    orgAgendaFiles = mkOption {
      type = types.str;
      default = "{'~/Documents/org/*', '~/my-orgs/**/*'}";
      description = "List of org files to be used as agenda files.";
    };

    orgDefaultNotesFile = mkOption {
      type = types.str;
      default = "~/Documents/org/refile.org";
      description = "Default org file to be used for notes.";
    };

    treesitter = {
      enable = mkEnableOption "Orgmode treesitter" // {default = config.vim.languages.enableTreesitter;};

      orgPackage = nvim.types.mkGrammarOption pkgs "org";
    };
  };
}
