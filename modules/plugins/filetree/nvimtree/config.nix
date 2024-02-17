{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge mkBinding nvim boolToString;

  cfg = config.vim.filetree.nvimTree;
  self = import ./nvimtree.nix {
    inherit pkgs;
    lib = lib;
  };
  mappings = self.options.vim.filetree.nvimTree.mappings;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-tree-lua"];

    vim.maps.normal = mkMerge [
      (mkBinding cfg.mappings.toggle ":NvimTreeToggle<cr>" mappings.toggle.description)
      (mkBinding cfg.mappings.refresh ":NvimTreeRefresh<cr>" mappings.refresh.description)
      (mkBinding cfg.mappings.findFile ":NvimTreeFindFile<cr>" mappings.findFile.description)
      (mkBinding cfg.mappings.focus ":NvimTreeFocus<cr>" mappings.focus.description)
    ];

    vim.luaConfigRC.nvimtreelua = nvim.dag.entryAnywhere ''
      ${
        lib.optionalString (cfg.disableNetrw) ''
          -- disable netrew completely
          vim.g.loaded_netrw = 1
          vim.g.loaded_netrwPlugin = 1
        ''
      }

      require'nvim-tree'.setup({
        disable_netrw = ${boolToString cfg.disableNetrw},
        hijack_netrw = ${boolToString cfg.hijackNetrw},
        auto_reload_on_write = ${boolToString cfg.autoreloadOnWrite},

        sort = {
          sorter = "${cfg.sort.sorter}",
          folders_first = ${boolToString cfg.sort.foldersFirst},
        },

        hijack_unnamed_buffer_when_opening = ${boolToString cfg.hijackUnnamedBufferWhenOpening},
        hijack_cursor = ${boolToString cfg.hijackCursor},
        root_dirs = ${nvim.lua.listToLuaTable cfg.rootDirs},
        prefer_startup_root = ${boolToString cfg.preferStartupRoot},
        sync_root_with_cwd = ${boolToString cfg.syncRootWithCwd},
        reload_on_bufenter = ${boolToString cfg.reloadOnBufEnter},
        respect_buf_cwd = ${boolToString cfg.respectBufCwd},

        hijack_directories = {
          enable = ${boolToString cfg.hijackDirectories.enable},
          auto_open = ${boolToString cfg.hijackDirectories.autoOpen},
        },

        update_focused_file = {
          enable = ${boolToString cfg.updateFocusedFile.enable},
          update_root = ${boolToString cfg.updateFocusedFile.updateRoot},
          ignore_list = ${nvim.lua.listToLuaTable cfg.updateFocusedFile.ignoreList},
        },

        system_open = {
          cmd = "${cfg.systemOpen.cmd}",
          args = ${nvim.lua.listToLuaTable cfg.systemOpen.args},
        },

        diagnostics = {
          enable = ${boolToString cfg.diagnostics.enable},
          icons = {
            hint = "${cfg.diagnostics.icons.hint}",
            info = "${cfg.diagnostics.icons.info}",
            warning = "${cfg.diagnostics.icons.warning}",
            error = "${cfg.diagnostics.icons.error}",
          },

          severity = {
            min = vim.diagnostic.severity.${cfg.diagnostics.severity.min},
            max = vim.diagnostic.severity.${cfg.diagnostics.severity.max},
          },
        },

        git = {
          enable = ${boolToString cfg.git.enable},
          show_on_dirs = ${boolToString cfg.git.showOnDirs},
          show_on_open_dirs = ${boolToString cfg.git.showOnOpenDirs},
          disable_for_dirs = ${nvim.lua.listToLuaTable cfg.git.disableForDirs},
          timeout = ${toString cfg.git.timeout},
        },

        modified = {
          enable = ${boolToString cfg.modified.enable},
          show_on_dirs = ${boolToString cfg.modified.showOnDirs},
          show_on_open_dirs = ${boolToString cfg.modified.showOnOpenDirs},
        },

        filesystem_watchers = {
          enable = ${boolToString cfg.filesystemWatchers.enable},
          debounce_delay = ${toString cfg.filesystemWatchers.debounceDelay},
          ignore_dirs = ${nvim.lua.listToLuaTable cfg.filesystemWatchers.ignoreDirs},
        },

        select_prompts = ${boolToString cfg.selectPrompts},

        view = {
          centralize_selection = ${boolToString cfg.view.centralizeSelection},
          cursorline = ${boolToString cfg.view.cursorline},
          debounce_delay = ${toString cfg.view.debounceDelay},
          width = ${nvim.lua.expToLua cfg.view.width},
          side = "${cfg.view.side}",
          preserve_window_proportions = ${boolToString cfg.view.preserveWindowProportions},
          number = ${boolToString cfg.view.number},
          relativenumber = ${boolToString cfg.view.relativenumber},
          signcolumn = "${cfg.view.signcolumn}",
          float = {
            enable = ${boolToString cfg.view.float.enable},
            quit_on_focus_loss = ${boolToString cfg.view.float.quitOnFocusLoss},
            open_win_config = {
              relative = "${cfg.view.float.openWinConfig.relative}",
              border = "${cfg.view.float.openWinConfig.border}",
              width = ${toString cfg.view.float.openWinConfig.width},
              height = ${toString cfg.view.float.openWinConfig.height},
              row = ${toString cfg.view.float.openWinConfig.row},
              col = ${toString cfg.view.float.openWinConfig.col},
            },
          },
        },

        renderer = {
          add_trailing = ${boolToString cfg.renderer.addTrailing},
          group_empty = ${boolToString cfg.renderer.groupEmpty},
          full_name = ${boolToString cfg.renderer.fullName},
          highlight_git = ${boolToString cfg.renderer.highlightGit},
          highlight_opened_files = ${cfg.renderer.highlightOpenedFiles},
          highlight_modified = ${cfg.renderer.highlightModified},
          root_folder_label = ${nvim.lua.expToLua cfg.renderer.rootFolderLabel},
          indent_width = ${toString cfg.renderer.indentWidth},
          indent_markers = {
            enable = ${boolToString cfg.renderer.indentMarkers.enable},
            inline_arrows = ${boolToString cfg.renderer.indentMarkers.inlineArrows},
            icons = ${nvim.lua.expToLua cfg.renderer.indentMarkers.icons},
          },

          special_files = ${nvim.lua.listToLuaTable cfg.renderer.specialFiles},
          symlink_destination = ${boolToString cfg.renderer.symlinkDestination},

          icons = {
            webdev_colors = ${boolToString cfg.renderer.icons.webdevColors},
            git_placement = "${cfg.renderer.icons.gitPlacement}",
            modified_placement = "${cfg.renderer.icons.modifiedPlacement}",
            padding = "${cfg.renderer.icons.padding}",
            symlink_arrow = "${cfg.renderer.icons.symlinkArrow}",

            show = {
              git = ${boolToString cfg.renderer.icons.show.git},
              folder = ${boolToString cfg.renderer.icons.show.folder},
              folder_arrow = ${boolToString cfg.renderer.icons.show.folderArrow},
              file = ${boolToString cfg.renderer.icons.show.file},
              modified = ${boolToString cfg.renderer.icons.show.modified},
            },

            glyphs = {
              default = "${cfg.renderer.icons.glyphs.default}",
              symlink = "${cfg.renderer.icons.glyphs.symlink}",
              modified = "${cfg.renderer.icons.glyphs.modified}",

              folder = {
                default = "${cfg.renderer.icons.glyphs.folder.default}",
                open = "${cfg.renderer.icons.glyphs.folder.open}",
                arrow_open = "${cfg.renderer.icons.glyphs.folder.arrowOpen}",
                arrow_closed = "${cfg.renderer.icons.glyphs.folder.arrowClosed}",
                empty = "${cfg.renderer.icons.glyphs.folder.empty}",
                empty_open = "${cfg.renderer.icons.glyphs.folder.emptyOpen}",
                symlink = "${cfg.renderer.icons.glyphs.folder.symlink}",
                symlink_open = "${cfg.renderer.icons.glyphs.folder.symlinkOpen}",
              },

              git = {
                unstaged = "${cfg.renderer.icons.glyphs.git.unstaged}",
                staged = "${cfg.renderer.icons.glyphs.git.staged}",
                unmerged = "${cfg.renderer.icons.glyphs.git.unmerged}",
                renamed = "${cfg.renderer.icons.glyphs.git.renamed}",
                untracked = "${cfg.renderer.icons.glyphs.git.untracked}",
                deleted = "${cfg.renderer.icons.glyphs.git.deleted}",
                ignored = "${cfg.renderer.icons.glyphs.git.ignored}",
              },
            },
          },
        },

        filters = {
          git_ignored = ${boolToString cfg.filters.gitIgnored},
          dotfiles = ${boolToString cfg.filters.dotfiles},
          git_clean = ${boolToString cfg.filters.gitClean},
          no_buffer = ${boolToString cfg.filters.noBuffer},
          exclude = ${nvim.lua.listToLuaTable cfg.filters.exclude},
        },

        trash = {
          cmd = "${cfg.trash.cmd}",
        },

        actions = {
          use_system_clipboard = ${boolToString cfg.actions.useSystemClipboard},
          change_dir = {
            enable = ${boolToString cfg.actions.changeDir.enable},
            global = ${boolToString cfg.actions.changeDir.global},
            restrict_above_cwd = ${boolToString cfg.actions.changeDir.restrictAboveCwd},
          },

          expand_all = {
            max_folder_discovery = ${toString cfg.actions.expandAll.maxFolderDiscovery},
            exclude = ${nvim.lua.listToLuaTable cfg.actions.expandAll.exclude},
          },

          file_popup = {
            open_win_config = ${nvim.lua.expToLua cfg.actions.filePopup.openWinConfig},
          },

          open_file = {
            quit_on_open = ${boolToString cfg.actions.openFile.quitOnOpen},
            eject = ${boolToString cfg.actions.openFile.eject},
            resize_window = ${boolToString cfg.actions.openFile.resizeWindow},
            window_picker = {
              enable = ${boolToString cfg.actions.openFile.windowPicker.enable},
              picker = "${cfg.actions.openFile.windowPicker.picker}",
              chars = "${cfg.actions.openFile.windowPicker.chars}",
              exclude = {
                filetype = ${nvim.lua.listToLuaTable cfg.actions.openFile.windowPicker.exclude.filetype},
                buftype = ${nvim.lua.listToLuaTable cfg.actions.openFile.windowPicker.exclude.buftype},
              },
            },
          },

          remove_file = {
            close_window = ${boolToString cfg.actions.removeFile.closeWindow},
          },
        },

        live_filter = {
          prefix = "${cfg.liveFilter.prefix}",
          always_show_folders = ${boolToString cfg.liveFilter.alwaysShowFolders},
        },

        tab = {
          sync = {
            open = ${boolToString cfg.tab.sync.open},
            close = ${boolToString cfg.tab.sync.close},
            ignore = ${nvim.lua.listToLuaTable cfg.tab.sync.ignore},
          },
        },

        notify = {
          threshold = vim.log.levels.${cfg.notify.threshold},
          absolute_path = ${boolToString cfg.notify.absolutePath},
        },

        ui = {
          confirm = {
            remove = ${boolToString cfg.ui.confirm.remove},
            trash = ${boolToString cfg.ui.confirm.trash},
          },
        },
      })

      -- autostart behaviour
      ${
        lib.optionalString (cfg.openOnSetup) ''
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
  };
}
