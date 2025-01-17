{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.basics;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-basics"];

    pluginRC.mini-basics = entryAnywhere ''
      require("mini.basics").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
