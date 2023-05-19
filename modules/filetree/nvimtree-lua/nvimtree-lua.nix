{
  pkgs,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.filetree.nvimTreeLua = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nvim-tree-lua";
    };

    mappings = {
      toggle = mkOption {
        type = types.nullOr types.str;
        default = "<C-n>";
        description = "Toggle NvimTree";
      };
      refresh = mkOption {
        type = types.nullOr types.str;
        default = "<leader>tr";
        description = "Refresh NvimTree";
      };
      findFile = mkOption {
        type = types.nullOr types.str;
        default = "<leader>tg";
        description = "Find file in NvimTree";
      };
      focus = mkOption {
        type = types.nullOr types.str;
        default = "<leader>tf";
        description = "Focus NvimTree";
      };
    };

    sortBy = mkOption {
      default = "name";
      description = "Sort by name or extension";
      type = types.enum ["name" "extension" "modification_time" "case_sensitive"];
    };

    hideFiles = mkOption {
      default = ["node_modules" ".cache"];
      description = "Files to hide in the file view by default.";
      type = with types; listOf str;
    };

    openOnSetup = mkOption {
      default = true;
      description = "Open when vim is started on a directory";
      type = types.bool;
    };

    closeOnLastWindow = mkOption {
      default = true;
      description = "Close when tree is last window open";
      type = types.bool;
    };

    ignoreFileTypes = mkOption {
      default = [];
      description = "Ignore file types";
      type = with types; listOf str;
    };

    followBufferFile = mkOption {
      default = true;
      description = "Follow file that is in current buffer on tree";
      type = types.bool;
    };

    indentMarkers = mkOption {
      default = true;
      description = "Show indent markers";
      type = types.bool;
    };

    hideDotFiles = mkOption {
      default = false;
      description = "Hide dotfiles";
      type = types.bool;
    };

    openTreeOnNewTab = mkOption {
      default = true;
      description = "Opens the tree view when opening a new tab";
      type = types.bool;
    };

    disableNetRW = mkOption {
      default = false;
      description = "Disables netrw and replaces it with tree";
      type = types.bool;
    };

    hijackNetRW = mkOption {
      default = true;
      description = "Prevents netrw from automatically opening when opening directories";
      type = types.bool;
    };

    trailingSlash = mkOption {
      default = true;
      description = "Add a trailing slash to all folders";
      type = types.bool;
    };

    groupEmptyFolders = mkOption {
      default = true;
      description = "Compact empty folders trees into a single item";
      type = types.bool;
    };

    lspDiagnostics = mkOption {
      default = true;
      description = "Shows lsp diagnostics in the tree";
      type = types.bool;
    };

    systemOpenCmd = mkOption {
      default = "${pkgs.xdg-utils}/bin/xdg-open";
      description = "The command used to open a file with the associated default program";
      type = types.str;
    };

    updateCwd = mkOption {
      # updateCwd has been deprecated in favor of syncRootWithCwd
      # this option is kept for backwards compatibility
      default = true;
      description = "Updates the tree when changing nvim's directory (DirChanged event).";
      type = types.bool;
    };

    ignore_ft_on_setup = mkOption {
      default = [];
      description = "Ignore file types on setup";
      type = with types; listOf str;
    };

    hijackCursor = mkOption {
      default = false;
      description = "Hijack the cursor in the tree to put it at the start of the filename";
      type = types.bool;
    };

    hijackUnnamedBufferWhenOpening = mkOption {
      default = false;
      description = "Open nvimtree in place of the unnamed buffer if it's empty.";
      type = types.bool;
    };

    syncRootWithCwd = mkOption {
      default = true;
      description = "Changes the tree root directory on `DirChanged` and refreshes the tree";
      type = types.bool;
    };

    updateFocusedFile = mkOption {
      default = {
        enable = true;
        update_cwd = true;
      };
      description = "Updates the tree when changing nvim's directory (DirChanged event).";
      type = with types; attrsOf (either bool (attrsOf bool));
    };

    view = {
      adaptiveSize = mkOption {
        default = true;
        description = "Resize the tree when the window is resized";
        type = types.bool;
      };
      side = mkOption {
        default = "left";
        description = "Side the tree will appear on left or right";
        type = types.enum ["left" "right"];
      };
      width = mkOption {
        default = 35;
        description = "Width of the tree in charecters";
        type = types.int;
      };
      cursorline = mkOption {
        default = false;
        description = "Whether to display the cursor line in NvimTree";
        type = types.bool;
      };
    };

    git = {
      enable = mkEnableOption "Git integration";
      ignore = mkOption {
        default = false;
        description = "Ignore files in git";
        type = types.bool;
      };
    };

    filesystemWatchers = {
      enable = mkOption {
        default = true;
        description = "Enable filesystem watchers";
        type = types.bool;
      };
    };

    actions = {
      changeDir = {
        global = mkOption {
          default = true;
          description = "Change directory when changing nvim's directory (DirChanged event).";
          type = types.bool;
        };
      };
      openFile = {
        resizeWindow = mkOption {
          default = true;
          description = "Resize the tree when opening a file";
          type = types.bool;
        };
        quitOnOpen = mkOption {
          default = false;
          description = "Quit the tree when opening a file";
          type = types.bool;
        };
        windowPicker = {
          enable = mkEnableOption "Window picker";

          chars = mkOption {
            default = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
            description = "A string of chars used as identifiers by the window picker";
            type = types.str;
          };

          /*
          # FIXME: Can't get this to place the list items in a lua table
          exclude = {
            fileType = mkOption {
              default = ["notify" "packer" "qf" "diff" "fugitive" "fugitiveblame"];
              description = "File types to exclude from window picker";
              type = with types; listOf str;
            };
            buftype = mkOption {
              default = ["nofile" "terminal" "help"];
              description = "Buffer types to exclude from window picker";
              type = with types; listOf str;
            };
          };
          */
        };
      };
      expandAll = {
        exclude = mkOption {
          default = [];
          description = "Exclude files from expand all";
          type = with types; listOf str;
        };
      };
    };

    renderer = {
      higlightGit = mkOption {
        default = false;
        description = "Highlight git related files";
        type = types.bool;
      };

      highlightOpenedFiles = mkOption {
        default = "none";
        description = "Highlight opened files";
        type = types.enum ["none" "icon" "name" "all"];
      };

      indentMarkers = mkOption {
        default = false;
        description = "Show indent markers";
        type = types.bool;
      };

      showHiddenFiles = mkOption {
        default = true;
        description = "Show hidden files";
        type = types.bool;
      };

      trailingSlash = mkOption {
        default = false;
        description = "Add a trailing slash to all folders";
        type = types.bool;
      };

      showParentFolder = mkOption {
        default = false;
        description = "Show parent folder";
        type = types.bool;
      };

      groupEmptyFolders = mkOption {
        default = false;
        description = "Compact empty folders trees into a single item";
        type = types.bool;
      };

      rootFolderLabel = mkOption {
        default = null;
        description = "Root folder label. Set null to disable";
        type = with types; nullOr str;
      };

      icons = {
        show = {
          file = mkOption {
            default = true;
            description = "Show file icons";
            type = types.bool;
          };
          folder = mkOption {
            default = true;
            description = "Show folder icons";
            type = types.bool;
          };
          folderArrow = mkOption {
            default = true;
            description = "Show folder arrow icons";
            type = types.bool;
          };
          git = mkOption {
            default = false;
            description = "Show git icons";
            type = types.bool;
          };
        };
        glyphs = {
          default = mkOption {
            default = "";
            description = "Default icon";
            type = types.str;
          };
          symlink = mkOption {
            default = "";
            description = "Symlink icon";
            type = types.str;
          };

          folder = {
            default = mkOption {
              default = "";
              description = "Default folder icon";
              type = types.str;
            };
            open = mkOption {
              default = "";
              description = "Open folder icon";
              type = types.str;
            };
            empty = mkOption {
              default = "";
              description = "Empty folder icon";
              type = types.str;
            };
            emptyOpen = mkOption {
              default = "";
              description = "Empty open folder icon";
              type = types.str;
            };
            symlink = mkOption {
              default = "";
              description = "Symlink folder icon";
              type = types.str;
            };
            symlinkOpen = mkOption {
              default = "";
              description = "Symlink open folder icon";
              type = types.str;
            };
            arrowOpen = mkOption {
              default = "";
              description = "Open folder arrow icon";
              type = types.str;
            };
            arrowClosed = mkOption {
              default = "";
              description = "Closed folder arrow icon";
              type = types.str;
            };
          };

          git = {
            unstaged = mkOption {
              default = "✗";
              description = "Unstaged git icon";
              type = types.str;
            };
            staged = mkOption {
              default = "✓";
              description = "Staged git icon";
              type = types.str;
            };
            unmerged = mkOption {
              default = "";
              description = "Unmerged git icon";
              type = types.str;
            };
            renamed = mkOption {
              default = "➜";
              description = "Renamed git icon";
              type = types.str;
            };
            untracked = mkOption {
              default = "★";
              description = "Untracked git icon";
              type = types.str;
            };
            deleted = mkOption {
              default = "";
              description = "Deleted git icon";
              type = types.str;
            };
            ignored = mkOption {
              default = "◌";
              description = "Ignored git icon";
              type = types.str;
            };
          };
        };
      };
    };
  };
}
