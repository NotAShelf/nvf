{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.misc;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-misc"];

    pluginRC.mini-misc = entryAnywhere ''
      require("mini.misc").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
