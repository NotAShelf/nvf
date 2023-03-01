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
  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-tree-lua"];

    # vim.nnoremap = {
    #   "<C-n>" = ":NvimTreeToggle<CR>";
    #   "<leader>tr" = ":NvimTreeRefresh<CR>";
    #   "<leader>tg" = ":NvimTreeFindFile<CR>";
    #   "<leader>tf" = ":NvimTreeFocus<CR>";
    # };

    vim.luaConfigRC.nvimtreelua = nvim.dag.entryAnywhere ''
        vim.api.nvim_set_keymap("n", "<C-n>", ":NvimTreeToggle<cr>" ,{silent = true, noremap = true, nowait = true})
        vim.api.nvim_set_keymap("n", "<leader>tr", ":NvimTreeRefresh<cr>" ,{silent = true, noremap = true})
        vim.api.nvim_set_keymap("n", "<leader>tg", ":NvimTreeFindFile<cr>" ,{silent = true, noremap = true})
        vim.api.nvim_set_keymap("n", "<leader>tf", ":NvimTreeFocus<cr>" ,{silent = true, noremap = true})

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
        -- Open on startup has been deprecated
        -- see https://github.com/nvim-tree/nvim-tree.lua/wiki/Open-At-Startup
        -- use a nix eval to dynamically insert the open on startup function
        ${
        # FIXME: this function is actually obslete due to the existence of the dashboard, I need to find an alternative logic
        if (cfg.openOnSetup)
        then ''
          vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
        ''
        else ""
      }

      require'nvim-tree'.setup({
        sort_by = ${"'" + cfg.sortBy + "'"},
        disable_netrw = ${boolToString cfg.disableNetRW},
        hijack_netrw = ${boolToString cfg.hijackNetRW},
        hijack_cursor = ${boolToString cfg.hijackCursor},
        open_on_tab = ${boolToString cfg.openTreeOnNewTab},
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
          change_dir = {
            global = ${boolToString cfg.actions.changeDir.global},
          },
          open_file = {
            quit_on_open = ${boolToString cfg.actions.openFile.quitOnOpen},
            resize_window = ${boolToString cfg.actions.openFile.resizeWindow},
            window_picker = {
                enable = ${boolToString cfg.actions.openFile.windowPicker.enable},
                chars = ${toString cfg.actions.openFile.windowPicker.chars},
            },
          },
          expand_all = {
            exclude = {
              ${builtins.concatStringsSep "\n" (builtins.map (s: "\"" + s + "\",") cfg.actions.expandAll.exclude)}
            },
          }
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
