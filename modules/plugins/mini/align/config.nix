{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.align;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-align"];

    pluginRC.mini-align = entryAnywhere ''
      require("mini.align").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
