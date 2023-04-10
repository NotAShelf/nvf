{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.telescope;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "telescope"
    ];

    vim.maps.normal =
      {
        "<leader>ff" = {action = "<cmd> Telescope find_files<CR>";};
        "<leader>fg" = {action = "<cmd> Telescope live_grep<CR>";};
        "<leader>fb" = {action = "<cmd> Telescope buffers<CR>";};
        "<leader>fh" = {action = "<cmd> Telescope help_tags<CR>";};
        "<leader>ft" = {action = "<cmd> Telescope<CR>";};

        "<leader>fvcw" = {action = "<cmd> Telescope git_commits<CR>";};
        "<leader>fvcb" = {action = "<cmd> Telescope git_bcommits<CR>";};
        "<leader>fvb" = {action = "<cmd> Telescope git_branches<CR>";};
        "<leader>fvs" = {action = "<cmd> Telescope git_status<CR>";};
        "<leader>fvx" = {action = "<cmd> Telescope git_stash<CR>";};
      }
      // (
        if config.vim.lsp.enable
        then {
          "<leader>flsb" = {action = "<cmd> Telescope lsp_document_symbols<CR>";};
          "<leader>flsw" = {action = "<cmd> Telescope lsp_workspace_symbols<CR>";};

          "<leader>flr" = {action = "<cmd> Telescope lsp_references<CR>";};
          "<leader>fli" = {action = "<cmd> Telescope lsp_implementations<CR>";};
          "<leader>flD" = {action = "<cmd> Telescope lsp_definitions<CR>";};
          "<leader>flt" = {action = "<cmd> Telescope lsp_type_definitions<CR>";};
          "<leader>fld" = {action = "<cmd> Telescope diagnostics<CR>";};
        }
        else {}
      )
      // (
        if config.vim.treesitter.enable
        then {
          "<leader>fs" = {action = "<cmd> Telescope treesitter<CR>";};
        }
        else {}
      );

    vim.luaConfigRC.telescope = nvim.dag.entryAnywhere ''
      local telescope = require('telescope')
      telescope.setup {
        defaults = {
          vimgrep_arguments = {
            "${pkgs.ripgrep}/bin/rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--no-ignore",
          },
          pickers = {
            find_command = {
              "${pkgs.fd}/bin/fd",
            },
          },
        },
        prompt_prefix = "     ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.8,
          height = 0.8,
          preview_cutoff = 120,
        },
        file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/", "target/", "result/" }, -- TODO: make this configurable
        color_devicons = true,
        path_display = { "absolute" },
        set_env = { ["COLORTERM"] = "truecolor" },
        winblend = 0,
        border = {},
      }

      ${
        if config.vim.ui.noice.enable
        then "telescope.load_extension('noice')"
        else ""
      }

      ${
        if config.vim.notify.nvim-notify.enable
        then "telescope.load_extension('notify')"
        else ""
      }
    '';
  };
}
