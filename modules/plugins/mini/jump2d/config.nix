{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.jump2d;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-jump2d"];

    pluginRC.mini-jump2d = entryAnywhere ''
      require("mini.jump2d").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
