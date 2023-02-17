{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.binds.whichKey;
in {
  options.vim.binds.whichKey = {
    enable = mkEnableOption "which-key menu";
  };

  config = mkIf (cfg.enable) {
    vim.startPlugins = ["which-key"];

    vim.luaConfigRC.whichkey = nvim.dag.entryAnywhere ''
      require("which-key").setup {}

      local wk = require("which-key")
      wk.register({
        ["<leader>b"] = { name = "+Buffer" },
        ["<leader>c"] = { name = "+CodeAction" },
        ["<leader>b"] = { name = "+Buffer" },
        ["<leader>f"] = { name = "+Telescope" },
        ["<leader>m"] = { name = "+Minimap" },
        ["<leader>o"] = { name = "+Notes" },
        ["<leader>t"] = { name = "+NvimTree" },
        ["<leader>x"] = { name = "+Trouble" }, -- TODO: move all trouble binds to the same parent group
        ["<leader>l"] = { name = "+Trouble" },

        -- Buffer
        ["<leader>bm"] = { name = "BufferLineMove" },
        ["<leader>bm"] = { name = "BufferLineSort" },

        -- Telescope
        ["<leader>fl"] = { name = "Telescope LSP" },
        ["<leader>fm"] = { name = "Cellular Automaton" }, -- TODO: mvoe this to its own parent group
        ["<leader>fv"] = { name = "Telescope Git" },
        ["<leader>fvc"] = { name = "Commits" },

        -- Trouble
        ["<leader>lw"] = { name = "Workspace" },
      })

    '';
  };
}
