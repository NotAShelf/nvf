{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.jump;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-jump"];

    pluginRC.mini-jump = entryAnywhere ''
      require("mini.jump").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
