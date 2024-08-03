{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) filter;
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
    vim.binds.whichKey.register = pushDownDefault {
      "<leader>t" = "+NvimTree";
    };

    vim.lazy = {
      plugins = {
        nvim-tree-lua = {
          package = "nvim-tree-lua";
          setupModule = "nvim-tree";
          inherit (cfg) setupOpts;
          cmd = ["NvimTreeClipboard" "NvimTreeClose" "NvimTreeCollapse" "NvimTreeCollapseKeepBuffers" "NvimTreeFindFile" "NvimTreeFindFileToggle" "NvimTreeFocus" "NvimTreeHiTest" "NvimTreeOpen" "NvimTreeRefresh" "NvimTreeResize" "NvimTreeToggle"];

          keys = filter ({lhs, ...}: lhs != null) [
            (mkLznBinding ["n"] cfg.mappings.toggle ":NvimTreeToggle<cr>" mappings.toggle.description)
            (mkLznBinding ["n"] cfg.mappings.refresh ":NvimTreeRefresh<cr>" mappings.refresh.description)
            (mkLznBinding ["n"] cfg.mappings.findFile ":NvimTreeFindFile<cr>" mappings.findFile.description)
            (mkLznBinding ["n"] cfg.mappings.focus ":NvimTreeFocus<cr>" mappings.focus.description)
          ];
        };
      };
    };

    vim.pluginRC.nvimtreelua = entryAnywhere ''
      ${
        optionalString cfg.setupOpts.disable_netrw ''
          -- disable netrew completely
          vim.g.loaded_netrw = 1
          vim.g.loaded_netrwPlugin = 1
        ''
      }

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
  };
}
