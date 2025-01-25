{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.hues;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-hues"];

    pluginRC.mini-hues = entryAnywhere ''
      require("mini.hues").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
