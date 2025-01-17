{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.sessions;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-sessions"];

    pluginRC.mini-sessions = entryAnywhere ''
      require("mini.sessions").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
