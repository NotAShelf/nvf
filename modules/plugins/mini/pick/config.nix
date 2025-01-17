{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.pick;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-pick"];

    pluginRC.mini-pick = entryAnywhere ''
      require("mini.pick").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
