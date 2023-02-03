{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.dashboard.dashboard-nvim;
in {
  options.vim.dashboard.dashboard-nvim = {
    enable = mkEnableOption "dashboard-nvim";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [
      "dashboard-nvim"
    ];

    vim.nnoremap = {
      "<silent><leader>bn" = ":BufferLineCycleNext<CR>";
      "<silent><leader>bp" = ":BufferLineCyclePrev<CR>";
      "<silent><leader>bc" = ":BufferLinePick<CR>";
      "<silent><leader>bse" = ":BufferLineSortByExtension<CR>";
      "<silent><leader>bsd" = ":BufferLineSortByDirectory<CR>";
      "<silent><leader>bsi" = ":lua require'bufferline'.sort_buffers_by(function (buf_a, buf_b) return buf_a.id < buf_b.id end)<CR>";
      "<silent><leader>bmn" = ":BufferLineMoveNext<CR>";
      "<silent><leader>bmp" = ":BufferLineMovePrev<CR>";
      "<silent><leader>b1" = "<Cmd>BufferLineGoToBuffer 1<CR>";
      "<silent><leader>b2" = "<Cmd>BufferLineGoToBuffer 2<CR>";
      "<silent><leader>b3" = "<Cmd>BufferLineGoToBuffer 3<CR>";
      "<silent><leader>b4" = "<Cmd>BufferLineGoToBuffer 4<CR>";
      "<silent><leader>b5" = "<Cmd>BufferLineGoToBuffer 5<CR>";
      "<silent><leader>b6" = "<Cmd>BufferLineGoToBuffer 6<CR>";
      "<silent><leader>b7" = "<Cmd>BufferLineGoToBuffer 7<CR>";
      "<silent><leader>b8" = "<Cmd>BufferLineGoToBuffer 8<CR>";
      "<silent><leader>b9" = "<Cmd>BufferLineGoToBuffer 9<CR>";
    };

    vim.luaConfigRC.dashboard-nvim = nvim.dag.entryAnywhere ''
      require("dashboard-nvim").setup{
        hide = {
          statusline    -- hide statusline default is true
          tabline       -- hide the tabline
          winbar        -- hide winbar
        },
        preview = {
          command       -- preview command
          file_path     -- preview file path
          file_height   -- preview file height
          file_width    -- preview file width
        },
      }
    '';
  };
}
