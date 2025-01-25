{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.diff;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-diff"];

    pluginRC.mini-diff = entryAnywhere ''
      require("mini.diff").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
