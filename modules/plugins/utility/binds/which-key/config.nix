{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.binds.whichKey;
  register = mapAttrsToList (n: v: lib.lists.optional (v != null) (mkLuaInline "{ '${n}', desc = '${v}' }")) cfg.register;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["which-key-nvim"];

      pluginRC.whichkey = entryAnywhere ''
        local wk = require("which-key")
        wk.setup (${toLuaObject cfg.setupOpts})
        wk.add(${toLuaObject register})
      '';
    };
  };
}
