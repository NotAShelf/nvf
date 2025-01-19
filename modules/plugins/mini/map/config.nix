{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.map;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-map"];

    pluginRC.mini-map = entryAnywhere ''
      require("mini.map").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
