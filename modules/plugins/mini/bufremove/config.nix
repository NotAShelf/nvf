{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.bufremove;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-bufremove"];

    pluginRC.mini-bufremove = entryAnywhere ''
      require("mini.bufremove").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
