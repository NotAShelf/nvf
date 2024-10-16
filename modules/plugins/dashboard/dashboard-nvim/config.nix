{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.dashboard.dashboard-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["dashboard-nvim"];

      pluginRC.dashboard-nvim = entryAnywhere ''
        require("dashboard").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
