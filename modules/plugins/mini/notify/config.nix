{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.notify;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-notify"];

    pluginRC.mini-notify = entryAnywhere ''
      require("mini.notify").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
