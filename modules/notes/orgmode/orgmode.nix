{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.notes.orgmode = {
    enable = mkEnableOption "Enable nvim-orgmode: Neovim plugin for Emac Orgmode. Get the best of both worlds";
    orgAgendaFiles = mkOption {
      type = types.str;
      default = "{'~/Dropbox/org/*', '~/my-orgs/**/*'}";
      description = "List of org files to be used as agenda files.";
    };
    orgDefaultNotesFile = mkOption {
      type = types.str;
      default = "~/Dropbox/org/refile.org";
      description = "Default org file to be used for notes.";
    };
  };
}
