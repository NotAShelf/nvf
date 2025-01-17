{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.icons;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-icons"];

    pluginRC.mini-icons = entryAnywhere ''
      require("mini.icons").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
