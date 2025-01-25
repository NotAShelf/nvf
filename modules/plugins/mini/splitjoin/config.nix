{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.splitjoin;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-splitjoin"];

    pluginRC.mini-splitjoin = entryAnywhere ''
      require("mini.splitjoin").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
