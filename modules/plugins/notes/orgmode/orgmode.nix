{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) str listOf;
  inherit (lib.nvim.types) mkTreesitterGrammarOption mkPluginSetupOption;
in {
  options.vim.notes.orgmode = {
    enable = mkEnableOption "nvim-orgmode: Neovim plugin for Emacs Orgmode. Get the best of both worlds";

    setupOpts = mkPluginSetupOption "Orgmode" {
      org_agenda_files = mkOption {
        type = listOf str;
        default = ["~/Documents/org/*" "~/my-orgs/**/*"];
        description = "List of org files to be used as agenda files.";
      };

      org_default_notes_file = mkOption {
        type = str;
        default = "~/Documents/org/refile.org";
        description = "Default org file to be used for notes.";
      };
    };

    treesitter = {
      enable = mkEnableOption "Orgmode treesitter" // {default = config.vim.languages.enableTreesitter;};
      orgPackage = mkTreesitterGrammarOption pkgs "org";
    };
  };
}
