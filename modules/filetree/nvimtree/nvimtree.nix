{
  pkgs,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.filetree.nvimTree = {
    enable = mkEnableOption "filetree via nvim-tree.lua";

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

    disableNetrw = mkOption {
      default = false;
      description = "Disables netrw and replaces it with tree";
      type = types.bool;
    };

    hijackNetrw = mkOption {
      default = true;
      description = "Prevents netrw from automatically opening when opening directories";
      type = types.bool;
    };

    autoreloadOnWrite = mkOption {
      default = true;
      description = "Auto reload tree on write";
      type = types.bool;
    };

    sort = {
      # TODO: function as a possible type
      sorter = mkOption {
        default = "name";
        description = "How files within the same directory are sorted.";
        type = types.enum ["name" "extension" "modification_time" "case_sensitive" "suffix" "filetype"];
      };

      foldersFirst = mkOption {
        default = true;
        description = "Sort folders before files. Has no effect when `sort.sorter` is a function.";
        type = types.bool;
      };
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

    rootDirs = mkOption {
      default = [];
      description = ''
        Preferred root directories. Only relevant when `updateFocusedFile.updateRoot` is `true`
      '';
      type = with types; listOf str;
    };

    preferStartupRoot = mkOption {
      default = false;
      description = ''
        Prefer startup root directory when updating root directory of the tree.
        Only relevant when `update_focused_file.update_root` is `true`
      '';
      type = types.bool;
    };

    syncRootWithCwd = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Changes the tree root directory on `DirChanged` and refreshes the tree.
        Only relevant when `updateFocusedFile.updateRoot` is `true`

        (previously `update_cwd`)
      '';
    };

    reloadOnBufEnter = mkOption {
      default = false;
      type = types.bool;
      description = "Automatically reloads the tree on `BufEnter` nvim-tree.";
    };

    respectBufCwd = mkOption {
      default = false;
      type = types.bool;
      description = "Will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.";
    };

    hijackDirectories = mkOption {
      description = "hijack new directory buffers when they are opened (`:e dir`).";
      type = types.submodule {
        options = {
          enable = mkOption {
            type = types.bool;
            description = ''
              Enable the `hijack_directories` feature. Disable this option if you use vim-dirvish or dirbuf.nvim.
              If `hijack_netrw` and `disable_netrw` are `false`, this feature will be disabled.
            '';
          };

          autoOpen = mkOption {
            type = types.bool;
            description = ''
              Opens the tree if the tree was previously closed.
            '';
          };
        };
      };
      default = {
        enable = true;
        autoOpen = false;
      };
    };

    updateFocusedFile = mkOption {
      description = ''
        Update the focused file on `BufEnter`, un-collapses the folders recursively
        until it finds the file.
      '';
      type = types.submodule {
        options = {
          enable = mkEnableOption "update focused file";

          updateRoot = mkEnableOption ''
            Update the root directory of the tree if the file is not under current
            root directory. It prefers vim's cwd and `root_dirs`.
            Otherwise it falls back to the folder containing the file.
            Only relevant when `update_focused_file.enable` is `true`
          '';

          ignoreList = mkOption {
            description = ''
              List of buffer names and filetypes that will not update the root dir
              of the tree if the file isn't found under the current root directory.
              Only relevant when `update_focused_file.update_root` and
              `update_focused_file.enable` are `true`.
            '';
            type = with types; listOf str;
          };
        };
      };
      default = {
        ignoreList = [];
      };
    };

    systemOpen = {
      args = mkOption {
        default = [];
        description = "Optional argument list.";
        type = with types; listOf str;
      };

      cmd = mkOption {
        default = "${pkgs.xdg-utils}/bin/xdg-open";
        description = "The open command itself";
        type = types.str;
      };
    };

    diagnostics = mkOption {
      description = ''
        Show LSP and COC diagnostics in the signcolumn
        Note that the modified sign will take precedence over the diagnostics signs.
      '';
      default = {
        debounceDelay = 50;
        showOnDirs = false;
        showOnOpenDirs = true;
        icons = {
          hint = "";
          info = "";
          warning = "";
          error = "";
        };

        severity = {
          min = "HINT";
          max = "ERROR";
        };
      };
      type = types.submodule {
        options = {
          enable = mkEnableOption "diagnostics";
          debounceDelay = mkOption {
            description = "Idle milliseconds between diagnostic event and update.";
            type = types.int;
          };

          showOnDirs = mkOption {
            description = "Show diagnostic icons on parent directories.";
            type = types.bool;
          };

          showOnOpenDirs = mkOption {
            description = "Show diagnostics icons on directories that are open.";
            type = types.bool;
          };

          icons = {
            hint = mkOption {
              description = "Icon used for `hint` diagnostic.";
              type = types.str;
            };
            info = mkOption {
              description = "Icon used for `info` diagnostic.";
              type = types.str;
            };
            warning = mkOption {
              description = "Icon used for `warning` diagnostic.";
              type = types.str;
            };
            error = mkOption {
              description = "Icon used for `error` diagnostic.";
              type = types.str;
            };
          };

          severity = mkOption {
            type = types.submodule {
              options = {
                min = mkOption {
                  description = "Minimum severity.";
                  type = types.enum ["HINT" "INFO" "WARNING" "ERROR"];
                };

                max = mkOption {
                  description = "Maximum severity.";
                  type = types.enum ["HINT" "INFO" "WARNING" "ERROR"];
                };
              };
            };
          };
        };
      };
    };

    git = {
      enable = mkEnableOption "Git integration with icons and colors.";

      showOnDirs = mkOption {
        type = types.bool;
        default = true;
        description = "Show git icons on parent directories.";
      };

      showOnOpenDirs = mkOption {
        type = types.bool;
        default = true;
        description = "Show git icons on directories that are open.";
      };

      disableForDirs = mkOption {
        type = with types; listOf str;
        default = [];
        description = ''
          Disable git integration when git top-level matches these paths.
          May be relative, evaluated via `":p"`
        '';
      };

      timeOut = mkOption {
        type = types.int;
        default = 400;
        description = ''
          Kills the git process after some time if it takes too long.
          Git integration will be disabled after 10 git jobs exceed this timeout.
        '';
      };
    };

    modified = mkOption {
      description = "Indicate which file have unsaved modification.";

      default = {
        showOnDirs = true;
        showOnOpenDirs = true;
      };

      type = types.submodule {
        options = {
          enable = mkEnableOption "Modified files with icons and color highlight.";

          showOnDirs = mkOption {
            type = types.bool;
            description = "Show modified icons on parent directories.";
          };

          showOnOpenDirs = mkOption {
            type = types.bool;
            description = "Show modified icons on directories that are open.";
          };
        };
      };
    };

    filesystemWatchers = mkOption {
      description = ''
        Will use file system watcher (libuv fs_event) to watch the filesystem for changes.
        Using this will disable BufEnter / BufWritePost events in nvim-tree which
        were used to update the whole tree. With this feature, the tree will be
        updated only for the appropriate folder change, resulting in better
        performance.
      '';

      default = {
        enable = true;
        debounceDelay = 50;
        ignoreDirs = [];
      };

      type = types.submodule {
        options = {
          enable = mkOption {
            description = "Enable filesystem watchers.";
            type = types.bool;
          };

          debounceDelay = mkOption {
            description = "Idle milliseconds between filesystem change and action.";
            type = types.int;
          };

          ignoreDirs = mkOption {
            type = with types; listOf str;
            description = ''
              List of vim regex for absolute directory paths that will not be watched.
              Backslashes must be escaped e.g. `"my-project/\\.build$"`.
              Useful when path is not in `.gitignore` or git integration is disabled.
            '';
          };
        };
      };
    };

    selectPrompts = mkEnableOption ''
      Use `vim.ui.select` style prompts. Necessary when using a UI prompt decorator such as dressing.nvim or telescope-ui-select.nvim
    '';

    view = mkOption {
      description = "Window / buffer setup.";

      default = {
        centralizeSelection = false;
        cursorline = false;
        debounceDelay = 100;
        side = "left";
        preserveWindowProportions = false;
        number = false;
        relativeNumber = false;
        signcolumn = "yes";
      };

      type = types.submodule {
        options = {
          centralizeSelection = mkOption {
            type = types.bool;
            description = ''
              When entering nvim-tree, reposition the view so that the current node is
              initially centralized
            '';
          };

          cursorline = mkOption {
            default = false;
            description = "Whether to display the cursor line in NvimTree";
            type = types.bool;
          };

          debounceDelay = mkOption {
            type = types.int;
            default = 100;
            description = ''
              Idle milliseconds before some reload / refresh operations.
              Increase if you experience performance issues around screen refresh.
            '';
          };

          width = mkOption {
            description = ''
              Width of the window: can be a `%` string, a number representing columns, a
              function or a table.
              A table indicates that the view should be dynamically sized based on the
              longest line (previously `view.adaptive_size`).
            '';

            default = 30;

            type = with types; oneOf [int attrs];
          };

          side = mkOption {
            type = types.enum ["left" "right"];
            default = "left";
            description = "Side the tree will appear on left or right";
          };

          preserveWindowProportions = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Preserves window proportions when opening a file.
              If `false`, the height and width of windows other than nvim-tree will be equalized.
            '';
          };

          number = mkOption {
            type = types.bool;
            default = false;
            description = "Print the line number in front of each line.";
          };

          relativeNumber = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Show the line number relative to the line with the cursor in front of each line.
              If the option `view.number` is also `true`, the number on the cursor line
              will be the line number instead of `0`.
            '';
          };

          signcolumn = mkOption {
            type = types.enum ["yes" "auto" "no"];
            default = "yes";
            description = "Show diagnostic sign column.";
          };

          float = mkOption {
            description = "Configuration options for floating window";

            default = {
              quitOnFocusLoss = true;
              openWinConfig = {
                relative = "editor";
                border = "single";
                width = 30;
                height = 30;
                row = 1;
                col = 1;
              };
            };

            type = types.submodule {
              options = {
                enable = mkEnableOption "Tree window will be floating.";

                quitOnFocusLoss = mkOption {
                  type = types.bool;
                  description = "Close the floating tree window when it loses focus.";
                };

                openWinConfig = mkOption {
                  type = with types; oneOf [str attrs];
                  description = "Floating window configuration.";
                };
              };
            };
          };
        };
      };
    };

    renderer = {
      addTrailing = mkOption {
        default = false;
        description = "Appends a trailing slash to folder names.";
        type = types.bool;
      };

      groupEmpty = mkOption {
        default = false;
        description = "Compact folders that only contain a single folder into one node in the file tree.";
        type = types.bool;
      };

      fullName = mkOption {
        default = false;
        description = "Display node whose name length is wider than the width of nvim-tree window in floating window.";
        type = types.bool;
      };

      highlightGit = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Enable file highlight for git attributes using `NvimTreeGit` highlight groups.
          Requires `nvim-tree.git.enable`
          This can be used with or without the icons.
        '';
      };

      highlightOpenedFiles = mkOption {
        type = types.enum ["none" "icon" "name" "all"];
        default = "none";
        description = ''
          Highlight icons and/or names for bufloaded() files using the
          `NvimTreeOpenedFile` highlight group.
        '';
      };

      highlightModified = mkOption {
        type = types.enum ["none" "icon" "name" "all"];
        default = "none";
        description = ''
          Highlight modified files in the tree using `NvimTreeNormal` highlight group.
          Requires `nvim-tree.view.highlightOpenedFiles`
        '';
      };

      rootFolderLabel = mkOption {
        type = with types; oneOf [str bool];
        default = false;
        example = ''"":~:s?$?/..?"'';
        description = ''
          In what format to show root folder. See `:help filename-modifiers` for
          available `string` options.
          Set to `false` to hide the root folder.

          Function is passed the absolute path of the root folder and should
          return a string. e.g.
          my_root_folder_label = function(path)
            return ".../" .. vim.fn.fnamemodify(path, ":t")
          end
        '';
      };

      indentWidth = mkOption {
        type = with types; addCheck int (x: x >= 1);
        default = 2;
        description = "Number of spaces for an each tree nesting level. Minimum 1.";
      };

      indentMarkers = mkOption {
        description = "Configuration options for tree indent markers.";
        default = {
          inlineArrows = true;
          icons = {
            corner = "└";
            edge = "│";
            item = "│";
            bottom = "─";
            none = "";
          };
        };

        type = types.submodule {
          options = {
            enable = mkEnableOption "Display indent markers when folders are open.";
            inlineArrows = mkOption {
              type = types.bool;
              default = true;
              description = "Display folder arrows in the same column as indent marker when using `renderer.icons.show.folder_arrow`";
            };

            icons = mkOption {
              type = types.attrs;
              default = {
                corner = "└";
                edge = "│";
                item = "│";
                bottom = "─";
                noner = "";
              };
            };
          };
        };
      };

      specialFiles = mkOption {
        type = with types; listOf str;
        default = ["Cargo.toml" "README.md" "readme.md" "Makefile" "MAKEFILE" "flake.nix"]; # ;)
        description = "A list of filenames that gets highlighted with `NvimTreeSpecialFile";
      };

      symlinkDestination = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to show the destination of the symlink.";
      };

      icons = mkOption {
        description = "Configuration options for icons.";
        default = {
          webdevColors = true;
          gitPlacement = "before";
          modifiedPlacement = "after";
          padding = " ";
          symlinkArrow = " ➛ ";
          show = {
            file = true;
            folder = true;
            folderArrow = true;
            git = false;
            modified = true;
          };
        };

        type = types.submodule {
          options = {
            webdevColors = mkOption {
              type = types.bool;
              description = " Use the webdev icon colors, otherwise `NvimTreeFileIcon`";
            };

            gitPlacement = mkOption {
              type = types.enum ["before" "after" "signcolumn"];
              description = "Place where the git icons will be rendered. `signcolumn` requires `view.signcolumn` to be enabled.";
            };

            modifiedPlacement = mkOption {
              type = types.enum ["before" "after" "signcolumn"];
              description = "Place where the modified icons will be rendered. `signcolumn` requires `view.signcolumn` to be enabled.";
            };

            padding = mkOption {
              type = types.str;
              description = "Inserted between icon and filename";
            };

            symlinkArrow = mkOption {
              type = types.str;
              description = "Used as a separator between symlinks' source and target.";
            };

            show = {
              file = mkOption {
                type = types.bool;
                description = "Show an icon before the file name. `nvim-web-devicons` will be used if available.";
              };

              folder = mkOption {
                type = types.bool;
                description = "Show an icon before the folder name.";
              };

              folderArrow = mkOption {
                type = types.bool;
                description = ''
                  Show a small arrow before the folder node. Arrow will be a part of the
                  node when using `renderer.indent_markers`.
                '';
              };

              git = mkOption {
                type = types.bool;
                description = ''
                  Show a git status icon, see `renderer.icons.gitPlacement`
                  Requires `git.enable` to be true.
                '';
              };

              modified = mkOption {
                type = types.bool;
                default = true;
                description = ''
                  Show a modified icon, see `renderer.icons.modifiedPlacement`
                  Requires `modified.enable` to be true.
                '';
              };
            };
            glyphs = mkOption {
              description = ''
                Configuration options for icon glyphs.
                NOTE: Do not set any glyphs to more than two characters if it's going
                to appear in the signcolumn.
              '';

              default = {
                default = "";
                symlink = "";
                modified = "";
                folder = {
                  default = "";
                  open = "";
                  arrowOpen = "";
                  arrowClosed = "";
                  empty = "";
                  emptyOpen = "";
                  symlink = "";
                  symlinkOpen = "";
                };

                git = {
                  unstaged = "✗";
                  staged = "✓";
                  unmerged = "";
                  renamed = "➜";
                  untracked = "★";
                  deleted = "";
                  ignored = "◌";
                };
              };

              type = types.submodule {
                options = {
                  default = mkOption {
                    type = types.str;
                    description = "Glyph for files. Will be overridden by `nvim-web-devicons` if available.";
                  };

                  symlink = mkOption {
                    type = types.str;
                    description = "Glyph for symlinks.";
                  };

                  modified = mkOption {
                    type = types.str;
                    description = "Icon to display for modified files.";
                  };

                  # TODO: hardcode each attribute
                  folder = mkOption {
                    type = types.attrs;
                    description = "Glyphs for directories. Recommended to use the defaults unless you know what you are doing.";
                  };

                  git = mkOption {
                    type = types.attrs;
                    description = "Glyphs for git status.";
                  };
                };
              };
            };
          };
        };
      };
    };

    filters = mkOption {
      description = "Filtering options.";

      default = {
        gitIgnored = false;
        dotfiles = false;
        gitClean = false;
        noBuffer = false;
        exclude = [];
      };
      type = types.submodule {
        options = {
          gitIgnored = mkOption {
            type = types.bool;
            description = "Ignore files based on `.gitignore`. Requires git.enable` to be `true`";
          };

          dotfiles = mkOption {
            type = types.bool;
            description = "Do not show dotfiles: files starting with a `.`";
          };

          gitClean = mkOption {
            type = types.bool;
            description = ''
              Do not show files with no git status. This will show ignored files when
              `nvim-tree.filters.git_ignored` is set, as they are effectively dirty.
            '';
          };

          noBuffer = mkOption {
            type = types.bool;
            description = "Do not show files that have no `buflisted()` buffer.";
          };

          exclude = mkOption {
            type = types.listOf types.str;
            description = "List of directories or files to exclude from filtering: always show them.";
          };
        };
      };
    };

    trash = mkOption {
      description = "Configuration options for trashing.";
      default = {
        cmd = "${pkgs.glib}/bin/gio trash";
      };

      type = types.submodule {
        options = {
          cmd = mkOption {
            type = types.str;
            description = "The command used to trash items";
          };
        };
      };
    };

    actions = mkOption {
      description = "Configuration for various actions.";
      default = {
        changeDir = {
          enable = true;
          global = false;
          restrictAboveCwd = false;
        };
      };

      type = types.submodule {
        options = {
          useSystemClipboard = mkOption {
            type = types.bool;
            default = true;
            description = ''
              A boolean value that toggle the use of system clipboard when copy/paste
              function are invoked. When enabled, copied text will be stored in registers
              '+' (system), otherwise, it will be stored in '1' and '"'.
            '';
          };

          # change_dir actions
          changeDir = mkOption {
            description = "vim `change-directory` behaviour";
            type = types.submodule {
              options = {
                enable = mkOption {
                  type = types.bool;
                  description = "Change the working directory when changing directories in the tree.";
                };

                global = mkOption {
                  type = types.bool;
                  description = ''
                    Use `:cd` instead of `:lcd` when changing directories.
                    Consider that this might cause issues with the `nvim-tree.syncRootWithCwd` option.
                  '';
                };

                restrictAboveCwd = mkOption {
                  type = types.bool;
                  description = ''
                    Restrict changing to a directory above the global current working directory.
                  '';
                };
              };
            };
          };

          # expand_all actions
          expandAll = mkOption {
            description = "Configuration for expand_all behaviour.";
            default = {
              maxFolderDiscovery = 300;
              exclude = [".git" "target" "build" "result"];
            };
            type = types.submodule {
              options = {
                maxFolderDiscovery = mkOption {
                  type = types.int;
                  description = ''
                    Limit the number of folders being explored when expanding every folders.
                    Avoids hanging neovim when running this action on very large folders.
                  '';
                };
                exclude = mkOption {
                  type = with types; listOf str;
                  description = "A list of directories that should not be expanded automatically.";
                };
              };
            };
          };

          # file_popup actions
          filePopup = mkOption {
            description = "Configuration for file_popup behaviour.";
            default.openWinConfig = {
              col = 1;
              row = 1;
              relative = "cursor";
              border = "rounded";
              style = "minimal";
            };

            type = types.submodule {
              options = {
                openWinConfig = mkOption {
                  type = types.attrs;
                  default = {
                    col = 1;
                    row = 1;
                    relative = "cursor";
                    border = "rounded";
                    style = "minimal";
                  };
                  description = "Floating window config for file_popup. See |nvim_open_win| for more details.";
                };
              };
            };
          };

          # open_file actions
          openFile = mkOption {
            description = "Configuration options for opening a file from nvim-tree.";

            default = {
              quitOnOpen = false;
              eject = false;
              resizeWindow = false;
              windowPicker = {
                enable = false;
                picker = "default";
                chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
                exclude = {
                  filetype = ["notify" "packer" "qf" "diff" "fugitive" "fugitiveblame"];
                  buftype = ["nofile" "terminal" "help"];
                };
              };
            };

            type = types.submodule {
              options = {
                quitOnOpen = mkOption {
                  type = types.bool;
                  description = "Closes the explorer when opening a file.";
                };

                eject = mkOption {
                  type = types.bool;
                  description = "Prevent new opened file from opening in the same window as the tree.";
                };

                resizeWindow = mkOption {
                  type = types.bool;
                  description = "Resizes the tree when opening a file. Previously `view.auto_resize`";
                };

                windowPicker = mkOption {
                  description = "window_picker";
                  type = types.submodule {
                    options = {
                      enable = mkOption {
                        type = types.bool;
                        description = "Enable the window picker. If this feature is not enabled, files will open in window from which you last opened the tree.";
                      };

                      picker = mkOption {
                        type = types.str;
                        description = ''
                          Change the default window picker, can be a string `"default"` or a function.
                          The function should return the window id that will open the node,
                          or `nil` if an invalid window is picked or user cancelled the action.

                          The picker may create a new window.
                        '';

                        example = literalExpression ''
                          -- with s1n7ax/nvim-window-picker plugin
                          require('window-picker').pick_window,
                        '';
                      };

                      chars = mkOption {
                        type = types.str;
                        description = "A string of chars used as identifiers by the window picker.";
                      };

                      exclude = {
                        filetype = mkOption {
                          type = with types; listOf str;
                          description = "A list of filetypes to exclude from the window picker.";
                        };

                        buftype = mkOption {
                          type = with types; listOf str;
                          description = "A list of buftypes to exclude from the window picker.";
                        };
                      };
                    };
                  };
                };
              };
            };
          };

          removeFile = {
            closeWindow = mkOption {
              type = types.bool;
              default = true;
              description = "Close any window displaying a file when removing the file from the tree";
            };
          };
        };
      };
    };

    liveFilter = mkOption {
      description = ''
        Configurations for the live_filtering feature.
        The live filter allows you to filter the tree nodes dynamically, based on
        regex matching (see `vim.regex`).
        This feature is bound to the `f` key by default.
        The filter can be cleared with the `F` key by default.
      '';

      default = {
        prefix = "[FILTER]: ";
        alwaysShowFolders = true;
      };

      type = types.submodule {
        options = {
          prefix = mkOption {
            type = types.str;
            description = "Prefix of the filter displayed in the buffer.";
          };

          alwaysShowFolders = mkOption {
            type = types.bool;
            description = "Whether to filter folders or not.";
          };
        };
      };
    };

    tab = mkOption {
      description = "Configuration for tab behaviour.";

      default = {
        sync = {
          open = false;
          close = false;
          ignore = [];
        };
      };

      type = types.submodule {
        options = {
          sync = mkOption {
            description = "Configuration for syncing nvim-tree across tabs.";

            default = {
              open = false;
              close = false;
              ignore = [];
            };

            type = types.submodule {
              options = {
                open = mkOption {
                  type = types.bool;
                  description = ''
                    Opens the tree automatically when switching tabpage or opening a new
                    tabpage if the tree was previously open.
                  '';
                };

                close = mkOption {
                  type = types.bool;
                  description = ''
                    Closes the tree across all tabpages when the tree is closed.
                  '';
                };

                ignore = mkOption {
                  type = with types; listOf str;
                  description = ''
                    List of filetypes or buffer names on new tab that will prevent
                    `nvim-tree.tab.sync.open` and `nvim-tree.tab.sync.close`
                  '';
                };
              };
            };
          };
        };
      };
    };

    notify = mkOption {
      description = "Configuration for notifications.";

      default = {
        threshold = "INFO";
        absolutePath = true;
      };

      type = types.submodule {
        options = {
          threshold = mkOption {
            type = types.enum ["ERROR" "WARNING" "INFO" "DEBUG"];
            default = "Specify minimum notification level, uses the values from `vim.log.levels`";
          };

          absolutePath = mkOption {
            type = types.bool;
            description = "Whether to use absolute paths or item names in fs action notifications.";
          };
        };
      };
    };
    ui = mkOption {
      description = "General UI configuration.";
      default = {
        confirm = {
          remove = true;
          trash = true;
        };
      };

      type = types.submodule {
        options = {
          confirm = {
            remove = mkOption {
              type = types.bool;
              description = "Prompt before removing.";
            };

            trash = mkOption {
              type = types.bool;
              description = "Prompt before trash.";
            };
          };
        };
      };
    };

    # kept for backwards compatibility
    openOnSetup = mkOption {
      default = true;
      description = "Open when vim is started on a directory";
      type = types.bool;
    };
  };
}
