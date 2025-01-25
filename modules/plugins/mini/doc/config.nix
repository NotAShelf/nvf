{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.doc;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-doc"];

    pluginRC.mini-doc = entryAnywhere ''
      require("mini.doc").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
