{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.ui.smartcolumn;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["smartcolumn"];

      luaConfigRC.smartcolumn = entryAnywhere ''
        require("smartcolumn").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
