{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.strings) optionalString;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkLznBinding;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) pushDownDefault;

  cfg = config.vim.filetree.nvimTree;
  self = import ./nvimtree.nix {inherit pkgs lib;};
  inherit (self.options.vim.filetree.nvimTree) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      binds.whichKey.register = pushDownDefault {
        "<leader>t" = "+NvimTree";
      };

      lazy.plugins.nvim-tree-lua = {
        package = "nvim-tree-lua";
        setupModule = "nvim-tree";
        inherit (cfg) setupOpts;

        cmd = ["NvimTreeClipboard" "NvimTreeClose" "NvimTreeCollapse" "NvimTreeCollapseKeepBuffers" "NvimTreeFindFile" "NvimTreeFindFileToggle" "NvimTreeFocus" "NvimTreeHiTest" "NvimTreeOpen" "NvimTreeRefresh" "NvimTreeResize" "NvimTreeToggle"];
        keys = [
          (mkLznBinding ["n"] cfg.mappings.toggle ":NvimTreeToggle<cr>" mappings.toggle.description)
          (mkLznBinding ["n"] cfg.mappings.refresh ":NvimTreeRefresh<cr>" mappings.refresh.description)
          (mkLznBinding ["n"] cfg.mappings.findFile ":NvimTreeFindFile<cr>" mappings.findFile.description)
          (mkLznBinding ["n"] cfg.mappings.focus ":NvimTreeFocus<cr>" mappings.focus.description)
        ];
      };

      pluginRC.nvim-tree = entryAnywhere ''
        ${
          optionalString cfg.setupOpts.disable_netrw ''
            -- disable netrew completely
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
          ''
        }

        ${optionalString (config.vim.lazy.enable && cfg.setupOpts.hijack_netrw && !cfg.openOnSetup) ''
          vim.api.nvim_create_autocmd("BufEnter", {
            group = vim.api.nvim_create_augroup("load_nvim_tree", {}),
            desc = "Loads nvim-tree when openning a directory",
            callback = function(args)
              local stats = vim.uv.fs_stat(args.file)

              if not stats or stats.type ~= "directory" then
                return
              end

              require("lz.n").trigger_load("nvim-tree-lua")

              return true
            end,
          })
        ''}

        ${
          optionalString cfg.openOnSetup ''
            ${optionalString config.vim.lazy.enable ''require('lz.n').trigger_load("nvim-tree-lua")''}
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
    };
  };
}
