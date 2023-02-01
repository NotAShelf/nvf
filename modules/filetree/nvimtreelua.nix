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
      default = 30;
      description = "Width of the tree in charecters";
      type = types.int;
    };

    adaptiveSize = mkOption {
      default = true;
      description = "Whether to enable adaptiveSize";
      type = types.bool;
    };

    hideFiles = mkOption {
      default = [".git" "node_modules" ".cache" ".idea"];
      description = "Files to hide in the file view by default.";
      type = with types; listOf str;
    };

    hideIgnoredGitFiles = mkOption {
      default = false;
      description = "Hide files ignored by git";
      type = types.bool;
    };

    highlightGit = {
      mkEnableOption = "Enable git highlights";
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

    closeOnFileOpen = mkOption {
      default = false;
      description = "Closes the tree when a file is opened.";
      type = types.bool;
    };

    resizeOnFileOpen = mkOption {
      default = false;
      description = "Resizes the tree when opening a file.";
      type = types.bool;
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

    hijackCursor = mkOption {
      default = true;
      description = "Keeps the cursor on the first letter of the filename when moving in the tree";
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

    syncRootWithCwd = mkOption {
      default = true;
      description = "Changes the tree root directory on `DirChanged` and refreshes the tree";
      type = types.bool;
    };

    updateFocusedFile = {
      mkEnableOption = "Enable updateFocusedFile";
      update_cwd = mkOption {
        default = false;
        description = "";
        type = types.bool;
      };
    };

    fileSystemWatchers = {
      mkEnableOption = "Enable fileSystemWatchers";
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
        open_on_setup = ${boolToString cfg.openOnSetup},
        open_on_setup_file = ${boolToString cfg.openOnSetup},
        system_open = {
          cmd = ${"'" + cfg.systemOpenCmd + "'"},
        },
        diagnostics = {
          enable = ${boolToString cfg.lspDiagnostics},
        },
        view  = {
          adaptive_size = ${boolToString cfg.adaptiveSize},
          width = ${toString cfg.treeWidth},
          side = ${"'" + cfg.treeSide + "'"},
        },
        renderer = {
          highlight_git = ${boolToString cfg.highlightGit},

          indent_markers = {
            enable = ${boolToString cfg.indentMarkers},
          },
          add_trailing = ${boolToString cfg.trailingSlash},
          group_empty = ${boolToString cfg.groupEmptyFolders},
        },
        actions = {
          open_file = {
            quit_on_open = ${boolToString cfg.closeOnFileOpen},
            resize_window = ${boolToString cfg.resizeOnFileOpen},
          },
        },
        git = {
          enable = true,
          ignore = ${boolToString cfg.hideIgnoredGitFiles},
        },
        filters = {
          dotfiles = ${boolToString cfg.hideDotFiles},
          custom = {
            ${builtins.concatStringsSep "\n" (builtins.map (s: "\"" + s + "\",") cfg.hideFiles)}
          },
        },
        filesystem_watchers = {
          enable = ${boolToString cfg.fileSystemWatchers},
        }
      })
    '';
  };
}
