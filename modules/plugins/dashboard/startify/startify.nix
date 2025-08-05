{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) listOf attrs bool enum str oneOf int;
in {
  options.vim.dashboard.startify = {
    enable = mkEnableOption "fancy start screen for Vim [vim-startify]";

    bookmarks = mkOption {
      type = listOf attrs;
      default = [];
      example = {"c" = "~/.vimrc";};
      description = "List of book marks to display on start page";
    };

    changeToDir = mkOption {
      type = bool;
      default = true;
      description = "Whether Vim should change to the directory of the file you open";
    };

    changeToVCRoot = mkOption {
      type = bool;
      default = false;
      description = "Whether Vim should change to the version control root when opening a file";
    };

    changeDirCmd = mkOption {
      type = enum ["cd" "lcd" "tcd"];
      default = "lcd";
      description = "Command to change the current window with.";
    };

    customHeader = mkOption {
      type = listOf str;
      default = [];
      description = "Text to place in the header";
    };

    customFooter = mkOption {
      type = listOf str;
      default = [];
      description = "Text to place in the footer";
    };

    lists = mkOption {
      type = listOf attrs;
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
    };

    skipList = mkOption {
      type = listOf str;
      default = [];
      description = "List of regex patterns to exclude from MRU lists";
    };

    updateOldFiles = mkOption {
      type = bool;

      default = false;
      description = "Set if you want startify to always update and not just when neovim closes";
    };

    sessionAutoload = mkOption {
      type = bool;

      default = false;
      description = "Make vim-startify auto load Session.vim files from the current directory";
    };

    commands = mkOption {
      type = listOf (oneOf [str attrs (listOf str)]);
      default = [];
      description = "Commands that are presented to the user on startify page";
    };

    filesNumber = mkOption {
      type = int;
      default = 10;
      description = "How many files to list";
    };

    customIndices = mkOption {
      type = listOf str;
      default = [];
      description = "Specify a list of default characters to use instead of numbers";
    };

    disableOnStartup = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether vim-startify should be disabled on startup.

        This will prevent startify from opening on startup, but it can still
        be called with `:Startify`
      '';
    };

    unsafe = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether to turn on unsafe mode for Startify.

        While enabld, vim-startify will stops resolving links, checking files
        are readable and filtering bookmark list
      '';
    };

    paddingLeft = mkOption {
      type = int;
      default = 3;
      description = "Number of spaces used for left padding.";
    };

    useEnv = mkOption {
      type = bool;
      default = false;
      description = "Show environment variables in path if name is shorter than value";
    };

    sessionBeforeSave = mkOption {
      type = listOf str;
      default = [];
      description = "Commands to run before saving a session";
    };

    sessionPersistence = mkOption {
      type = bool;
      default = false;
      description = "Persist session before leaving vim or switching session";
    };

    sessionDeleteBuffers = mkOption {
      type = bool;
      default = true;
      description = "Delete all buffers when loading or closing a session";
    };

    sessionDir = mkOption {
      type = str;
      default = "~/.vim/session";
      description = "Directory to save and load sessions from";
    };

    skipListServer = mkOption {
      type = listOf str;
      default = [];
      description = "List of vim servers to not load startify for";
    };

    sessionRemoveLines = mkOption {
      type = listOf str;
      default = [];
      description = "Patterns to remove from session files";
    };

    sessionSavevars = mkOption {
      type = listOf str;
      default = [];
      description = "List of variables to save into a session file.";
    };

    sessionSavecmds = mkOption {
      type = listOf str;
      default = [];
      description = "List of commands to run when loading a session.";
    };

    sessionSort = mkOption {
      type = bool;
      default = false;
      example = true;
      description = ''
        While true, sessions will be sorted by date rather than alphabetically.

      '';
    };
  };
}
