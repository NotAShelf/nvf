{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.operators;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-operators"];

    pluginRC.mini-operators = entryAnywhere ''
      require("mini.operators").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
