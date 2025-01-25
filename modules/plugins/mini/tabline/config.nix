{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.tabline;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-tabline"];

    pluginRC.mini-tabline = entryAnywhere ''
      require("mini.tabline").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
