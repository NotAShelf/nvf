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

    vim.nnoremap =
      {
        "<leader>ff" = "<cmd> Telescope find_files<CR>";
        "<leader>fg" = "<cmd> Telescope live_grep<CR>";
        "<leader>fb" = "<cmd> Telescope buffers<CR>";
        "<leader>fh" = "<cmd> Telescope help_tags<CR>";
        "<leader>ft" = "<cmd> Telescope<CR>";

        "<leader>fvcw" = "<cmd> Telescope git_commits<CR>";
        "<leader>fvcb" = "<cmd> Telescope git_bcommits<CR>";
        "<leader>fvb" = "<cmd> Telescope git_branches<CR>";
        "<leader>fvs" = "<cmd> Telescope git_status<CR>";
        "<leader>fvx" = "<cmd> Telescope git_stash<CR>";
      }
      // (
        if config.vim.lsp.enable
        then {
          "<leader>flsb" = "<cmd> Telescope lsp_document_symbols<CR>";
          "<leader>flsw" = "<cmd> Telescope lsp_workspace_symbols<CR>";

          "<leader>flr" = "<cmd> Telescope lsp_references<CR>";
          "<leader>fli" = "<cmd> Telescope lsp_implementations<CR>";
          "<leader>flD" = "<cmd> Telescope lsp_definitions<CR>";
          "<leader>flt" = "<cmd> Telescope lsp_type_definitions<CR>";
          "<leader>fld" = "<cmd> Telescope diagnostics<CR>";
        }
        else {}
      )
      // (
        if config.vim.treesitter.enable
        then {
          "<leader>fs" = "<cmd> Telescope treesitter<CR>";
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
        else null
      }

      ${
        if config.vim.notify.nvim-notify.enable
        then "telescope.load_extension('notify')"
        else null
      }
    '';
  };
}
