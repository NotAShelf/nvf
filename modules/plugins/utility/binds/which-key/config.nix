{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.binds.whichKey;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["which-key"];

      pluginRC.whichkey = entryAnywhere ''
        local wk = require("which-key")

        wk.setup (${toLuaObject cfg.setupOpts})
        wk.register(${toLuaObject cfg.register})
      '';
    };
  };
}
