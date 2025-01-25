{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.bracketed;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-bracketed"];

    pluginRC.mini-bracketed = entryAnywhere ''
      require("mini.bracketed").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
