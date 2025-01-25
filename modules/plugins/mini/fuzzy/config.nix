{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.fuzzy;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-fuzzy"];

    pluginRC.mini-fuzzy = entryAnywhere ''
      require("mini.fuzzy").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
