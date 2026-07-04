{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.cmdline;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-cmdline"];

    pluginRC.mini-cmdline = entryAnywhere ''
      require("mini.cmdline").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
