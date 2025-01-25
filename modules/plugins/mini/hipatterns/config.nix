{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.hipatterns;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-hipatterns"];

    pluginRC.mini-hipatterns = entryAnywhere ''
      require("mini.hipatterns").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
