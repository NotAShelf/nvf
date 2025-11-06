{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.cursorword;
in {
  vim = mkIf cfg.enable {
    startPlugins = ["mini-cursorword"];

    pluginRC.mini-ai = entryAnywhere ''
      require("mini.cursorword").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
