{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.indentscope;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-indentscope"];

    pluginRC.mini-indentscope = entryAnywhere ''
      require("mini.indentscope").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
