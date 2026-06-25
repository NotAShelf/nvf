{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.ui.ui2;
in {
  config = mkIf cfg.enable {
    vim = {
      luaConfigRC.ui2 = entryAnywhere ''
        require('vim._core.ui2').enable(${toLuaObject (cfg.setupOpts // {enable = lib.mkForce true;})})
      '';
    };
  };
}
