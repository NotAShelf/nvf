{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.binds.whichKey;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["which-key"];

    vim.pluginRC.whichkey = entryAnywhere ''
      local wk = require("which-key")
      wk.setup ({
        key_labels = {
          ["<space>"] = "SPACE",
          ["<leader>"] = "SPACE",
          ["<cr>"] = "RETURN",
          ["<tab>"] = "TAB",
        },

        ${optionalString config.vim.ui.borders.plugins.which-key.enable ''
        window = {
          border = ${toLuaObject config.vim.ui.borders.plugins.which-key.style},
        },
      ''}
      })

      wk.register(${toLuaObject cfg.register})
    '';
  };
}
