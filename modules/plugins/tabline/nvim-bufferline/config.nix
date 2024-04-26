{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) mkLuaBinding mkBinding pushDownDefault;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.tabline.nvimBufferline;

  self = import ./nvim-bufferline.nix {inherit lib;};
  inherit (self.options.vim.tabline.nvimBufferline) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        (assert config.vim.visuals.nvimWebDevicons.enable; "nvim-bufferline-lua")
        "bufdelete-nvim"
      ];

      binds.whichKey.register = pushDownDefault {
        "<leader>b" = "+Buffer";
        "<leader>bm" = "BufferLineMove";
        "<leader>bs" = "BufferLineSort";
        "<leader>bsi" = "BufferLineSortById";
      };

      luaConfigRC.nvimBufferline = entryAnywhere ''
        require("bufferline").setup({options = ${toLuaObject cfg.setupOpts}})
      '';
    };
  };
}
