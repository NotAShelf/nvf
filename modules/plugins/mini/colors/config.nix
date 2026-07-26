{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.colors;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-colors"];

    pluginRC.mini-colors = entryAnywhere ''
      require("mini.colors").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
