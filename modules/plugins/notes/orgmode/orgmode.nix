{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.types) str listOf;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "notes" "orgmode" "orgAgendaFiles"] ["vim" "notes" "orgmode" "setupOpts" "org_agenda_files"])
    (mkRenamedOptionModule ["vim" "notes" "orgmode" "orgDefaultNotesFile"] ["vim" "notes" "orgmode" "setupOpts" "org_default_notes_file"])
  ];

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
      orgPackage = mkPackageOption pkgs ["org-nvim treesitter"] {
        default = ["tree-sitter-grammars" "tree-sitter-org-nvim"];
      };
    };
  };
}
