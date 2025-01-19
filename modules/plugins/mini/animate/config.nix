{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.animate;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-animate"];

    pluginRC.mini-animate = entryAnywhere ''
      require("mini.animate").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
