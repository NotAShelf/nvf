{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.visits;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-visits"];

    pluginRC.mini-visits = entryAnywhere ''
      require("mini.visits").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
