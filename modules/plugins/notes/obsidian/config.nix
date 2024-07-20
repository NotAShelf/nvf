{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) pushDownDefault;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.notes.obsidian;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "obsidian-nvim"
        "vim-markdown"
        "tabular"
      ];

      binds.whichKey.register = pushDownDefault {
        "<leader>o" = "+Notes";
      };

      pluginRC.obsidian = entryAnywhere ''
        require("obsidian").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
