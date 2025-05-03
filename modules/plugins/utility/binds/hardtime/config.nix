{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.binds.hardtime-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["hardtime-nvim"];

      pluginRC.hardtime = entryAnywhere ''
        require("hardtime").setup (${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
