{
  pkgs,
  config,
  lib,
  ...
}:
with builtins;
with lib; let
  cfg = config.vim.dashboard.startify;

  mkVimBool = val:
    if val
    then "1"
    else "0";
in {
  options.vim.dashboard.startify = {
    enable = mkEnableOption "Enable startify";

    bookmarks = mkOption {
      default = [];
      description = ''List of book marks to disaply on start page'';
      type = with types; listOf attrs;
      example = {"c" = "~/.vimrc";};
    };

    changeToDir = mkOption {
      default = true;
      description = "Should vim change to the directory of the file you open";
      type = types.bool;
    };

    changeToVCRoot = mkOption {
      default = false;
      description = "Should vim change to the version control root when opening a file";
      type = types.bool;
    };

    changeDirCmd = mkOption {
      default = "lcd";
      description = "Command to change the current window with. Can be cd, lcd or tcd";
      type = types.enum ["cd" "lcd" "tcd"];
    };

    customHeader = mkOption {
      default = [];
      description = "Text to place in the header";
      type = with types; listOf str;
    };

    customFooter = mkOption {
      default = [];
      description = "Text to place in the footer";
      type = with types; listOf str;
    };

    lists = mkOption {
      default = [
        {
          type = "files";
          header = ["MRU"];
        }
        {
          type = "dir";
          header = ["MRU Current Directory"];
        }
        {
          type = "sessions";
          header = ["Sessions"];
        }
        {
          type = "bookmarks";
          header = ["Bookmarks"];
        }
        {
          type = "commands";
          header = ["Commands"];
        }
      ];
      description = "Specify the lists and in what order they are displayed on startify.";
      type = with types; listOf attrs;
    };

    skipList = mkOption {
      default = [];
      description = "List of regex patterns to exclude from MRU lists";
      type = with types; listOf str;
    };

    updateOldFiles = mkOption {
      default = false;
      description = "Set if you want startify to always update and not just when neovim closes";
      type = types.bool;
    };

    sessionAutoload = mkOption {
      default = false;
      description = "Make startify auto load Session.vim files from the current directory";
      type = types.bool;
    };

    commands = mkOption {
      default = [];
      description = "Commands that are presented to the user on startify page";
      type = with types; listOf (oneOf [str attrs (listOf str)]);
    };

    filesNumber = mkOption {
      default = 10;
      description = "How many files to list";
      type = types.int;
    };

    customIndices = mkOption {
      default = [];
      description = "Specify a list of default charecters to use instead of numbers";
      type = with types; listOf str;
    };

    disableOnStartup = mkOption {
      default = false;
      description = "Prevent startify from opening on startup but can be called with :Startify";
      type = types.bool;
    };

    unsafe = mkOption {
      default = false;
      description = "Turns on unsafe mode for Startify. Stops resolving links, checking files are readable and filtering bookmark list";
      type = types.bool;
    };

    paddingLeft = mkOption {
      default = 3;
      description = "Number of spaces used for left padding.";
      type = types.int;
    };

    useEnv = mkOption {
      default = false;
      description = "Show environment variables in path if name is shorter than value";
      type = types.bool;
    };

    sessionBeforeSave = mkOption {
      default = [];
      description = "Commands to run before saving a session";
      type = with types; listOf str;
    };

    sessionPersistence = mkOption {
      default = false;
      description = "Persist session before leaving vim or switching session";
      type = types.bool;
    };

    sessionDeleteBuffers = mkOption {
      default = true;
      description = "Delete all buffers when loading or closing a session";
      type = types.bool;
    };

    sessionDir = mkOption {
      default = "~/.vim/session";
      description = "Directory to save and load sessions from";
      type = types.str;
    };

    skipListServer = mkOption {
      default = [];
      description = "List of vim servers to not load startify for";
      type = with types; listOf str;
    };

    sessionRemoveLines = mkOption {
      default = [];
      description = "Patterns to remove from session files";
      type = with types; listOf str;
    };

    sessionSavevars = mkOption {
      default = [];
      description = "List of variables to save into a session file.";
      type = with types; listOf str;
    };

    sessionSavecmds = mkOption {
      default = [];
      description = "List of commands to run when loading a session.";
      type = with types; listOf str;
    };

    sessionSort = mkOption {
      default = false;
      description = "Set if you want items sorted by date rather than alphabetically";
      type = types.bool;
    };
  };

  config = mkIf (cfg.enable) {
    vim.startPlugins = with pkgs.neovimPlugins; [vim-startify];

    vim.globals = {
      "startify_custom_header" =
        if cfg.customHeader == []
        then null
        else cfg.customHeader;
      "startify_custom_footer" =
        if cfg.customFooter == []
        then null
        else cfg.customFooter;
      "startify_bookmarks" = cfg.bookmarks;
      "startify_lists" = cfg.lists;
      "startify_change_to_dir" = mkVimBool cfg.changeToDir;
      "startify_change_to_vcs_root" = mkVimBool cfg.changeToVCRoot;
      "startify_change_cmd" = cfg.changeDirCmd;
      "startify_skiplist" = cfg.skipList;
      "startify_update_oldfiles" = mkVimBool cfg.updateOldFiles;
      "startify_session_autoload" = mkVimBool cfg.sessionAutoload;
      "startify_commands" = cfg.commands;
      "startify_files_number" = cfg.filesNumber;
      "startify_custom_indices" = cfg.customIndices;
      "startify_disable_at_vimenter" = mkVimBool cfg.disableOnStartup;
      "startify_enable_unsafe" = mkVimBool cfg.unsafe;
      "startify_padding_left" = cfg.paddingLeft;
      "startify_use_env" = mkVimBool cfg.useEnv;
      "startify_session_before_save" = cfg.sessionBeforeSave;
      "startify_session_persistence" = mkVimBool cfg.sessionPersistence;
      "startify_session_delete_buffers" = mkVimBool cfg.sessionDeleteBuffers;
      "startify_session_dir" = cfg.sessionDir;
      "startify_skiplist_server" = cfg.skipListServer;
      "startify_session_remove_lines" = cfg.sessionRemoveLines;
      "startify_session_savevars" = cfg.sessionSavevars;
      "startify_session_savecmds" = cfg.sessionSavecmds;
      "startify_session_sort" = mkVimBool cfg.sessionSort;
    };
  };
}
