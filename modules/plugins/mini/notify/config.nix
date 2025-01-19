{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkAssert;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.notify;
in {
  vim = mkIf cfg.enable (mkAssert (!config.vim.notify.nvim-notify.enable) "Mini.notify is incompatible with nvim-notify!" {
    startPlugins = ["mini-notify"];

    pluginRC.mini-notify = entryAnywhere ''
      require("mini.notify").setup(${toLuaObject cfg.setupOpts})
      vim.notify = MiniNotify.make_notify(${toLuaObject cfg.notifyOpts})
    '';
  });
}
