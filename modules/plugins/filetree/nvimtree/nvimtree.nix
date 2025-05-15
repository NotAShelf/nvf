{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.types) nullOr str bool int submodule listOf enum oneOf attrs addCheck;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.nvim.config) batchRenameOptions;

  migrationTable = {
    disableNetrw = "disable_netrw";
    hijackNetrw = "hijack_netrw";
    autoreloadOnWrite = "autoreload_on_write";
    updateFocusedFile = "update_focused_file";
    sort = {
      sorter = "sorter";
      foldersFirst = "folders_first";
    };
    hijackCursor = "hijack_cursor";
    hijackUnnamedBufferWhenOpening = "hijack_unnamed_buffer_when_opening";
    rootDirs = "root_dirs";
    preferStartupRoot = "prefer_startup_root";
    syncRootWithCwd = "sync_root_with_cwd";
    reloadOnBufEnter = "reload_on_buf_enter";
    respectBufCwd = "respect_buf_cwd";
    hijackDirectories = "hijack_directories";
    systemOpen = {
      args = "args";
      cmd = "cmd";
    };
    diagnostics = "diagnostics";
    git = {
      enable = "enable";
      showOnDirs = "show_on_dirs";
      showOnOpenDirs = "show_on_open_dirs";
      disableForDirs = "disable_for_dirs";
      timeout = "timeout";
    };
    modified = "modified";
    filesystemWatchers = "filesystem_watchers";
    selectPrompts = "select_prompts";
    view = "view";
    renderer = {
      addTrailing = "add_trailing";
      groupEmpty = "group_empty";
      fullName = "full_name";
      highlightGit = "highlight_git";
      highlightOpenedFiles = "highlight_opened_files";
      highlightModified = "highlight_modified";
      rootFolderLabel = "root_folder_label";
      indentWidth = "indent_width";
      indentMarkers = "indent_markers";
      specialFiles = "special_files";
      symlinkDestination = "symlink_destination";
      icons = "icons";
    };
    filters = "filters";
    trash = "trash";
    actions = "actions";
    liveFilter = "live_filter";
    tab = "tab";
    notify = "notify";
    ui = "ui";
  };

  renamedSetupOpts =
    batchRenameOptions
    ["vim" "filetree" "nvimTree"]
    ["vim" "filetree" "nvimTree" "setupOpts"]
    migrationTable;
in {
  imports = renamedSetupOpts;
  options.vim.filetree.nvimTree = {
    enable = mkEnableOption "filetree via nvim-tree.lua";

    mappings = {
      toggle = mkOption {
        type = nullOr str;
        default = "<leader>t";
        description = "Toggle NvimTree";
      };
      refresh = mkOption {
        type = nullOr str;
        default = "<leader>tr";
        description = "Refresh NvimTree";
      };
      findFile = mkOption {
        type = nullOr str;
        default = "<leader>tg";
        description = "Find file in NvimTree";
      };
      focus = mkOption {
        type = nullOr str;
        default = "<leader>tf";
        description = "Focus NvimTree";
      };
    };

    setupOpts = mkPluginSetupOption "Nvim Tree" {
      hijack_netrw = mkOption {
        default = true;
        description = "Prevents netrw from automatically opening when opening directories";
        type = bool;
      };

      disable_netrw = mkOption {
        default = false;
        description = "Disables netrw and replaces it with tree";
        type = bool;
      };

      auto_reload_on_write = mkOption {
        default = true;
        description = "Auto reload tree on write";
        type = bool;
      };

      update_focused_file = mkOption {
        description = ''
          Update the focused file on `BufEnter`, un-collapses the folders recursively
          until it finds the file.
        '';
        default = {};
        type = submodule {
          options = {
            enable = mkOption {
              type = bool;
              default = false;
              description = "update focused file";
            };

            update_root = mkOption {
              type = bool;
              default = false;
              description = ''
                Update the root directory of the tree if the file is not under current
                root directory. It prefers vim's cwd and `root_dirs`.
                Otherwise it falls back to the folder containing the file.
                Only relevant when `update_focused_file.enable` is `true`
              '';
            };

            ignore_list = mkOption {
              type = listOf str;
              default = [];
              description = ''
                List of buffer names and filetypes that will not update the root dir
                of the tree if the file isn't found under the current root directory.
                Only relevant when `update_focused_file.update_root` and
                `update_focused_file.enable` are `true`.
              '';
            };
          };
        };
      };

      sort = {
        # TODO: function as a possible type
        sorter = mkOption {
          default = "name";
          description = "How files within the same directory are sorted.";
          type = enum ["name" "extension" "modification_time" "case_sensitive" "suffix" "filetype"];
        };

        folders_first = mkOption {
          default = true;
          description = "Sort folders before files. Has no effect when `sort.sorter` is a function.";
          type = bool;
        };
      };

      hijack_cursor = mkOption {
        default = false;
        description = "Hijack the cursor in the tree to put it at the start of the filename";
        type = bool;
      };

      hijack_unnamed_buffer_when_opening = mkOption {
        default = false;
        description = "Open nvimtree in place of the unnamed buffer if it's empty.";
        type = bool;
      };

      root_dirs = mkOption {
        default = [];
        description = ''
          Preferred root directories. Only relevant when `updateFocusedFile.updateRoot` is `true`
        '';
        type = listOf str;
      };

      prefer_startup_root = mkOption {
        default = false;
        description = ''
          Prefer startup root directory when updating root directory of the tree.
          Only relevant when `update_focused_file.update_root` is `true`
        '';
        type = bool;
      };

      sync_root_with_cwd = mkOption {
        type = bool;
        default = false;
        description = ''
          Changes the tree root directory on `DirChanged` and refreshes the tree.
          Only relevant when `updateFocusedFile.updateRoot` is `true`

          (previously `update_cwd`)
        '';
      };

      reload_on_bufenter = mkOption {
        default = false;
        type = bool;
        description = "Automatically reloads the tree on `BufEnter` nvim-tree.";
      };

      respect_buf_cwd = mkOption {
        default = false;
        type = bool;
        description = "Will change cwd of nvim-tree to that of new buffer's when opening nvim-tree.";
      };

      hijack_directories = {
        enable = mkOption {
          type = bool;
          description = ''
            Enable the `hijack_directories` feature. Disable this option if you use vim-dirvish or dirbuf.nvim.
            If `hijack_netrw` and `disable_netrw` are `false`, this feature will be disabled.
          '';
          default = true;
        };

        auto_open = mkOption {
          type = bool;
          description = ''
            Opens the tree if the tree was previously closed.
          '';
          default = false;
        };
      };

      system_open = {
        args = mkOption {
          default = [];
          description = "Optional argument list.";
          type = listOf str;
        };

        cmd = mkOption {
          default =
            if pkgs.stdenv.isDarwin
            then "open"
            else if pkgs.stdenv.isLinux
            then "${pkgs.xdg-utils}/bin/xdg-open"
            else throw "NvimTree: No default system open command for this platform, please set `vim.filetree.nvimTree.systemOpen.cmd`";
          description = "The open command itself";
          type = str;
        };
      };

      diagnostics = mkOption {
        description = ''
          Show LSP and COC diagnostics in the signcolumn
          Note that the modified sign will take precedence over the diagnostics signs.
        '';

        default = {};

        type = submodule {
          options = {
            enable = mkEnableOption "diagnostics view in the signcolumn.";

            debounce_delay = mkOption {
              description = "Idle milliseconds between diagnostic event and update.";
              type = int;
              default = 50;
            };

            show_on_dirs = mkOption {
              description = "Show diagnostic icons on parent directories.";
              default = false;
            };

            show_on_open_dirs = mkOption {
              type = bool;
              default = true;
              description = ''
                Show diagnostics icons on directories that are open.
                Only relevant when `diagnostics.show_on_dirs` is `true`.
              '';
            };

            icons = mkOption {
              description = "Icons for diagnostic severity.";
              default = {};
              type = submodule {
                options = {
                  hint = mkOption {
                    description = "Icon used for `hint` diagnostic.";
                    type = str;
                    default = "";
                  };
                  info = mkOption {
                    description = "Icon used for `info` diagnostic.";
                    type = str;
                    default = "";
                  };
                  warning = mkOption {
                    description = "Icon used for `warning` diagnostic.";
                    type = str;
                    default = "";
                  };
                  error = mkOption {
                    description = "Icon used for `error` diagnostic.";
                    type = str;
                    default = "";
                  };
                };
              };
            };

            severity = mkOption {
              description = "Severity for which the diagnostics will be displayed. See `:help diagnostic-severity`";
              default = {};
              type = submodule {
                options = {
                  min = mkOption {
                    description = "Minimum severity.";
                    type = enum ["HINT" "INFO" "WARNING" "ERROR"];
                    default = "HINT";
                    apply = x: mkLuaInline "vim.diagnostic.severity.${x}";
                  };

                  max = mkOption {
                    description = "Maximum severity.";
                    type = enum ["HINT" "INFO" "WARNING" "ERROR"];
                    default = "ERROR";
                    apply = x: mkLuaInline "vim.diagnostic.severity.${x}";
                  };
                };
              };
            };
          };
        };
      };

      git = {
        enable = mkEnableOption "Git integration with icons and colors.";

        show_on_dirs = mkOption {
          type = bool;
          default = true;
          description = "Show git icons on parent directories.";
        };

        show_on_open_dirs = mkOption {
          type = bool;
          default = true;
          description = "Show git icons on directories that are open.";
        };

        disable_for_dirs = mkOption {
          type = listOf str;
          default = [];
          description = ''
            Disable git integration when git top-level matches these paths.
            May be relative, evaluated via `":p"`
          '';
        };

        timeout = mkOption {
          type = int;
          default = 400;
          description = ''
            Kills the git process after some time if it takes too long.
            Git integration will be disabled after 10 git jobs exceed this timeout.
          '';
        };
      };

      modified = mkOption {
        description = "Indicate which file have unsaved modification.";
        default = {};
        type = submodule {
          options = {
            enable = mkEnableOption "Modified files with icons and color highlight.";

            show_on_dirs = mkOption {
              type = bool;
              description = "Show modified icons on parent directories.";
              default = true;
            };

            show_on_open_dirs = mkOption {
              type = bool;
              description = "Show modified icons on directories that are open.";
              default = true;
            };
          };
        };
      };

      filesystem_watchers = mkOption {
        description = ''
          Will use file system watcher (libuv fs_event) to watch the filesystem for changes.
          Using this will disable BufEnter / BufWritePost events in nvim-tree which
          were used to update the whole tree. With this feature, the tree will be
          updated only for the appropriate folder change, resulting in better
          performance.
        '';
        default = {};
        type = submodule {
          options = {
            enable = mkOption {
              description = "Enable filesystem watchers.";
              type = bool;
              default = true;
            };

            debounce_delay = mkOption {
              description = "Idle milliseconds between filesystem change and action.";
              type = int;
              default = 50;
            };

            ignore_dirs = mkOption {
              type = listOf str;
              default = [];
              description = ''
                List of vim regex for absolute directory paths that will not be watched.
                Backslashes must be escaped e.g. `"my-project/\\.build$"`.
                Useful when path is not in `.gitignore` or git integration is disabled.
              '';
            };
          };
        };
      };

      select_prompts = mkEnableOption ''
        Use `vim.ui.select` style prompts. Necessary when using a UI prompt decorator such as dressing.nvim or telescope-ui-select.nvim
      '';

      view = mkOption {
        description = "Window / buffer setup.";
        default = {};
        type = submodule {
          options = {
            centralize_selection = mkOption {
              description = "If true, reposition the view so that the current node is initially centralized when entering nvim-tree.";
              type = bool;
              default = false;
            };

            cursorline = mkOption {
              description = "Enable cursorline in nvim-tree window.";
              type = bool;
              default = true;
            };

            debounce_delay = mkOption {
              type = int;
              default = 15;
              description = ''
                Idle milliseconds before some reload / refresh operations.
                Increase if you experience performance issues around screen refresh.
              '';
            };

            width = mkOption {
              description = ''
                Width of the window: can be a `%` string, a number representing columns, a
                function or a table.

                A table (an attribute set in our case, see example) indicates that the view should be dynamically sized based on the
                longest line.
              '';
              type = oneOf [int attrs];
              default = 30;
              example = literalExpression ''
                {
                  min = 30;
                  max = -1;
                  padding = 1;
                }
              '';
            };

            side = mkOption {
              description = "Side of the tree.";
              type = enum ["left" "right"];
              default = "left";
            };

            preserve_window_proportions = mkOption {
              description = ''
                Preserves window proportions when opening a file.
                If `false`, the height and width of windows other than nvim-tree will be equalized.
              '';
              type = bool;
              default = false;
            };

            number = mkOption {
              description = "Print the line number in front of each line.";
              type = bool;
              default = false;
            };

            relativenumber = mkOption {
              description = ''
                Show the line number relative to the line with the cursor in front of each line.
                If the option `view.number` is also `true`, the number on the cursor line
                will be the line number instead of `0`.
              '';
              type = bool;
              default = false;
            };

            signcolumn = mkOption {
              description = ''Show diagnostic sign column. Value can be `"yes"`, `"auto"` or`"no"`.'';
              type = enum ["yes" "auto" "no"];
              default = "yes";
            };

            float = mkOption {
              description = "Configuration options for floating window.";

              default = {};
              type = submodule {
                options = {
                  enable = mkOption {
                    description = "If true, tree window will be floating.";
                    type = bool;
                    default = false;
                  };

                  quit_on_focus_loss = mkOption {
                    description = "Close the floating tree window when it loses focus.";
                    type = bool;
                    default = true;
                  };

                  open_win_config = mkOption {
                    description = "Floating window config. See `:h nvim_open_win()` for more details.";
                    type = attrs;
                    default = {
                      relative = "editor";
                      border = "rounded";
                      width = 30;
                      height = 30;
                      row = 1;
                      col = 1;
                    };
                  };
                };
              };
            };
          };
        };
      };

      renderer = {
        add_trailing = mkOption {
          default = false;
          description = "Appends a trailing slash to folder names.";
          type = bool;
        };

        group_empty = mkOption {
          default = false;
          description = "Compact folders that only contain a single folder into one node in the file tree.";
          type = bool;
        };

        full_name = mkOption {
          default = false;
          description = "Display node whose name length is wider than the width of nvim-tree window in floating window.";
          type = bool;
        };

        highlight_git = mkOption {
          type = bool;
          default = false;
          description = ''
            Enable file highlight for git attributes using `NvimTreeGit` highlight groups.
            Requires `nvimTree.git.enable`
            This can be used with or without the icons.
          '';
        };

        highlight_opened_files = mkOption {
          type = enum ["none" "icon" "name" "all"];
          default = "none";
          description = ''
            Highlight icons and/or names for bufloaded() files using the
            `NvimTreeOpenedFile` highlight group.
          '';
        };

        highlight_modified = mkOption {
          type = enum ["none" "icon" "name" "all"];
          default = "none";
          description = ''
            Highlight modified files in the tree using `NvimTreeNormal` highlight group.
            Requires `nvimTree.view.highlightOpenedFiles`
          '';
        };

        root_folder_label = mkOption {
          type = oneOf [str bool];
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

        indent_width = mkOption {
          type = addCheck int (x: x >= 1);
          default = 2;
          description = "Number of spaces for an each tree nesting level. Minimum 1.";
        };

        indent_markers = mkOption {
          description = "Configuration options for tree indent markers.";
          default = {};
          type = submodule {
            options = {
              enable = mkEnableOption "Display indent markers when folders are open.";
              inline_arrows = mkOption {
                type = bool;
                default = true;
                description = "Display folder arrows in the same column as indent marker when using `renderer.icons.show.folder_arrow`";
              };

              icons = mkOption {
                type = attrs;
                description = "Individual elements of the indent markers";
                default = {
                  corner = "└";
                  edge = "│";
                  item = "│";
                  bottom = "─";
                  none = "";
                };
              };
            };
          };
        };

        special_files = mkOption {
          type = listOf str;
          default = ["Cargo.toml" "README.md" "readme.md" "Makefile" "MAKEFILE" "flake.nix"]; # ;)
          description = "A list of filenames that gets highlighted with `NvimTreeSpecialFile";
        };

        symlink_destination = mkOption {
          type = bool;
          default = true;
          description = "Whether to show the destination of the symlink.";
        };

        icons = mkOption {
          description = "Configuration options for icons.";
          default = {};
          type = submodule {
            options = {
              webdev_colors = mkOption {
                type = bool;
                description = " Use the webdev icon colors, otherwise `NvimTreeFileIcon`";
                default = true;
              };

              git_placement = mkOption {
                type = enum ["before" "after" "signcolumn" "right_align"];
                default = "before";
                description = ''
                  Place where the git icons will be rendered.
                  `signcolumn` requires `view.signcolumn` to be enabled.
                '';
              };

              modified_placement = mkOption {
                type = enum ["before" "after" "signcolumn" "right_align"];
                default = "after";
                description = ''
                  Place where the modified icons will be rendered.
                  `signcolumn` requires `view.signcolumn` to be enabled.
                '';
              };

              hidden_placement = mkOption {
                type = enum ["before" "after" "signcolumn" "right_align"];
                default = "after";
                description = ''
                  Place where the hidden icons will be rendered.
                  `signcolumn` requires `view.signcolumn` to be enabled.
                '';
              };

              diagnostics_placement = mkOption {
                type = enum ["before" "after" "signcolumn" "right_align"];
                default = "after";
                description = ''
                  Place where the diagnostics icons will be rendered.
                  `signcolumn` requires `view.signcolumn` to be enabled.
                '';
              };

              bookmarks_placement = mkOption {
                type = enum ["before" "after" "signcolumn" "right_align"];
                default = "after";
                description = ''
                  Place where the bookmark icons will be rendered.
                  `signcolumn` requires `view.signcolumn` to be enabled.
                '';
              };

              padding = mkOption {
                type = str;
                description = "Inserted between icon and filename";
                default = " ";
              };

              symlink_arrow = mkOption {
                type = str;
                description = "Used as a separator between symlinks' source and target.";
                default = " ➛ ";
              };

              show = {
                file = mkOption {
                  type = bool;
                  description = "Show an icon before the file name. `nvim-web-devicons` will be used if available.";
                  default = true;
                };

                folder = mkOption {
                  type = bool;
                  description = "Show an icon before the folder name.";
                  default = true;
                };

                folder_arrow = mkOption {
                  type = bool;
                  default = true;
                  description = ''
                    Show a small arrow before the folder node. Arrow will be a part of the
                    node when using `renderer.indent_markers`.
                  '';
                };

                git = mkOption {
                  type = bool;
                  default = false;
                  description = ''
                    Show a git status icon, see `renderer.icons.gitPlacement`
                    Requires `git.enable` to be true.
                  '';
                };

                modified = mkOption {
                  type = bool;
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
                default = {};
                type = submodule {
                  options = {
                    default = mkOption {
                      type = str;
                      description = "Glyph for files. Will be overridden by `nvim-web-devicons` if available.";
                      default = "";
                    };

                    symlink = mkOption {
                      type = str;
                      description = "Glyph for symlinks.";
                      default = "";
                    };

                    modified = mkOption {
                      type = str;
                      description = "Icon to display for modified files.";
                      default = "";
                    };

                    # TODO: hardcode each attribute
                    folder = mkOption {
                      type = attrs;
                      description = "Glyphs for directories. Recommended to use the defaults unless you know what you are doing.";
                      default = {
                        default = "";
                        open = "";
                        arrow_open = "";
                        arrow_closed = "";
                        empty = "";
                        empty_open = "";
                        symlink = "";
                        symlink_open = "";
                      };
                    };

                    git = mkOption {
                      type = attrs;
                      description = "Glyphs for git status.";
                      default = {
                        unstaged = "✗";
                        staged = "✓";
                        unmerged = "";
                        renamed = "➜";
                        untracked = "★";
                        deleted = "";
                        ignored = "◌";
                      };
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
          git_ignored = false;
          dotfiles = false;
          git_clean = false;
          no_buffer = false;
          exclude = [];
        };
        type = submodule {
          options = {
            git_ignored = mkOption {
              type = bool;
              description = "Ignore files based on `.gitignore`. Requires git.enable` to be `true`";
              default = false;
            };

            dotfiles = mkOption {
              type = bool;
              description = "Do not show dotfiles: files starting with a `.`";
              default = false;
            };

            git_clean = mkOption {
              type = bool;
              default = false;

              description = ''
                Do not show files with no git status. This will show ignored files when
                `nvimTree.filters.gitIgnored` is set, as they are effectively dirty.
              '';
            };

            no_buffer = mkOption {
              type = bool;
              default = false;
              description = "Do not show files that have no `buflisted()` buffer.";
            };

            exclude = mkOption {
              type = listOf str;
              default = [];
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

        type = submodule {
          options = {
            cmd = mkOption {
              type = str;
              description = "The command used to trash items";
            };
          };
        };
      };

      actions = mkOption {
        description = "Configuration for various actions.";
        default = {};
        type = submodule {
          options = {
            use_system_clipboard = mkOption {
              type = bool;
              default = true;
              description = ''
                A boolean value that toggle the use of system clipboard when copy/paste
                function are invoked. When enabled, copied text will be stored in registers
                '+' (system), otherwise, it will be stored in '1' and '"'.
              '';
            };

            # change_dir actions
            change_dir = mkOption {
              description = "vim `change-directory` behaviour";
              default = {};
              type = submodule {
                options = {
                  enable = mkOption {
                    type = bool;
                    default = true;
                    description = "Change the working directory when changing directories in the tree.";
                  };

                  global = mkOption {
                    type = bool;
                    default = false;
                    description = ''
                      Use `:cd` instead of `:lcd` when changing directories.
                      Consider that this might cause issues with the `nvimTree.syncRootWithCwd` option.
                    '';
                  };

                  restrict_above_cwd = mkOption {
                    type = bool;
                    default = false;
                    description = ''
                      Restrict changing to a directory above the global current working directory.
                    '';
                  };
                };
              };
            };

            # expand_all actions
            expand_all = mkOption {
              description = "Configuration for expand_all behaviour.";
              default = {};
              type = submodule {
                options = {
                  max_folder_discovery = mkOption {
                    type = int;
                    default = 300;
                    description = ''
                      Limit the number of folders being explored when expanding every folders.
                      Avoids hanging neovim when running this action on very large folders.
                    '';
                  };
                  exclude = mkOption {
                    type = listOf str;
                    description = "A list of directories that should not be expanded automatically.";
                    default = [".git" "target" "build" "result"];
                  };
                };
              };
            };

            # file_popup actions
            file_popup = mkOption {
              description = "Configuration for file_popup behaviour.";
              default = {};
              type = submodule {
                options = {
                  open_win_config = mkOption {
                    type = attrs;
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
            open_file = mkOption {
              description = "Configuration options for opening a file from nvim-tree.";
              default = {};
              type = submodule {
                options = {
                  quit_on_open = mkOption {
                    type = bool;
                    description = "Closes the explorer when opening a file.";
                    default = false;
                  };

                  eject = mkOption {
                    type = bool;
                    description = "Prevent new opened file from opening in the same window as the tree.";
                    default = false;
                  };

                  resize_window = mkOption {
                    type = bool;
                    default = false;

                    description = "Resizes the tree when opening a file. Previously `view.auto_resize`";
                  };

                  window_picker = mkOption {
                    description = "window_picker";
                    default = {};
                    type = submodule {
                      options = {
                        enable = mkOption {
                          type = bool;
                          description = "Enable the window picker. If this feature is not enabled, files will open in window from which you last opened the tree.";
                          default = false;
                        };

                        picker = mkOption {
                          type = str;
                          default = "default";
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
                          type = str;
                          description = "A string of chars used as identifiers by the window picker.";
                          default = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
                        };

                        exclude = {
                          filetype = mkOption {
                            type = listOf str;
                            description = "A list of filetypes to exclude from the window picker.";
                            default = ["notify" "packer" "qf" "diff" "fugitive" "fugitiveblame"];
                          };

                          buftype = mkOption {
                            type = listOf str;
                            description = "A list of buftypes to exclude from the window picker.";
                            default = ["nofile" "terminal" "help"];
                          };
                        };
                      };
                    };
                  };
                };
              };
            };

            remove_file = {
              close_window = mkOption {
                type = bool;
                default = true;
                description = "Close any window displaying a file when removing the file from the tree";
              };
            };
          };
        };
      };

      live_filter = mkOption {
        description = ''
          Configurations for the live_filtering feature.
          The live filter allows you to filter the tree nodes dynamically, based on
          regex matching (see `vim.regex`).
          This feature is bound to the `f` key by default.
          The filter can be cleared with the `F` key by default.
        '';
        default = {};
        type = submodule {
          options = {
            prefix = mkOption {
              type = str;
              description = "Prefix of the filter displayed in the buffer.";
              default = "[FILTER]: ";
            };

            always_show_folders = mkOption {
              type = bool;
              description = "Whether to filter folders or not.";
              default = true;
            };
          };
        };
      };

      tab = mkOption {
        description = "Configuration for tab behaviour.";
        default = {};
        type = submodule {
          options = {
            sync = mkOption {
              description = "Configuration for syncing nvim-tree across tabs.";
              default = {};
              type = submodule {
                options = {
                  open = mkOption {
                    type = bool;
                    default = false;
                    description = ''
                      Opens the tree automatically when switching tabpage or opening a new
                      tabpage if the tree was previously open.
                    '';
                  };

                  close = mkOption {
                    type = bool;
                    default = false;
                    description = ''
                      Closes the tree across all tabpages when the tree is closed.
                    '';
                  };

                  ignore = mkOption {
                    type = listOf str;
                    default = [];
                    description = ''
                      List of filetypes or buffer names on new tab that will prevent
                      `nvimTree.tab.sync.open` and `nvimTree.tab.sync.close`
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
        default = {};
        type = submodule {
          options = {
            threshold = mkOption {
              type = enum ["ERROR" "WARNING" "INFO" "DEBUG"];
              description = "Specify minimum notification level, uses the values from `vim.log.levels`";
              default = "INFO";
              apply = x: mkLuaInline "vim.log.levels.${x}";
            };

            absolute_path = mkOption {
              type = bool;
              description = "Whether to use absolute paths or item names in fs action notifications.";
              default = true;
            };
          };
        };
      };

      ui = mkOption {
        description = "General UI configuration.";
        default = {};
        type = submodule {
          options = {
            confirm = {
              remove = mkOption {
                type = bool;
                description = "Prompt before removing.";
                default = true;
              };

              trash = mkOption {
                type = bool;
                description = "Prompt before trash.";
                default = true;
              };
            };
          };
        };
      };
    };

    # kept for backwards compatibility
    openOnSetup = mkOption {
      default = true;
      description = "Open when vim is started on a directory";
      type = bool;
    };
  };
}
