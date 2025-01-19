{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.starter;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-starter"];

    pluginRC.mini-starter = entryAnywhere ''
      require("mini.starter").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
