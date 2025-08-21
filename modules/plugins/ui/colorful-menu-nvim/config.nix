{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.ui.colorful-menu-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["colorful-menu-nvim"];
      pluginRC.colorful-menu-nvim = entryAnywhere ''
        require("colorful-menu").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
