{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.ai;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-ai"];

    pluginRC.mini-ai = entryAnywhere ''
      require("mini.ai").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
