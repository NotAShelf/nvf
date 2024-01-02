{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.strings) optionalString;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.trivial) boolToString;
  inherit (lib.nvim.binds) mkBinding;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) listToLuaTable expToLua toLuaObject;
  # TODO: move this to its own module
  inherit (lib) pushDownDefault;

  cfg = config.vim.filetree.nvimTree;
  self = import ./nvimtree.nix {inherit pkgs lib;};
  inherit (self.options.vim.filetree.nvimTree) mappings;
  rawLua = code: {__raw = code;};
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-tree-lua"];

    vim.maps.normal = mkMerge [
      (mkBinding cfg.mappings.toggle ":NvimTreeToggle<cr>" mappings.toggle.description)
      (mkBinding cfg.mappings.refresh ":NvimTreeRefresh<cr>" mappings.refresh.description)
      (mkBinding cfg.mappings.findFile ":NvimTreeFindFile<cr>" mappings.findFile.description)
      (mkBinding cfg.mappings.focus ":NvimTreeFocus<cr>" mappings.focus.description)
    ];

    vim.binds.whichKey.register = pushDownDefault {
      "<leader>t" = "+NvimTree";
    };

    vim.luaConfigRC.nvimtreelua = entryAnywhere ''
      ${
        lib.optionalString cfg.disableNetrw ''
          -- disable netrew completely
          vim.g.loaded_netrw = 1
          vim.g.loaded_netrwPlugin = 1
        ''
      }

      require'nvim-tree'.setup(${toLuaObject cfg.setupOpts})

      ${
        optionalString cfg.openOnSetup ''
          -- autostart behaviour
          -- Open on startup has been deprecated
          -- see https://github.com/nvim-tree/nvim-tree.lua/wiki/Open-At-Startup

          -- use a nix eval to dynamically insert the open on startup function
          local function open_nvim_tree(data)
            local IGNORED_FT = {
              "markdown",
            }

            -- buffer is a real file on the disk
            local real_file = vim.fn.filereadable(data.file) == 1

            -- buffer is a [No Name]
              local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

            -- &ft
            local filetype = vim.bo[data.buf].ft

            -- only files please
            if not real_file and not no_name then
              return
            end

            -- skip ignored filetypes
            if vim.tbl_contains(IGNORED_FT, filetype) then
              return
            end

            -- open the tree but don't focus it
            require("nvim-tree.api").tree.toggle({ focus = false })
          end

          -- function to automatically open the tree on VimEnter
          vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
        ''
      }
    '';

    # backwards compatibility
    vim.filetree.nvimTree.setupOpts = {
      disable_netrw = cfg.disableNetrw;
      hijack_netrw = cfg.hijackNetrw;
      auto_reload_on_write = cfg.autoreloadOnWrite;

      sort = {
        sorter = cfg.sort.sorter;
        folders_first = cfg.sort.foldersFirst;
      };

      hijack_unnamed_buffer_when_opening = cfg.hijackUnnamedBufferWhenOpening;
      hijack_cursor = cfg.hijackCursor;
      root_dirs = cfg.rootDirs;
      prefer_startup_root = cfg.preferStartupRoot;
      sync_root_with_cwd = cfg.syncRootWithCwd;
      reload_on_bufenter = cfg.reloadOnBufEnter;
      respect_buf_cwd = cfg.respectBufCwd;

      hijack_directories = {
        enable = cfg.hijackDirectories.enable;
        auto_open = cfg.hijackDirectories.autoOpen;
      };

      update_focused_file = {
        enable = cfg.updateFocusedFile.enable;
        update_root = cfg.updateFocusedFile.updateRoot;
        ignore_list = cfg.updateFocusedFile.ignoreList;
      };

      system_open = {
        cmd = cfg.systemOpen.cmd;
        args = cfg.systemOpen.args;
      };

      diagnostics = {
        enable = cfg.diagnostics.enable;
        icons = {
          hint = cfg.diagnostics.icons.hint;
          info = cfg.diagnostics.icons.info;
          warning = cfg.diagnostics.icons.warning;
          error = cfg.diagnostics.icons.error;
        };

        severity = {
          min = rawLua "vim.diagnostic.severity.${cfg.diagnostics.severity.min}";
          max = rawLua "vim.diagnostic.severity.${cfg.diagnostics.severity.max}";
        };
      };

      git = {
        enable = cfg.git.enable;
        show_on_dirs = cfg.git.showOnDirs;
        show_on_open_dirs = cfg.git.showOnOpenDirs;
        disable_for_dirs = cfg.git.disableForDirs;
        timeout = cfg.git.timeout;
      };

      modified = {
        enable = cfg.modified.enable;
        show_on_dirs = cfg.modified.showOnDirs;
        show_on_open_dirs = cfg.modified.showOnOpenDirs;
      };

      filesystem_watchers = {
        enable = cfg.filesystemWatchers.enable;
        debounce_delay = cfg.filesystemWatchers.debounceDelay;
        ignore_dirs = cfg.filesystemWatchers.ignoreDirs;
      };

      select_prompts = cfg.selectPrompts;

      view = {
        centralize_selection = cfg.view.centralizeSelection;
        cursorline = cfg.view.cursorline;
        debounce_delay = cfg.view.debounceDelay;
        width = cfg.view.width;
        side = cfg.view.side;
        preserve_window_proportions = cfg.view.preserveWindowProportions;
        number = cfg.view.number;
        relativenumber = cfg.view.relativenumber;
        signcolumn = cfg.view.signcolumn;
        float = {
          enable = cfg.view.float.enable;
          quit_on_focus_loss = cfg.view.float.quitOnFocusLoss;
          open_win_config = {
            relative = cfg.view.float.openWinConfig.relative;
            border = cfg.view.float.openWinConfig.border;
            width = cfg.view.float.openWinConfig.width;
            height = cfg.view.float.openWinConfig.height;
            row = cfg.view.float.openWinConfig.row;
            col = cfg.view.float.openWinConfig.col;
          };
        };
      };

      renderer = {
        add_trailing = cfg.renderer.addTrailing;
        group_empty = cfg.renderer.groupEmpty;
        full_name = cfg.renderer.fullName;
        highlight_git = cfg.renderer.highlightGit;
        highlight_opened_files = cfg.renderer.highlightOpenedFiles;
        highlight_modified = cfg.renderer.highlightModified;
        root_folder_label = cfg.renderer.rootFolderLabel;
        indent_width = cfg.renderer.indentWidth;
        indent_markers = {
          enable = cfg.renderer.indentMarkers.enable;
          inline_arrows = cfg.renderer.indentMarkers.inlineArrows;
          icons = cfg.renderer.indentMarkers.icons;
        };

        special_files = cfg.renderer.specialFiles;
        symlink_destination = cfg.renderer.symlinkDestination;

        icons = {
          webdev_colors = cfg.renderer.icons.webdevColors;
          git_placement = cfg.renderer.icons.gitPlacement;
          modified_placement = cfg.renderer.icons.modifiedPlacement;
          padding = cfg.renderer.icons.padding;
          symlink_arrow = cfg.renderer.icons.symlinkArrow;

          show = {
            git = cfg.renderer.icons.show.git;
            folder = cfg.renderer.icons.show.folder;
            folder_arrow = cfg.renderer.icons.show.folderArrow;
            file = cfg.renderer.icons.show.file;
            modified = cfg.renderer.icons.show.modified;
          };

          glyphs = {
            default = cfg.renderer.icons.glyphs.default;
            symlink = cfg.renderer.icons.glyphs.symlink;
            modified = cfg.renderer.icons.glyphs.modified;

            folder = {
              default = cfg.renderer.icons.glyphs.folder.default;
              open = cfg.renderer.icons.glyphs.folder.open;
              arrow_open = cfg.renderer.icons.glyphs.folder.arrowOpen;
              arrow_closed = cfg.renderer.icons.glyphs.folder.arrowClosed;
              empty = cfg.renderer.icons.glyphs.folder.empty;
              empty_open = cfg.renderer.icons.glyphs.folder.emptyOpen;
              symlink = cfg.renderer.icons.glyphs.folder.symlink;
              symlink_open = cfg.renderer.icons.glyphs.folder.symlinkOpen;
            };

            git = {
              unstaged = cfg.renderer.icons.glyphs.git.unstaged;
              staged = cfg.renderer.icons.glyphs.git.staged;
              unmerged = cfg.renderer.icons.glyphs.git.unmerged;
              renamed = cfg.renderer.icons.glyphs.git.renamed;
              untracked = cfg.renderer.icons.glyphs.git.untracked;
              deleted = cfg.renderer.icons.glyphs.git.deleted;
              ignored = cfg.renderer.icons.glyphs.git.ignored;
            };
          };
        };
      };

      filters = {
        git_ignored = cfg.filters.gitIgnored;
        dotfiles = cfg.filters.dotfiles;
        git_clean = cfg.filters.gitClean;
        no_buffer = cfg.filters.noBuffer;
        exclude = cfg.filters.exclude;
      };

      trash = {
        cmd = cfg.trash.cmd;
      };

      actions = {
        use_system_clipboard = cfg.actions.useSystemClipboard;
        change_dir = {
          enable = cfg.actions.changeDir.enable;
          global = cfg.actions.changeDir.global;
          restrict_above_cwd = cfg.actions.changeDir.restrictAboveCwd;
        };

        expand_all = {
          max_folder_discovery = cfg.actions.expandAll.maxFolderDiscovery;
          exclude = cfg.actions.expandAll.exclude;
        };

        file_popup = {
          open_win_config = cfg.actions.filePopup.openWinConfig;
        };

        open_file = {
          quit_on_open = cfg.actions.openFile.quitOnOpen;
          eject = cfg.actions.openFile.eject;
          resize_window = cfg.actions.openFile.resizeWindow;
          window_picker = {
            enable = cfg.actions.openFile.windowPicker.enable;
            picker = cfg.actions.openFile.windowPicker.picker;
            chars = cfg.actions.openFile.windowPicker.chars;
            exclude = {
              filetype = cfg.actions.openFile.windowPicker.exclude.filetype;
              buftype = cfg.actions.openFile.windowPicker.exclude.buftype;
            };
          };
        };

        remove_file = {
          close_window = cfg.actions.removeFile.closeWindow;
        };
      };

      live_filter = {
        prefix = cfg.liveFilter.prefix;
        always_show_folders = cfg.liveFilter.alwaysShowFolders;
      };

      tab = {
        sync = {
          open = cfg.tab.sync.open;
          close = cfg.tab.sync.close;
          ignore = cfg.tab.sync.ignore;
        };
      };

      notify = {
        threshold = rawLua "vim.log.levels.${cfg.notify.threshold}";
        absolute_path = cfg.notify.absolutePath;
      };

      ui = {
        confirm = {
          remove = cfg.ui.confirm.remove;
          trash = cfg.ui.confirm.trash;
        };
      };
    };
  };
}
