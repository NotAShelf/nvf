{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.test;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-test"];

    pluginRC.mini-test = entryAnywhere ''
      require("mini.test").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
