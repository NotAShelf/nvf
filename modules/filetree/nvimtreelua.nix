{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.filetree.nvimTreeLua;
in {
  options.vim.filetree.nvimTreeLua = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable nvim-tree-lua";
    };

    treeSide = mkOption {
      default = "left";
      description = "Side the tree will appear on left or right";
      type = types.enum ["left" "right"];
    };

    treeWidth = mkOption {
      default = 25;
      description = "Width of the tree in charecters";
      type = types.int;
    };

    hideFiles = mkOption {
      default = [".git" "node_modules" ".cache"];
      description = "Files to hide in the file view by default.";
      type = with types; listOf str;
    };

    hideIgnoredGitFiles = mkOption {
      default = false;
      description = "Hide files ignored by git";
      type = types.bool;
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
      default = false;
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
      default = true;
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

      hideRootFolder = mkOption {
        default = false;
        description = "Hide the root folder";
        type = types.bool;
      };
    };

    git = {
      enable = mkEnableOption "Git integration";
      ignore = mkOption {
        default = true;
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

  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-tree-lua"];

    vim.nnoremap = {
      "<C-n>" = ":NvimTreeToggle<CR>";
      "<leader>tr" = ":NvimTreeRefresh<CR>";
      "<leader>tg" = ":NvimTreeFindFile<CR>";
      "<leader>tf" = ":NvimTreeFocus<CR>";
    };

    vim.luaConfigRC.nvimtreelua = nvim.dag.entryAnywhere ''
      require'nvim-tree'.setup({
        disable_netrw = ${boolToString cfg.disableNetRW},
        hijack_netrw = ${boolToString cfg.hijackNetRW},
        hijack_cursor = ${boolToString cfg.hijackCursor},
        open_on_tab = ${boolToString cfg.openTreeOnNewTab},
        -- FIXME: Open on startup has been deprecated
        -- needs an alternative, see https://github.com/nvim-tree/nvim-tree.lua/wiki/Open-At-Startup3
        -- open_on_setup = ${boolToString cfg.openOnSetup},
        -- open_on_setup_file = ${boolToString cfg.openOnSetup},
        sync_root_with_cwd = ${boolToString cfg.syncRootWithCwd},
        update_focused_file = {
          enable = ${boolToString cfg.updateFocusedFile.enable},
          update_cwd = ${boolToString cfg.updateFocusedFile.update_cwd},
        },

        view  = {
          width = ${toString cfg.view.width},
          side = ${"'" + cfg.view.side + "'"},
          adaptive_size = ${boolToString cfg.view.adaptiveSize},
          hide_root_folder = ${boolToString cfg.view.hideRootFolder},
        },
        git = {
          enable = ${boolToString cfg.git.enable},
          ignore = ${boolToString cfg.git.ignore},
        },

        filesystem_watchers = {
          enable = ${boolToString cfg.filesystemWatchers.enable},
        },

        actions = {
          open_file = {
            quit_on_open = ${boolToString cfg.actions.openFile.quitOnOpen},
            resize_window = ${boolToString cfg.actions.openFile.resizeWindow},
          },
        },

        renderer = {
          highlight_git = ${boolToString cfg.renderer.higlightGit},
          highlight_opened_files = ${"'" + cfg.renderer.highlightOpenedFiles + "'"},
          indent_markers = {
            enable = ${boolToString cfg.renderer.indentMarkers},
          },
          -- TODO: those two
          add_trailing = ${boolToString cfg.renderer.trailingSlash},
          group_empty = ${boolToString cfg.renderer.groupEmptyFolders},
        },

        system_open = {
          cmd = ${"'" + cfg.systemOpenCmd + "'"},
        },
        diagnostics = {
          enable = ${boolToString cfg.lspDiagnostics},
        },
        filters = {
          dotfiles = ${boolToString cfg.hideDotFiles},
          custom = {
            ${builtins.concatStringsSep "\n" (builtins.map (s: "\"" + s + "\",") cfg.hideFiles)}
          },
        },
      })
    '';
  };
}
