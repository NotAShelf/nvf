{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;

  cfg = config.vim.binds.whichKey;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = ["which-key"];

    vim.luaConfigRC.whichkey = nvim.dag.entryAnywhere ''
      local wk = require("which-key")
      wk.setup ({
        key_labels = {
          ["<space>"] = "SPACE",
          ["<leader>"] = "SPACE",
          ["<cr>"] = "RETURN",
          ["<tab>"] = "TAB",
        },

        ${lib.optionalString (config.vim.ui.borders.plugins.which-key.enable) ''
        window = {
          border = "${config.vim.ui.borders.plugins.which-key.style}",
        },
      ''}
      })

      wk.register({
        ${
        if config.vim.tabline.nvimBufferline.enable
        then ''
          -- Buffer
          ["<leader>b"] = { name = "+Buffer" },
          ["<leader>bm"] = { name = "BufferLineMove" },
          ["<leader>bs"] = { name = "BufferLineSort" },
          ["<leader>bsi"] = { name = "BufferLineSortById" },
        ''
        else ""
      }

        ${
        if config.vim.telescope.enable
        then ''
          ["<leader>f"] = { name = "+Telescope" },
           -- Telescope
          ["<leader>fl"] = { name = "Telescope LSP" },
          ["<leader>fm"] = { name = "Cellular Automaton" }, -- TODO: mvoe this to its own parent group
          ["<leader>fv"] = { name = "Telescope Git" },
          ["<leader>fvc"] = { name = "Commits" },
        ''
        else ""
      }

        ${
        if config.vim.lsp.trouble.enable
        then ''
          -- Trouble
          ["<leader>lw"] = { name = "Workspace" },
          ["<leader>x"] = { name = "+Trouble" }, -- TODO: move all trouble binds to the same parent group
          ["<leader>l"] = { name = "+Trouble" },
        ''
        else ""
      }

        ${
        if config.vim.lsp.nvimCodeActionMenu.enable
        then ''
          -- Parent Groups
          ["<leader>c"] = { name = "+CodeAction" },
        ''
        else ""
      }

        ${
        if config.vim.minimap.codewindow.enable || config.vim.minimap.minimap-vim.enable
        then ''
          -- Minimap
          ["<leader>m"] = { name = "+Minimap" }, -- TODO: remap both minimap plugins' keys to be the same
        ''
        else ""
      }

        ${
        if config.vim.notes.mind-nvim.enable || config.vim.notes.obsidian.enable || config.vim.notes.orgmode.enable
        then ''
          -- Notes
          ["<leader>o"] = { name = "+Notes" },
          -- TODO: options for other note taking plugins and their individual binds
          -- TODO: move all note-taker binds under leader + o
        ''
        else ""
      }

        ${
        # TODO: This probably will need to be reworked for custom-keybinds
        if config.vim.filetree.nvimTree.enable
        then ''
          -- NvimTree
          ["<leader>t"] = { name = "+NvimTree" },
        ''
        else ""
      }

        ${
        if config.vim.git.gitsigns.enable
        then ''
          -- Git
          ["<leader>g"] = { name = "+Gitsigns" },
        ''
        else ""
      }

        ${
        if config.vim.languages.markdown.glow.enable
        then ''
          -- Markdown
          ["<leader>pm"] = { name = "+Preview Markdown" },
        ''
        else ""
      }

      })
    '';
  };
}
