{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.lists) optionals;
  inherit (lib.types) submodule listOf str;
in {
  options.vim.binds.whichKey = {
    enable = mkEnableOption "which-key keybind helper menu";

    register = mkOption {
      description = "Register label for which-key keybind helper menu";
      type = listOf (submodule {
        options = {
          keybind = mkOption {
            type = str;
            description = "Keybind to register";
          };
          label = mkOption {
            type = str;
            description = "Label for keybind";
          };
        };
      });
      default =
        optionals config.vim.tabline.nvimBufferline.enable [
          {
            keybind = "<leader>b";
            label = "+Buffer";
          }
          {
            keybind = "<leader>bm";
            label = "BufferLineMove";
          }
          {
            keybind = "<leader>bs";
            label = "BufferLineSort";
          }
          {
            keybind = "<leader>bsi";
            label = "BufferLineSortById";
          }
        ]
        ++ optionals config.vim.telescope.enable [
          {
            keybind = "<leader>f";
            label = "+Telescope";
          }
          {
            keybind = "<leader>fl";
            label = "Telescope LSP";
          }
          {
            keybind = "<leader>fm";
            label = "Cellular Automaton";
          }
          {
            keybind = "<leader>fv";
            label = "Telescope Git";
          }
          {
            keybind = "<leader>fvc";
            label = "Commits";
          }
        ]
        ++ optionals config.vim.lsp.trouble.enable [
          {
            keybind = "<leader>lw";
            label = "Workspace";
          }
          {
            keybind = "<leader>x";
            label = "+Trouble";
          }
          {
            keybind = "<leader>l";
            label = "Trouble";
          }
        ]
        ++ optionals config.vim.lsp.nvimCodeActionMenu.enable [
          {
            keybind = "<leader>c";
            label = "+CodeAction";
          }
        ]
        ++ optionals (config.vim.minimap.codewindow.enable || config.vim.minimap.minimap-vim.enable) [
          {
            keybind = "<leader>m";
            label = "+Minimap";
          }
        ]
        ++ optionals (config.vim.notes.mind-nvim.enable || config.vim.notes.obsidian.enable || config.vim.notes.orgmode.enable) [
          {
            keybind = "<leader>o";
            label = "+Notes";
          }
        ]
        ++ optionals config.vim.filetree.nvimTree.enable [
          {
            keybind = "<leader>t";
            label = "+NvimTree";
          }
        ]
        ++ optionals config.vim.git.gitsigns.enable [
          {
            keybind = "<leader>g";
            label = "+Gitsigns";
          }
        ]
        ++ optionals config.vim.utility.preview.glow.enable [
          {
            keybind = "<leader>pm";
            label = "+Preview Markdown";
          }
        ];
      apply = map (x: {${x.keybind} = {name = x.label;};});
    };
  };
}
