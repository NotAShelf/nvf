{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.notes.orgmode;
in {
  options.vim.notes = {
    orgmode = {
      enable = mkEnableOption "Neovim plugin for Emac Orgmode. Get the best of both worlds.";
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
  };

  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "orgmode-nvim"
    ];

    vim.luaConfigRC.orgmode = nvim.dag.entryAnywhere ''
      -- Load custom treesitter grammar for org filetype
      require('orgmode').setup_ts_grammar()

      -- Treesitter configuration
      require('nvim-treesitter.configs').setup {

        -- If TS highlights are not enabled at all, or disabled via `disable` prop,
        -- highlighting will fallback to default Vim syntax highlighting
        highlight = {
          enable = true,
          -- Required for spellcheck, some LaTex highlights and
          -- code block highlights that do not have ts grammar
        additional_vim_regex_highlighting = {'org'},
        },
        ensure_installed = {'org'}, -- Or run :TSUpdate org
      }

      require('orgmode').setup({
        org_agenda_files = ${cfg.orgAgendaFiles},
        org_default_notes_file = '${cfg.orgDefaultNotesFile}',
      })
    '';
  };
}
