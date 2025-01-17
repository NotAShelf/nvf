{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.move;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-move"];

    pluginRC.mini-move = entryAnywhere ''
      require("mini.move").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
