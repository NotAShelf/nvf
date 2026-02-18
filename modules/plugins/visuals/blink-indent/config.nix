{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.visuals.blink-indent;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["blink-indent"];

      pluginRC.blink-indent = entryAnywhere ''
        require("blink.indent").setup(${toLuaObject cfg.setupOpts})
      '';
    };
  };
}
